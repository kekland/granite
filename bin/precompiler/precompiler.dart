// ignore_for_file: avoid_print

/*
 * Precompiler 
 * (will be obsolete with online compilation! but it's not supported yet.)
 * 
 * Objectives: 
 * - precompile shaders (via impellerc) **fast**
 * - generate shaderbundle flatbuffers
 * - do black magic trickery to support shader hot reloading
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart';

import 'shader_bundle/shader_bundle_impeller.fb.shaderbundle_generated.dart' as ipsb;

import 'package:flutter_gpu_shaders/environment.dart';
import 'package:granite/renderer/preprocessor/preprocessor.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'shader_bundle_utils.dart';

Future<void> precompileStyle({
  required File outputFile,
  required spec.Style style,
  bool addHotReloadSuffix = false,
}) async {
  final tempDir = Directory.systemTemp.createTempSync('granite_precompiler');
  final hotReloadSuffix = addHotReloadSuffix ? DateTime.now().millisecondsSinceEpoch.toString() : null;
  print('temp directory: ${tempDir.path}');
  print('hot reload suffix: $hotReloadSuffix');

  final preprocessedStyle = StylePreprocessor.preprocess(style);

  print('starting compilation');
  print('impellerC path: ${await findImpellerC()}');
  final bundles = await preprocessedStyle.layers.nonNulls
      .map(
        (v) => _compileLayer(
          tempDir: tempDir,
          layer: v,
          styleName: style.name!,
          hotReloadSuffix: hotReloadSuffix,
        ),
      )
      .wait;
  print('compiled ${bundles.length} layers');
  print('compiling generic shaders');
  final genericBundle = await _compileGenericShaders(
    tempDir: tempDir,
    genericShaders: preprocessedStyle.genericShaders,
    hotReloadSuffix: hotReloadSuffix,
  );
  print('compiled generic shaders');

  final (zippedBundleBytes, zippedBundle) = _zipShaderBundles([...bundles, genericBundle]);
  await outputFile.writeAsBytes(zippedBundleBytes);
}

Future<ipsb.ShaderBundle> _compileLayer({
  required Directory tempDir,
  required PreprocessedLayer layer,
  required String styleName,
  String? hotReloadSuffix,
}) async {
  final shaderBundleJson = {};
  final suffix = hotReloadSuffix != null ? '#$hotReloadSuffix' : '';

  final shaderFileName = '${tempDir.path}/${layer.id}$suffix';

  // Write vertex and fragment shaders to temp directory
  final vertFile = await File('$shaderFileName.vert').writeAsString(layer.vertexShaderCode);
  final fragFile = await File('$shaderFileName.frag').writeAsString(layer.fragmentShaderCode);

  // Write them to the shader bundle JSON
  shaderBundleJson['$styleName/${layer.id}-vert$suffix'] = {'type': 'vertex', 'file': vertFile.path};
  shaderBundleJson['$styleName/${layer.id}-frag$suffix'] = {'type': 'fragment', 'file': fragFile.path};

  // Run impellerc
  final slOutFile = File('${tempDir.path}/${layer.id}.shaderbundle');
  final shaderbundle = await _executeImpellerC(shaderBundleJson: shaderBundleJson, slOutFile: slOutFile);

  return shaderbundle;
}

Future<ipsb.ShaderBundle> _compileGenericShaders({
  required Directory tempDir,
  required Map<String, String> genericShaders,
  String? hotReloadSuffix,
}) async {
  final shaderBundleJson = {};
  final suffix = hotReloadSuffix != null ? '#$hotReloadSuffix' : '';

  for (final entry in genericShaders.entries) {
    final name = '${entry.key}$suffix';
    final code = entry.value;
    final type = entry.key.split('-').last;

    final file = await File('${tempDir.path}/$name.$type').writeAsString(code);
    shaderBundleJson[name] = {'type': type == 'vert' ? 'vertex' : 'fragment', 'file': file.path};
  }

  final slOutFile = File('${tempDir.path}/generic_shaders.shaderbundle');
  final shaderbundle = await _executeImpellerC(shaderBundleJson: shaderBundleJson, slOutFile: slOutFile);
  return shaderbundle;
}

Uri? _impellerCExecPath;
Future<ipsb.ShaderBundle> _executeImpellerC({
  required Map shaderBundleJson,
  required File slOutFile,
}) async {
  _impellerCExecPath ??= await findImpellerC();

  final impellercArgs = [
    '--sl=${slOutFile.absolute.path}',
    '--shader-bundle=${jsonEncode(shaderBundleJson)}',
  ];

  final result = await Process.run(_impellerCExecPath!.toFilePath(), impellercArgs);
  if (result.exitCode != 0) {
    throw Exception('Failed to build shader bundle: ${result.stderr}\n${result.stdout}');
  }

  return ipsb.ShaderBundle(await slOutFile.readAsBytes());
}

(Uint8List, ipsb.ShaderBundle) _zipShaderBundles(List<ipsb.ShaderBundle> bundles) {
  final shaders = <ipsb.ShaderObjectBuilder>[];

  for (final bundle in bundles) {
    for (final s in bundle.shaders!) {
      shaders.add(
        ipsb.ShaderObjectBuilder(
          name: s.name,
          metalIos: backendShaderObjectBuilderMapper(s.metalIos),
          metalDesktop: backendShaderObjectBuilderMapper(s.metalDesktop),
          openglDesktop: backendShaderObjectBuilderMapper(s.openglDesktop),
          openglEs: backendShaderObjectBuilderMapper(s.openglEs),
          vulkan: backendShaderObjectBuilderMapper(s.vulkan),
        ),
      );
    }
  }

  final t = ipsb.ShaderBundleObjectBuilder(shaders: shaders);
  final fbb = Builder();
  fbb.finish(t.finish(fbb), 'IPSB');

  return (fbb.buffer, ipsb.ShaderBundle(fbb.buffer));
}
