import 'package:granite/renderer/core/props/prop_instruction.dart';
import 'package:granite/renderer/preprocessor/analysis/property_analyzer.dart';
import 'package:granite/renderer/preprocessor/gen/raw_shaders.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/spec/gen/style.gen.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:vector_math/vector_math_64.dart';

class PreprocessedLayer {
  PreprocessedLayer({
    required this.id,
    required this.vertexShaderCode,
    required this.fragmentShaderCode,
    required this.vertexPropInstructions,
    required this.uniformPropInstructions,
  });

  final String id;
  final String vertexShaderCode;
  final String fragmentShaderCode;
  final List<PropInstruction> vertexPropInstructions;
  final List<PropInstruction> uniformPropInstructions;
}

final _variableRegex = RegExp(r'(highp|mediump|lowp)? ?([a-zA-Z0-9]+) ([a-zA-Z0-9]+)');
(String? precision, String type, String name) _parseVariable(String line) {
  final match = _variableRegex.firstMatch(line);
  if (match == null) {
    throw ArgumentError('Invalid variable declaration: $line');
  }
  final precision = match.group(1);
  final type = match.group(2)!;
  final name = match.group(3)!;
  return (precision, type, name);
}

String _getLayerType(spec.Layer layer) {
  return switch (layer.type) {
    spec.Layer$Type.background => 'background',
    spec.Layer$Type.fill => 'fill',
    spec.Layer$Type.line => 'line',
    spec.Layer$Type.symbol => 'symbol',
    spec.Layer$Type.raster => 'raster',
    spec.Layer$Type.circle => 'circle',
    spec.Layer$Type.fillExtrusion => 'fillExtrusion',
    spec.Layer$Type.hillshade => 'hillshade',
    spec.Layer$Type.heatmap => 'heatmap',
  };
}

String _joinLowerCamelCase(List<String> parts) {
  if (parts.isEmpty) return '';
  final first = parts.first[0].toLowerCase() + parts.first.substring(1);
  final rest = parts.skip(1).map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase()).join('');
  return first + rest;
}

Type _glslTypeToDartType(String glslType) {
  return switch (glslType) {
    'float' => double,
    'int' => int,
    'bool' => bool,
    'vec2' => Vector2,
    'vec3' => Vector3,
    'vec4' => Vector4,
    'mat2' => Matrix2,
    'mat3' => Matrix3,
    'mat4' => Matrix4,
    _ => throw ArgumentError('Unknown GLSL type: $glslType'),
  };
}

int _glslTypeSizeInBytes(String glslType) {
  return switch (glslType) {
    'float' => 4,
    'int' => 4,
    'bool' => 1,
    'vec2' => 8,
    'vec3' => 12,
    'vec4' => 16,
    'mat2' => 32,
    'mat3' => 48,
    'mat4' => 64,
    _ => throw ArgumentError('Unknown GLSL type: $glslType'),
  };
}

String _writeValue(Object? value) {
  if (value is String) {
    return '"$value"';
  } else if (value is num || value is bool) {
    return value.toString();
  } else if (value is Vector2) {
    return 'vec2(${value.x}, ${value.y})';
  } else if (value is Vector3) {
    return 'vec3(${value.x}, ${value.y}, ${value.z})';
  } else if (value is Vector4) {
    return 'vec4(${value.x}, ${value.y}, ${value.z}, ${value.w})';
  } else {
    throw ArgumentError('Unsupported value type: ${value.runtimeType}');
  }
}

List<String> _indentLines(List<String> lines, [int indent = 2]) {
  final indentStr = ' ' * indent;
  return lines.map((line) => '$indentStr$line').toList();
}

(String, String)? _getShaderCode(spec.Layer layer) {
  return switch (layer.type) {
    Layer$Type.background => (RawShaders.background_vert, RawShaders.background_frag),
    Layer$Type.fill => (RawShaders.fill_vert, RawShaders.fill_frag),
    Layer$Type.line => (RawShaders.line_vert, RawShaders.line_frag),
    Layer$Type.fillExtrusion => (RawShaders.fill_extrusion_vert, RawShaders.fill_extrusion_frag),
    _ => null,
  };
}

class LayerPreprocessor {
  static List<(int line, String pragma)> _getPropDeclarationPragmas(List<String> shaderCodeLines) {
    final pragmas = <(int, String)>[];

    for (var i = 0; i < shaderCodeLines.length; i++) {
      final line = shaderCodeLines[i];
      if (line.startsWith('#pragma prop: declare(')) {
        final decl = line.split('(')[1].split(')')[0];
        pragmas.add((i, decl));
      }
    }

    return pragmas;
  }

  static List<String> _applyResolutionPragma(List<String> shaderCodeLines, List<String> resolution) {
    final newLines = <String>[];

    for (final line in shaderCodeLines) {
      if (line.contains('#pragma prop: resolve')) {
        newLines.addAll(_indentLines(resolution, 2));
      } else {
        newLines.add(line);
      }
    }

    return newLines;
  }

