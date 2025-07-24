import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/core/scene/lol.dart';

import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

vm.Matrix4 _getLayerTileTransform(TileCoordinates c, int extent, double zoom) {
  final tileSize = RendererNode.kTileSize * pow(2, (zoom - c.z)).toDouble();

  final translated = vm.Matrix4.identity()..translate(c.x.toDouble() * tileSize, c.y.toDouble() * tileSize, 0.0);

  final scale2 = tileSize / extent;
  final scaled2 = vm.Matrix4.identity()..scaleByDouble(scale2, scale2, scale2, 1.0);

  return translated * scaled2;
}

abstract base class LayerTileNode<TSpec extends spec.Layer, TLayer extends LayerNode> extends scene.Node
    with RendererDescendantNode, Preparable {
  LayerTileNode({
    required this.coordinates,
    required this.vtLayer,
  }) : super(name: '${vtLayer.name} $coordinates');

  final TileCoordinates coordinates;
  final vt.Layer vtLayer;
  late final LayerTileGeometry geometry;
  late final LayerTileMaterial material;

  TSpec get specLayer => parent.specLayer as TSpec;

  @override
  TLayer get parent => super.parent as TLayer;

  void setGeometryAndMaterial();

  @override
  Future<void> prepareImpl() async {
    setGeometryAndMaterial();
    await [geometry.prepare(), material.prepare()].wait;
  }

  @override
  void render(scene.SceneEncoder encoder, vm.Matrix4 parentWorldTransform) {
    if (!visible || !isReady || geometry.isEmpty) return;
    localTransform = _getLayerTileTransform(coordinates, vtLayer.extent, renderer.baseEvaluationContext.zoom);

    final modelTransform = parentWorldTransform * localTransform;
    final cameraTransform = encoder.cameraTransform;
    final cameraPosition = encoder.camera.position;

    // Compute light
    final light = renderer.style.light ?? spec.Light.withDefaults();
    final lightPosition = light.position.evaluate(renderer.baseEvaluationContext);
    final lightIntensity = light.intensity.evaluate(renderer.baseEvaluationContext);
    final lightColor = light.color.evaluate(renderer.baseEvaluationContext);

    final a = lightPosition.y * vm.degrees2Radians;
    final p = lightPosition.z * vm.degrees2Radians;
    final lightDirection = vm.Vector3(cos(a) * sin(p), sin(a) * sin(p), cos(p));

    // Compute other stuff
    final zoom = renderer.baseEvaluationContext.zoom;
    final tileSize = RendererNode.kTileSize * pow(2, (zoom - coordinates.z)).toDouble();
    final unitsPerPixel = 4096.0 / tileSize;

    // mat4, mat4, mat4 vec3, vec3
    final tileInfoData = ByteData(272);
    var offset = 0;
    offset = tileInfoData.setMat4(offset, cameraTransform * modelTransform);
    offset = tileInfoData.setMat4(offset, cameraTransform);
    offset = tileInfoData.setMat4(offset, modelTransform);
    offset = tileInfoData.setVec3(offset, cameraPosition);
    offset += 0;
    offset = tileInfoData.setVec3(offset, lightDirection);
    offset += 0;
    offset = tileInfoData.setFloat(offset, lightIntensity.toDouble());
    offset += 0;
    offset = tileInfoData.setVec4(offset, lightColor.vec);
    offset += 4;
    offset = tileInfoData.setFloat(offset, unitsPerPixel);
    offset = tileInfoData.setFloat(offset, zoom);
    final view = encoder.transientsBuffer.emplace(tileInfoData);

    final vertexShaderSlot = geometry.vertexShader.getUniformSlot('TileInfo');
    final fragmentShaderSlot = material.fragmentShader.getUniformSlot('TileInfo');
    if (vertexShaderSlot.sizeInBytes != null) encoder.renderPass.bindUniform(vertexShaderSlot, view);
    if (fragmentShaderSlot.sizeInBytes != null) encoder.renderPass.bindUniform(fragmentShaderSlot, view);

    encoder.encodePreservePipeline(parentWorldTransform * localTransform, geometry, material);
  }
}
