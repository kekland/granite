// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:granite/spec/spec.dart' as spec;

import 'precompiler/precompiler.dart';

// NOTE:
// This script will be obsolete once we can turn on online shader compilation. In the meantime, style shaders must
// be precompiled to a shader bundle file, which is then used by the renderer.

Future<void> main(List<String> args) async {
  // Args: `compile_style.dart <style_file_path> <out_directory_path>`
  // For now, those are hardcoded.
  // final args = [
  //   'fixtures/maptiler-streets-v2.json',
  //   'example/assets/maptiler-streets.shaderbundle',
  // ];

  final args = [
    'fixtures/maptiler-streets-v2.json',
    'example/assets/maptiler-streets.shaderbundle',
  ];

  // final args = [
  //   'fixtures/maptiler-streets-v2-dark.json',
  //   'example/assets/maptiler-streets-dark.shaderbundle',
  // ];

  final timer = Stopwatch()..start();

  final styleFilePath = args[0];
  final outFile = File(args[1]);

  final style = spec.Style.fromJson(jsonDecode(File(styleFilePath).readAsStringSync()));

  await precompileStyle(
    style: style,
    outputFile: outFile,
    addHotReloadSuffix: true,
  );

  print('Done in ${timer.elapsedMilliseconds}ms');
}
