import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/core/gpu/customizable_surface.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/shaders/texture.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/renderer/utils/filter_features.dart';
import 'package:granite/renderer/utils/tessellator.dart';
import 'package:granite/renderer/utils/vt_utils.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

final class FillExtrusionLayerNode extends LayerNode<spec.LayerFillExtrusion> {
  FillExtrusionLayerNode({required super.specLayer, required super.preprocessedLayer});

  final _surface = CustomizableSurface();

  @override
  LayerTileNode createLayerTileNode(TileCoordinates coordinates, vt.Layer vtLayer) =>
      FillExtrusionLayerTileNode(coordinates: coordinates, vtLayer: vtLayer);

  @override
  void render(scene.SceneEncoder encoder, vm.Matrix4 parentWorldTransform) {
    super.render(encoder, parentWorldTransform);
    return;

    // if (renderer.isShadowPass) {}

    // final renderTarget = _surface.getNextRenderTarget(encoder.dimensions, true);

    // // TODO: Do this in the same encoder and command buffer.
    // final offscreenEncoder = scene.SceneEncoder(renderTarget, encoder.camera, encoder.dimensions, encoder.environment);

    // super.render(offscreenEncoder, parentWorldTransform);
    // offscreenEncoder.finish();

    // final opacity = specLayer.paint.fillExtrusionOpacity.evaluate(renderer.baseEvaluationContext).toDouble();
    // encoder.encode(
    //   parentWorldTransform,
    //   TextureGeometry(renderer: renderer),
    //   TextureMaterial(
    //     renderer: renderer,
    //     texture: renderTarget.colorAttachments.first.resolveTexture!,
    //     opacity: opacity,
    //   ),
    // );
  }
}

final class FillExtrusionLayerTileNode extends LayerTileNode<spec.LayerFillExtrusion, FillExtrusionLayerNode> {
  FillExtrusionLayerTileNode({required super.coordinates, required super.vtLayer});

  @override
  void setGeometryAndMaterial() {
    geometry = FillExtrusionLayerTileGeometry(node: this);
    material = FillExtrusionLayerTileMaterial(node: this);
  }
}

final class FillExtrusionLayerTileGeometry extends LayerTileGeometry<FillExtrusionLayerTileNode> {
  FillExtrusionLayerTileGeometry({required super.node});

  @override
  Future<void> prepare() async {
    final evalContext = renderer.baseEvaluationContext.copyWithZoom(node.coordinates.z.toDouble());
    final features = filterFeatures<vt.PolygonFeature>(
      node.vtLayer,
      node.specLayer,
      evalContext,
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

    const staticBytesPerVertex = 24;
    final bytesPerVertex = staticBytesPerVertex + vertexProps.lengthInBytes;
    final vertexData = ByteData(6 * bytesPerVertex * vertexCount);
    void setVertex(
      int index, {
      required vm.Vector3 position,
      required vm.Vector3 normal,
    }) {
      var offset = index * bytesPerVertex;
      offset = vertexData.setVec3(offset, position);
      offset = vertexData.setVec3(offset, normal);
      offset = vertexData.setByteData(offset, vertexProps.data);
    }

    var vertexIndex = 0;
    for (final feature in features) {
      vertexProps.compute(evalContext.forFeature(feature), node.specLayer);
      final polygons = feature.polygons;

      for (final polygon in polygons) {
        final indices = Tessellator.tessellatePolygon(polygon);

        final _vertices = polygon.vertices.map((o) => vm.Vector3(o.x, o.y, 0.0)).toList();

        // create base vertices
        indicesList.addAll(indices.map((i) => i + vertexIndex));
        indicesList.addAll(indices.map((i) => i + _vertices.length + vertexIndex));
        for (var i = 0; i < _vertices.length; i++) {
          final vertex = _vertices[i];
          setVertex(vertexIndex, position: vertex, normal: vm.Vector3(0.0, 0.0, -1.0));
          vertexIndex++;
        }

        // create top vertices
        for (var i = 0; i < _vertices.length; i++) {
          final vertex = _vertices[i];
          setVertex(vertexIndex, position: vm.Vector3(vertex.x, vertex.y, 1.0), normal: vm.Vector3(0.0, 0.0, 1.0));
          vertexIndex++;
        }

        // create walls
        for (final ring in [polygon.exterior, ...polygon.interiors]) {
          final vertices = ring.points.map((o) => vm.Vector3(o.x, o.y, 0.0)).toList();

          for (var i = 0; i < ring.points.length; i++) {
            final startIdx = i % vertices.length;
            final endIdx = (i + 1) % vertices.length;
            final startVtx = vertices[startIdx];
            final endVtx = vertices[endIdx];

            final tangent = endVtx - startVtx;
            final normal = vm.Vector3(-tangent.y, tangent.x, 0.0).normalized();

            // create verts
            setVertex(
              vertexIndex,
              position: vm.Vector3(startVtx.x, startVtx.y, 0.0),
              normal: normal,
            );
            setVertex(
              vertexIndex + 1,
              position: vm.Vector3(endVtx.x, endVtx.y, 0.0),
              normal: normal,
            );
            setVertex(
              vertexIndex + 2,
              position: vm.Vector3(endVtx.x, endVtx.y, 1.0),
              normal: normal,
            );
            setVertex(
              vertexIndex + 3,
              position: vm.Vector3(startVtx.x, startVtx.y, 1.0),
              normal: normal,
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

    uploadVertexData(
      vertexData,
      vertexCount,
      Uint32List.fromList(indicesList).buffer.asByteData(),
      indexType: gpu.IndexType.int32,
    );
  }
}

final class FillExtrusionLayerTileMaterial extends LayerTileMaterial<FillExtrusionLayerTileNode> {
  FillExtrusionLayerTileMaterial({required super.node});

  @override
  void bind(gpu.RenderPass pass, gpu.HostBuffer transientsBuffer, scene.Environment environment) {
    super.bind(pass, transientsBuffer, environment);

    pass.setDepthCompareOperation(gpu.CompareFunction.lessEqual);
    pass.setDepthWriteEnable(true);
  }
}
