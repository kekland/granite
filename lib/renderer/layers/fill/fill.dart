import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/renderer/utils/filter_features.dart';
import 'package:granite/renderer/utils/tessellator.dart';
import 'package:granite/renderer/utils/vt_utils.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

final class FillLayerNode extends LayerNode<spec.LayerFill> {
  FillLayerNode({required super.specLayer, required super.preprocessedLayer});

  @override
  LayerTileNode createLayerTileNode(TileCoordinates coordinates, vt.Layer vtLayer) =>
      FillLayerTileNode(coordinates: coordinates, vtLayer: vtLayer);
}

final class FillLayerTileNode extends LayerTileNode<spec.LayerFill, FillLayerNode> {
  FillLayerTileNode({required super.coordinates, required super.vtLayer});

  @override
  void setGeometryAndMaterial() {
    geometry = FillLayerTileGeometry(node: this);
    material = FillLayerTileMaterial(node: this);
  }
}

final class FillLayerTileGeometry extends LayerTileGeometry<FillLayerTileNode> {
  FillLayerTileGeometry({required super.node});

  @override
  Future<void> prepare() async {
    final evalContext = renderer.baseEvaluationContext.copyWithZoom(node.coordinates.z.toDouble());
    final features = filterFeatures<vt.PolygonFeature>(
      node.vtLayer,
      node.specLayer,
      evalContext,
      sortKey: node.specLayer.layout.fillSortKey,
    );

    var vertexCount = 0;
    final indicesList = <int>[];

    for (final feature in features) {
      for (final polygon in feature.polygons) vertexCount += polygon.vertexCount;
    }

    if (vertexCount == 0) {
      isEmpty = true;
      return;
    }

    const staticBytesPerVertex = 8;
    final bytesPerVertex = staticBytesPerVertex + vertexProps.lengthInBytes;
    final vertexData = ByteData(vertexCount * bytesPerVertex);

    void setVertex(int index, {required vm.Vector2 position}) {
      var offset = index * bytesPerVertex;
      offset = vertexData.setVec2(offset, position);
      offset = vertexData.setByteData(offset, vertexProps.data);
    }

    var vertexIndex = 0;
    for (final feature in features) {
      vertexProps.compute(evalContext.forFeature(feature), node.specLayer);
      final polygons = feature.polygons;

      for (final polygon in polygons) {
        final indices = Tessellator.tessellatePolygon(polygon);
        indicesList.addAll(indices.map((i) => i + vertexIndex));

        for (final vertex in polygon.vertices) {
          setVertex(vertexIndex, position: vertex);
          vertexIndex++;
        }
      }
    }

    uploadVertexData(
      vertexData,
      vertexCount,
      Uint32List.fromList(indicesList).buffer.asByteData(),
      indexType: gpu.IndexType.int32,
    );
  }
}

final class FillLayerTileMaterial extends LayerTileMaterial<FillLayerTileNode> {
  FillLayerTileMaterial({required super.node});

  @override
  void bind(gpu.RenderPass pass, gpu.HostBuffer transientsBuffer, scene.Environment environment) {
    super.bind(pass, transientsBuffer, environment);
    pass.setDepthWriteEnable(true);
    pass.setDepthCompareOperation(gpu.CompareFunction.always);
  }
}
