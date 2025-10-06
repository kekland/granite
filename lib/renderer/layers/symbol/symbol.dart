import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/layers/symbol/layout/symbol_layout_engine.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/renderer/utils/filter_features.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

final class SymbolLayerNode extends LayerNode<spec.LayerSymbol> {
  SymbolLayerNode({required super.specLayer, required super.preprocessedLayer});

  @override
  LayerTileNode createLayerTileNode(TileCoordinates coordinates, GeometryData? geometryData, vt.Layer? vtLayer) =>
      SymbolLayerTileNode(coordinates: coordinates, geometryData: geometryData, vtLayer: vtLayer);
}

final class SymbolLayerTileNode extends LayerTileNode<spec.LayerSymbol, SymbolLayerNode> {
  SymbolLayerTileNode({required super.coordinates, required super.geometryData, required super.vtLayer});

  @override
  void setGeometryAndMaterial() {
    geometry = SymbolLayerTileGeometry(node: this);
    material = SymbolLayerTileMaterial(node: this);
  }

  // @override
  // void render(scene.SceneEncoder encoder, vm.Matrix4 parentWorldTransform) {
  //   super.render(encoder, parentWorldTransform);
  // }
}

base class SymbolLayerTileGeometry extends LayerTileGeometry<SymbolLayerTileNode> {
  SymbolLayerTileGeometry({required super.node});

  @override
  Future<void> prepare() async {
    final evalContext = renderer.baseEvaluationContext.copyWithZoom(node.coordinates.z.toDouble());

    final layout = node.specLayer.layout;
    final placement = layout.symbolPlacement.evaluate(evalContext);
    final allowedFeatureTypes = switch (placement) {
      spec.LayoutSymbol$SymbolPlacement.point => const [vt.PointFeature],
      // spec.LayoutSymbol$SymbolPlacement.point => const [vt.PointFeature, vt.LineStringFeature, vt.PolygonFeature],
      // spec.LayoutSymbol$SymbolPlacement.line => const [vt.LineStringFeature, vt.PolygonFeature],
      // spec.LayoutSymbol$SymbolPlacement.lineCenter => const [vt.LineStringFeature, vt.PolygonFeature],
      _ => null,
    };

    if (node.vtLayer == null || allowedFeatureTypes == null) {
      isEmpty = true;
      return;
    }

    final features = filterFeatures(
      node.vtLayer!,
      node.specLayer,
      evalContext,
      sortKey: node.specLayer.layout.symbolSortKey,
      allowedFeatures: allowedFeatureTypes,
    );

    var vertexCount = 0;
    var indexCount = 0;
    final placements = <List<SymbolPlacement>>[];
    for (final feature in features) {
      final featurePlacements = await SymbolLayoutEngine.performLayout(
        renderer: renderer,
        evalContext: evalContext.forFeature(feature),
        layout: layout,
        feature: feature,
      );

      for (final placement in featurePlacements) {
        // Each glyph has 4 vertices and 6 indices.
        vertexCount += placement.glyphs.length * 4;
        indexCount += placement.glyphs.length * 6;
      }

      placements.add(featurePlacements);
    }

    if (vertexCount == 0) {
      isEmpty = true;
      return;
    }

    const staticBytesPerVertex = 24;
    final bytesPerVertex = staticBytesPerVertex + vertexProps.lengthInBytes;
    final vertexBuffer = ByteData(bytesPerVertex * vertexCount);
    final indexBuffer = Uint32List(indexCount);

    void setVertex(
      int index, {
      required vm.Vector2 position,
      required vm.Vector2 anchor,
      required vm.Vector2 uv,
    }) {
      var offset = index * bytesPerVertex;
      offset = vertexBuffer.setVec2(offset, position);
      offset = vertexBuffer.setVec2(offset, anchor);
      offset = vertexBuffer.setVec2(offset, uv);
      offset = vertexBuffer.setByteData(offset, vertexProps.data);
    }

    var vertexIndex = 0;
    for (var i = 0; i < placements.length; i++) {
      final featurePlacements = placements[i];
      if (featurePlacements.isEmpty) continue;

      final feature = features[i];
      final eval = evalContext.forFeature(feature);
      vertexProps.compute(eval, node.specLayer);

      for (final placement in featurePlacements) {
        for (final glyph in placement.glyphs) {
          final topLeft = glyph.position;
          final topRight = topLeft + vm.Vector2(glyph.width, 0.0);
          final bottomLeft = topLeft + vm.Vector2(0.0, glyph.height);
          final bottomRight = topLeft + vm.Vector2(glyph.width, glyph.height);

          final topLeftUv = glyph.uv.$1;
          final topRightUv = vm.Vector2(glyph.uv.$2.x, glyph.uv.$1.y);
          final bottomLeftUv = vm.Vector2(glyph.uv.$1.x, glyph.uv.$2.y);
          final bottomRightUv = glyph.uv.$2;

          setVertex(vertexIndex++, position: topLeft, anchor: placement.anchor, uv: topLeftUv);
          setVertex(vertexIndex++, position: topRight, anchor: placement.anchor, uv: topRightUv);
          setVertex(vertexIndex++, position: bottomLeft, anchor: placement.anchor, uv: bottomLeftUv);
          setVertex(vertexIndex++, position: bottomRight, anchor: placement.anchor, uv: bottomRightUv);
        }
      }
    }

    for (var i = 0; i < indexCount; i += 6) {
      final b = i ~/ 6 * 4;
      indexBuffer[i] = b;
      indexBuffer[i + 1] = b + 1;
      indexBuffer[i + 2] = b + 2;
      indexBuffer[i + 3] = b + 1;
      indexBuffer[i + 4] = b + 3;
      indexBuffer[i + 5] = b + 2;
    }

    print('uploaded vtx data: ${vertexCount} vertices');
    uploadVertexData(
      vertexBuffer,
      vertexCount,
      indexBuffer.buffer.asByteData(),
      indexType: gpu.IndexType.int32,
    );
  }
}

base class SymbolLayerTileMaterial extends LayerTileMaterial<SymbolLayerTileNode> {
  SymbolLayerTileMaterial({required super.node});

  @override
  bool get usesShadowMap => false;

  @override
  void bind(gpu.RenderPass pass, gpu.HostBuffer transientsBuffer, scene.Environment environment) {
    super.bind(pass, transientsBuffer, environment);
    pass.setDepthWriteEnable(false);
    pass.setDepthCompareOperation(gpu.CompareFunction.always);
    pass.setCullMode(gpu.CullMode.none);

    pass.bindTexture(
      fragmentShader.getUniformSlot('u_glyph_atlas_texture'),
      node.renderer.glyphAtlas.texture,
    );
  }
}