  static PreprocessedLayer? preprocess(spec.Layer layer) {
    final layerType = _getLayerType(layer);
    final shaderCode = _getShaderCode(layer);
    if (shaderCode == null) return null;

    final (vertexShaderCode, fragmentShaderCode) = shaderCode;
    var vertexShaderCodeLines = vertexShaderCode.split('\n').toList();
    var fragmentShaderCodeLines = fragmentShaderCode.split('\n').toList();

    var vertexResolution = <String>[];
    var fragmentResolution = <String>[];
    var uniformMembers = <String>[];

    final vertexPropInstructions = <PropInstruction>[];
    final uniformPropInstructions = <PropInstruction>[];

    final vertexPropDeclarations = _getPropDeclarationPragmas(vertexShaderCodeLines);
    final fragmentPropDeclarations = _getPropDeclarationPragmas(fragmentShaderCodeLines);

    if (vertexPropDeclarations.length != fragmentPropDeclarations.length) {
      throw ArgumentError('Vertex and fragment shader prop declarations do not match.');
    }

    for (final (index, variable) in vertexPropDeclarations) {
      final (precision, glslType, name) = _parseVariable(variable);
      final dartType = _glslTypeToDartType(glslType);
      final propSymbol = Symbol(_joinLowerCamelCase([layerType, name]));
      final prop = layer.paint!.getProperty(propSymbol);
      final analysis = analyzeProperty(prop);

      var vertexPropReplacement = '';
      var fragmentPropReplacement = '';

      if (analysis.type == PropertyShaderType.constant) {
        vertexPropReplacement = 'const $variable = ${_writeValue(analysis.constantValue!)};';
        fragmentPropReplacement = 'const $variable = ${_writeValue(analysis.constantValue!)};';
      } else {
        final variables = <String>[];
        final resolution = <String>[];
        final instructions = <PropInstruction>[];

        if (analysis.interpolation == null) {
          variables.add(variable);
          instructions.add(
            SetPropInstruction(
              memberName: name,
              propertySymbol: propSymbol,
              setter: internal_resolveByteDataSetter(dartType),
              sizeInBytes: _glslTypeSizeInBytes(glslType),
            ),
          );
        }
        //
        else if (analysis.interpolation == PropertyInterpolation.crossfade) {
          variables.add('${variable}_start_value');
          variables.add('${variable}_end_value');
          resolution.add('$variable = prop_crossfade(${name}_start_value, ${name}_end_value);');

          instructions.add(
            SetPropWithCrossFadeInstruction(
              memberName: '${name}_start_value',
              propertySymbol: propSymbol,
              setter: internal_resolveByteDataSetter(dartType),
              sizeInBytes: 2 * _glslTypeSizeInBytes(glslType),
            ),
          );
        }
        //
        else {
          // interpolate or step
          variables.add('${variable}_start_value');
          variables.add('${variable}_end_value');
          uniformMembers.add('vec2 ${name}_stops');

          final fn = 'prop_${analysis.interpolation!.name}';
          resolution.add(
            '$variable = $fn(${name}_start_value, ${name}_end_value, prop_ubo.${name}_stops.x, prop_ubo.${name}_stops.y);',
          );

          instructions.add(
            SetPropWithInterpolationInstruction(
              memberName: '${name}_start_value',
              stops: analysis.interpolationStops!,
              propertySymbol: propSymbol,
              setter: internal_resolveByteDataSetter(dartType),
              sizeInBytes: 2 * _glslTypeSizeInBytes(glslType),
            ),
          );

          uniformPropInstructions.add(
            SetPropInterpolationStopsInstruction(
              memberName: '${name}_stops',
              stops: analysis.interpolationStops!,
            ),
          );
        }

        if (analysis.type == PropertyShaderType.attribute) {
          vertexPropReplacement = [
            for (final v in variables) 'in $v;',
            'out ${variable}_o;',
          ].join('\n');
          fragmentPropReplacement = 'in ${variable}_o;';

          vertexResolution.addAll(resolution);
          vertexResolution.add('${name}_o = $name;');
          fragmentResolution.add('$variable = ${name}_o;');

          vertexPropInstructions.addAll(instructions);
        }
        //
        else if (analysis.type == PropertyShaderType.uniform) {
          uniformMembers.addAll(variables);
          vertexPropReplacement = 'out ${variable}_o;';
          fragmentPropReplacement = 'in ${variable}_o;';

          for (final v in variables) {
            vertexResolution.add('$v = prop_ubo.${v.split(' ').last};');
          }

          vertexResolution.add('${name}_o = $name;');
          fragmentResolution.add('$variable = ${name}_o;');

          uniformPropInstructions.addAll(instructions);
        }
      }

      vertexShaderCodeLines[index] = vertexPropReplacement;

      final fragmentIndex = fragmentPropDeclarations.firstWhere((f) => f.$2 == variable).$1;
      fragmentShaderCodeLines[fragmentIndex] = fragmentPropReplacement;
    }

    vertexShaderCodeLines = _applyResolutionPragma(vertexShaderCodeLines, vertexResolution);
    fragmentShaderCodeLines = _applyResolutionPragma(fragmentShaderCodeLines, fragmentResolution);

    if (uniformMembers.isNotEmpty) {
      final uniformDeclaration = [
        'uniform PropUbo {',
        for (final member in uniformMembers) '  $member;',
        '} prop_ubo;',
        '',
      ];

      vertexShaderCodeLines.insert(2, uniformDeclaration.join('\n'));
      fragmentShaderCodeLines.insert(2, uniformDeclaration.join('\n'));
    }

    return PreprocessedLayer(
      id: layer.id,
      vertexShaderCode: vertexShaderCodeLines.join('\n'),
      fragmentShaderCode: fragmentShaderCodeLines.join('\n'),
      vertexPropInstructions: vertexPropInstructions,
      uniformPropInstructions: uniformPropInstructions,
    );
  }
}
