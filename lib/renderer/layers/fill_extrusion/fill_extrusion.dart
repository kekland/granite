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

final class FillExtrusionTileLayerNode extends TileLayerNode<spec.LayerFillExtrusion> {
  FillExtrusionTileLayerNode({
    required super.renderer,
    required super.specLayer,
    required super.vtLayer,
    required gpu.Shader vertexShader,
    required gpu.Shader fragmentShader,
    required UniformProps uniformProps,
    required VertexProps vertexProps,
  }) : super(
         geometry: FillExtrusionTileLayerGeometry(
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

class FillExtrusionTileLayerGeometry extends TileLayerGeometry<spec.LayerFillExtrusion> {
  FillExtrusionTileLayerGeometry({
    required super.renderer,
    required super.specLayer,
    required super.vtLayer,
    required super.vertexShader,
    required super.fragmentShader,
    required super.uniformProps,
    required super.vertexProps,
  }) : super(staticBytesPerVertex: 24, ubos: [TileUbo()]);

  @override
  Future<void> prepare() async {
    final features = filterFeatures<vt.PolygonFeature>(
      vtLayer,
      specLayer,
      renderer.prepareEvalContext,
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
    allocateVertices(vertexCount * 6);

    var vertexIndex = 0;
    for (final feature in features) {
      vertexProps.compute(renderer.prepareEvalContext.forFeature(feature), specLayer);
      final polygons = feature.polygons;

      for (final polygon in polygons) {
        final indices = Tessellator.tessellatePolygon(polygon);

        final _vertices = polygon.vertices.map((o) => Vector3(o.dx, o.dy, 0.0)).toList();

        // create base vertices
        indicesList.addAll(indices.map((i) => i + vertexIndex));
        indicesList.addAll(indices.map((i) => i + _vertices.length + vertexIndex));
        for (var i = 0; i < _vertices.length; i++) {
          final vertex = _vertices[i];
          setVertex(vertexIndex, position: Vector3(vertex.x, vertex.y, 0.0), normal: Vector3(0.0, 0.0, -1.0));
          vertexIndex++;
        }

        // create top vertices
        for (var i = 0; i < _vertices.length; i++) {
          final vertex = _vertices[i];
          setVertex(vertexIndex, position: Vector3(vertex.x, vertex.y, 1.0), normal: Vector3(0.0, 0.0, 1.0));
          vertexIndex++;
        }

        for (final ring in [polygon.exterior, ...polygon.interiors]) {
          final vertices = ring.points.map((o) => Vector3(o.dx, o.dy, 0.0)).toList();

          for (var i = 0; i < ring.points.length; i++) {
            final startIdx = i % vertices.length;
            final endIdx = (i + 1) % vertices.length;
            final startVtx = vertices[startIdx];
            final endVtx = vertices[endIdx];

            final tangent = endVtx - startVtx;
            final normal = Vector3(-tangent.y, tangent.x, 0.0).normalized();

            // create verts
            setVertex(
              vertexIndex,
              position: Vector3(startVtx.x, startVtx.y, 0.0),
              normal: Vector3(normal.x, normal.y, 0.0),
            );
            setVertex(
              vertexIndex + 1,
              position: Vector3(endVtx.x, endVtx.y, 0.0),
              normal: Vector3(normal.x, normal.y, 0.0),
            );
            setVertex(
              vertexIndex + 2,
              position: Vector3(endVtx.x, endVtx.y, 1.0),
              normal: Vector3(normal.x, normal.y, 0.0),
            );
            setVertex(
              vertexIndex + 3,
              position: Vector3(startVtx.x, startVtx.y, 1.0),
              normal: Vector3(normal.x, normal.y, 0.0),
            );

            // create indices
            indicesList.addAll([
              vertexIndex,
              vertexIndex + 1,
              vertexIndex + 2,
              vertexIndex,
              vertexIndex + 2,
              vertexIndex + 3,
            ]);

            vertexIndex += 4;
          }
        }
      }
    }

    allocateIndices(Uint32List.fromList(indicesList));
    upload();
  }

  void setVertex(
    int index, {
    required Vector3 position,
    required Vector3 normal,
  }) {
    var offset = index * bytesPerVertex;
    offset = vertexData!.setVec3(offset, position);
    offset = vertexData!.setVec3(offset, normal);
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

    pass.setDepthWriteEnable(true);
    pass.setDepthCompareOperation(gpu.CompareFunction.lessEqual);
  }
}
