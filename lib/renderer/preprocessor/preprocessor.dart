import 'package:granite/renderer/preprocessor/layer_preprocessor.dart';
import 'package:granite/spec/spec.dart' as spec;

class PreprocessedStyle {
  PreprocessedStyle({required this.layers});

  final List<PreprocessedLayer?> layers;
}

class StylePreprocessor {
  static PreprocessedStyle preprocess(spec.Style style) {
    return PreprocessedStyle(
      layers: style.layers.map(LayerPreprocessor.preprocess).toList(),
    );
  }
}
