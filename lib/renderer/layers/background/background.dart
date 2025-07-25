import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

final class BackgroundLayerNode extends LayerNode<spec.LayerBackground> {
  BackgroundLayerNode({required super.specLayer, required super.preprocessedLayer});

  @override
  void addTile(TileCoordinates coordinates, vt.Tile tile) {
    // Background layer does not use vector tile data, so we can just pass an empty layer.
    final layerTileNode = createLayerTileNode(coordinates, vt.Layer.empty);
    add(layerTileNode);
  }

  @override
  LayerTileNode createLayerTileNode(TileCoordinates coordinates, vt.Layer vtLayer) =>
      BackgroundLayerTileNode(coordinates: coordinates, vtLayer: vtLayer);
}

final class BackgroundLayerTileNode extends LayerTileNode<spec.LayerBackground, BackgroundLayerNode> {
  BackgroundLayerTileNode({required super.coordinates, required super.vtLayer});

  @override
  void setGeometryAndMaterial() {
    geometry = BackgroundLayerTileGeometry(node: this);
    material = BackgroundLayerTileMaterial(node: this);
  }
}

final class BackgroundLayerTileGeometry extends LayerTileGeometry<BackgroundLayerTileNode> {
  BackgroundLayerTileGeometry({required super.node});

  @override
  Future<void> prepare() async {
    const staticBytesPerVertex = 8;
    final bytesPerVertex = staticBytesPerVertex + vertexProps.lengthInBytes;

    final evalContext = renderer.baseEvaluationContext.copyWithZoom(node.coordinates.z.toDouble());
    vertexProps.compute(evalContext, node.specLayer);

    final vertexData = ByteData(4 * bytesPerVertex);
    void setVertex(int index, {required vm.Vector2 position}) {
      var offset = index * bytesPerVertex;
      offset = vertexData.setVec2(offset, position);
      offset = vertexData.setByteData(offset, vertexProps.data);
    }

    setVertex(0, position: vm.Vector2(0.0, 0.0));
    setVertex(1, position: vm.Vector2(1.0, 0.0));
    setVertex(2, position: vm.Vector2(1.0, 1.0));
    setVertex(3, position: vm.Vector2(0.0, 1.0));

    uploadVertexData(
      vertexData,
      4,
      Uint16List.fromList(const [0, 1, 2, 0, 2, 3]).buffer.asByteData(),
      indexType: gpu.IndexType.int16,
    );
  }
}

final class BackgroundLayerTileMaterial extends LayerTileMaterial<BackgroundLayerTileNode> {
  BackgroundLayerTileMaterial({required super.node});

  @override
  void bind(gpu.RenderPass pass, gpu.HostBuffer transientsBuffer, scene.Environment environment) {
    super.bind(pass, transientsBuffer, environment);
    pass.setDepthWriteEnable(true);
    pass.setDepthCompareOperation(gpu.CompareFunction.always);
  }
}
