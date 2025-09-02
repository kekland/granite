import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/spec.dart' as spec;

export 'background/background.dart';
export 'fill/fill.dart';
export 'fill_extrusion/fill_extrusion.dart';
export 'line/line.dart';
export 'symbol/symbol.dart';

LayerNode createLayerNode(spec.Layer specLayer, PreprocessedLayer preprocessedLayer) {
  if (!supportedLayers.contains(specLayer.type)) {
    throw UnsupportedError('Unsupported layer type: ${specLayer.type}, id: ${specLayer.id}');
  }

  return switch (specLayer.type) {
    spec.Layer$Type.background => BackgroundLayerNode(
      specLayer: specLayer as spec.LayerBackground,
      preprocessedLayer: preprocessedLayer,
    ),
    spec.Layer$Type.fill => FillLayerNode(
      specLayer: specLayer as spec.LayerFill,
      preprocessedLayer: preprocessedLayer,
    ),
    spec.Layer$Type.fillExtrusion => FillExtrusionLayerNode(
      specLayer: specLayer as spec.LayerFillExtrusion,
      preprocessedLayer: preprocessedLayer,
    ),
    spec.Layer$Type.line => LineLayerNode(
      specLayer: specLayer as spec.LayerLine,
      preprocessedLayer: preprocessedLayer,
    ),
    spec.Layer$Type.symbol => SymbolLayerNode(
      specLayer: specLayer as spec.LayerSymbol,
      preprocessedLayer: preprocessedLayer,
    ),
    _ => throw UnsupportedError('Unsupported layer type: ${specLayer.type}, id: ${specLayer.id}'),
  };
}
