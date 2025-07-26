import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:granite/renderer/isolates/isolates.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;

typedef TArg = ({
  spec.EvaluationContext evalContext,
  spec.Style style,
  List<PreprocessedLayer> preprocessedLayers,
  TransferableTypedData vtData,
});

typedef TReturn = List<GeometryData?>;

class LayerTileGeometryWorkerIsolate extends WorkerIsolate<TArg, TReturn> {
  LayerTileGeometryWorkerIsolate(super.name, super.commands, super.responses);

  static Future<LayerTileGeometryWorkerIsolate> spawn() {
    return WorkerIsolate.spawnWrapper(
      startRemoteIsolate,
      LayerTileGeometryWorkerIsolate.new,
    );
  }

  static void startRemoteIsolate(SendPort sendPort) {
    return WorkerIsolate.startRemoteIsolateWrapper(sendPort, work);
  }

  static TReturn work(TArg arg) {
    final result = <GeometryData?>[];
    final vtTile = vt.decodeTileFromBytes(arg.vtData.materialize().asUint8List());

    for (final preprocessedLayer in arg.preprocessedLayers) {
      final specLayer = arg.style.layers.firstWhereOrNull((l) => l.id == preprocessedLayer.id);
      if (specLayer == null) {
        result.add(null);
        continue;
      }

      final vtLayer = vtTile.layers.firstWhereOrNull((l) => l.name == specLayer.sourceLayer);
      if (vtLayer == null) {
        result.add(null);
        continue;
      }

      final vertexProps = VertexProps(instructions: preprocessedLayer.vertexPropInstructions);

      if (specLayer.type == spec.Layer$Type.fill) {
        result.add(
          FillLayerTileGeometry.prepareGeometry(
            evalContext: arg.evalContext,
            specLayer: specLayer as spec.LayerFill,
            vtLayer: vtLayer,
            vertexProps: vertexProps,
          ),
        );
      } else if (specLayer.type == spec.Layer$Type.line) {
        result.add(
          LineLayerTileGeometry.prepareGeometry(
            evalContext: arg.evalContext,
            specLayer: specLayer as spec.LayerLine,
            vtLayer: vtLayer,
            vertexProps: vertexProps,
          ),
        );
      } else if (specLayer.type == spec.Layer$Type.fillExtrusion) {
        result.add(
          FillExtrusionLayerTileGeometry.prepareGeometry(
            evalContext: arg.evalContext,
            specLayer: specLayer as spec.LayerFillExtrusion,
            vtLayer: vtLayer,
            vertexProps: vertexProps,
          ),
        );
      } else {
        result.add(null);
      }
    }

    return result;
  }
}

class LayerTileGeometryWorkerIsolatePool extends WorkerIsolatePool<TArg, TReturn, LayerTileGeometryWorkerIsolate> {
  LayerTileGeometryWorkerIsolatePool(int size) : super(size, LayerTileGeometryWorkerIsolate.spawn);
}
