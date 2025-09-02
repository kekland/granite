import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/core/gpu/uniform_utils.dart';

import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/layer.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

vm.Matrix4 _getLayerTileTransform(TileCoordinates c, double zoom) {
  final worldTileSize = RendererNode.kTileSize * pow(2, (zoom - c.z));

  final translated = vm.Matrix4.identity()
    ..translateByDouble(c.x.toDouble() * worldTileSize, c.y.toDouble() * worldTileSize, 0.0, 1.0);

  final scale2 = worldTileSize / RendererNode.kTileExtent;
  final scaled2 = vm.Matrix4.identity()..scaleByDouble(scale2, scale2, scale2, 1.0);

  return translated * scaled2;
}

abstract base class LayerTileNode<TSpec extends spec.Layer, TLayer extends LayerNode> extends scene.Node
    with RendererDescendantNode {
  LayerTileNode({
    required this.coordinates,
    required this.geometryData,
    this.vtLayer,
  }) : super();

  final TileCoordinates coordinates;
  final GeometryData? geometryData;
  final vt.Layer? vtLayer;
  late final int stencilRef;
  late final LayerTileGeometry geometry;
  late final LayerTileMaterial material;

  TSpec get specLayer => parent.specLayer as TSpec;

  @override
  TLayer get parent => super.parent as TLayer;

  var _hasStencilRef = false;
  void getStencilRef() {
    if (_hasStencilRef) return;
    stencilRef = renderer.getTileStencilRef(coordinates);
    _hasStencilRef = true;
  }

  void setGeometryAndMaterial();

  bool get isClipped => true;

  @override
  void render(scene.SceneEncoder encoder, vm.Matrix4 parentWorldTransform) {
    getStencilRef();
    geometry.maybePrepare();
    if (!geometry.isReady || !visible || geometry.isEmpty) return;

    localTransform = _getLayerTileTransform(coordinates, renderer.baseEvaluationContext.zoom);

    final modelTransform = parentWorldTransform * localTransform;
    final cameraTransform = encoder.cameraTransform;
    final cameraPosition = encoder.camera.position;

    // [0 - width; 0 - height] -> [-1.0 - 1.0; -1.0 - 1.0]
    final screenDimensions = encoder.dimensions / 2.0;
    final screenToClipTransform = vm.Matrix4.identity()
      ..translateByDouble(-screenDimensions.width / 2.0, -screenDimensions.height / 2.0, 0.0, 1.0)
      ..scaleByDouble(2.0 / screenDimensions.width, -2.0 / screenDimensions.height, 1.0, 1.0);

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
    final tileSize = RendererNode.kTileSize * pow(1.33, (zoom - coordinates.z)).toDouble();
    final unitsPerPixel = 4096.0 / tileSize;

    final vertexShaderSlot = geometry.vertexShader.getUniformSlot('TileInfo');
    final fragmentShaderSlot = material.fragmentShader.getUniformSlot('TileInfo');
    final slot = fragmentShaderSlot.sizeInBytes != null ? fragmentShaderSlot : vertexShaderSlot;

    // mat4, mat4, mat4 vec3, vec3
    final tileInfoData = ByteData(272 + 64 + 64 + 64);
    tileInfoData.setMat4(getUniformMemberOffset(slot, 'mvp')!, cameraTransform * modelTransform);
    tileInfoData.setMat4(getUniformMemberOffset(slot, 'camera_transform')!, cameraTransform);
    tileInfoData.setMat4(getUniformMemberOffset(slot, 'model_transform')!, modelTransform);
    tileInfoData.setVec3(getUniformMemberOffset(slot, 'camera_position')!, cameraPosition);
    tileInfoData.setMat4(getUniformMemberOffset(slot, 'screen_to_clip_transform')!, screenToClipTransform);
    tileInfoData.setMat4(
      getUniformMemberOffset(slot, 'clip_to_screen_transform')!,
      screenToClipTransform.clone()..invert(),
    );

    tileInfoData.setVec3(getUniformMemberOffset(slot, 'light_direction')!, lightDirection);
    tileInfoData.setFloat(getUniformMemberOffset(slot, 'light_intensity')!, lightIntensity.toDouble());
    tileInfoData.setVec4(getUniformMemberOffset(slot, 'light_color')!, lightColor.vec);
    tileInfoData.setMat4(getUniformMemberOffset(slot, 'light_mvp')!, renderer.lightCameraVp * localTransform);
    tileInfoData.setFloat(getUniformMemberOffset(slot, 'units_per_pixel')!, unitsPerPixel);
    tileInfoData.setFloat(getUniformMemberOffset(slot, 'zoom')!, zoom);
    final view = encoder.transientsBuffer.emplace(tileInfoData);

    if (vertexShaderSlot.sizeInBytes != null) encoder.renderPass.bindUniform(vertexShaderSlot, view);
    if (fragmentShaderSlot.sizeInBytes != null) encoder.renderPass.bindUniform(fragmentShaderSlot, view);

    if (isClipped && !renderer.isShadowPass) {
      // if (false) {
      encoder.renderPass.setStencilReference(stencilRef);
      encoder.renderPass.setStencilConfig(
        gpu.StencilConfig(
          compareFunction: gpu.CompareFunction.equal,
          depthStencilPassOperation: gpu.StencilOperation.keep,
          readMask: 0xFF,
          writeMask: 0xFF,
        ),
      );
    } else {
      encoder.renderPass.setStencilConfig(
        gpu.StencilConfig(
          compareFunction: gpu.CompareFunction.always,
          depthStencilPassOperation: gpu.StencilOperation.keep,
          readMask: 0xFF,
          writeMask: 0xFF,
        ),
      );
    }

    encoder.encodePreservePipeline(parentWorldTransform * localTransform, geometry, material);
  }
}
