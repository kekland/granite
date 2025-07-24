import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:granite/renderer/core/props/uniform_props.dart';
import 'package:granite/renderer/core/props/vertex_props.dart';
import 'package:granite/renderer/core/tile_layer_geometry.dart';
import 'package:granite/renderer/core/tile_layer_node.dart';
import 'package:granite/renderer/core/ubos/tile_ubo.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/renderer/utils/filter_features.dart';
import 'package:granite/renderer/utils/tessellator.dart';
import 'package:granite/renderer/utils/vt_utils.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math.dart' as vm;
import 'package:vector_math/vector_math_64.dart';

final class FillTileLayerNode extends TileLayerNode<spec.LayerFill> {
  FillTileLayerNode({
    required super.renderer,
    required super.specLayer,
    required super.vtLayer,
    required gpu.Shader vertexShader,
    required gpu.Shader fragmentShader,
    required UniformProps uniformProps,
    required VertexProps vertexProps,
  }) : super(
         geometry: FillTileLayerGeometry(
           renderer: renderer,
           specLayer: specLayer,
           vtLayer: vtLayer,
           vertexShader: vertexShader,
           fragmentShader: fragmentShader,
           uniformProps: uniformProps,
           vertexProps: vertexProps,
         ),
       );
}

class FillTileLayerGeometry extends TileLayerGeometry<spec.LayerFill> {
  FillTileLayerGeometry({
    required super.renderer,
    required super.specLayer,
    required super.vtLayer,
    required super.vertexShader,
    required super.fragmentShader,
    required super.uniformProps,
    required super.vertexProps,
  }) : super(staticBytesPerVertex: 8, ubos: [TileUbo()]);

  @override
  Future<void> prepare() async {
    final features = filterFeatures<vt.PolygonFeature>(
      vtLayer,
      specLayer,
      renderer.prepareEvalContext,
      sortKey: specLayer.layout.fillSortKey,
    );

    if (features.isEmpty) {
      allocateVertices(1);
      allocateIndices(Uint32List(1));
      upload();
      return;
    }

    var vertexCount = 0;
    final indicesList = <int>[];

    for (final feature in features) {
      for (final polygon in feature.polygons) vertexCount += polygon.vertexCount;
    }

    // Allocate vertices
    allocateVertices(vertexCount);

    var vertexIndex = 0;
    for (final feature in features) {
      vertexProps.compute(renderer.prepareEvalContext.forFeature(feature), specLayer);
      final polygons = feature.polygons;

      for (final polygon in polygons) {
        final indices = Tessellator.tessellatePolygon(polygon);
        indicesList.addAll(indices.map((i) => i + vertexIndex));

        for (final vertex in polygon.vertices) {
          setVertex(vertexIndex, position: Vector2(vertex.dx, vertex.dy));
          vertexIndex++;
        }
      }
    }

    allocateIndices(Uint32List.fromList(indicesList));
    upload();
  }

  void setVertex(int index, {required Vector2 position}) {
    var offset = index * bytesPerVertex;
    offset = vertexData!.setVec2(offset, position);
    offset = vertexData!.setByteData(offset, vertexProps.data);
  }

  @override
  void bind(
    gpu.RenderPass pass,
    gpu.HostBuffer transientsBuffer,
    vm.Matrix4 modelTransform,
    vm.Matrix4 cameraTransform,
    vm.Vector3 cameraPosition,
  ) {
    super.bind(pass, transientsBuffer, modelTransform, cameraTransform, cameraPosition);
    pass.setDepthWriteEnable(false);
    pass.setDepthCompareOperation(gpu.CompareFunction.always);
  }
}
