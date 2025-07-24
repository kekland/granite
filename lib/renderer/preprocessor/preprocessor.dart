import 'package:granite/renderer/preprocessor/gen/raw_shaders.dart';
import 'package:granite/spec/spec.dart' as spec;

import 'layer_preprocessor.dart';
export 'layer_preprocessor.dart';

class PreprocessedStyle {
  PreprocessedStyle({
    required this.layers,
    required this.genericShaders,
  });

  final List<PreprocessedLayer?> layers;
  final Map<String, String> genericShaders;
}

class StylePreprocessor {
  static PreprocessedStyle preprocess(spec.Style style) {
    return PreprocessedStyle(
      layers: style.layers.map(LayerPreprocessor.preprocess).toList(),
      genericShaders: {
        'texture-vert': RawShaders.texture_vert,
        'texture-frag': RawShaders.texture_frag,
      },
    );
  }
}
