import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

vm.Matrix4 _getTileStencilTransform(TileCoordinates c, double zoom) {
  final worldTileSize = RendererNode.kTileSize * pow(2, (zoom - c.z)).toDouble();

  final translated = vm.Matrix4.identity()
    ..translateByDouble(c.x.toDouble() * worldTileSize, c.y.toDouble() * worldTileSize, 0.0, 1.0);

  final scale2 = worldTileSize * 1.0;
  final scaled2 = vm.Matrix4.identity()..scaleByDouble(scale2, scale2, scale2, 1.0);

  return translated * scaled2;
}

base class TileStencilNode extends scene.Node {
  TileStencilNode({required this.renderer, required this.coordinates})
    : super(
        localTransform: _getTileStencilTransform(coordinates, renderer.baseEvaluationContext.zoom),
        mesh: scene.Mesh(
          TileStencilGeometry(renderer: renderer, coordinates: coordinates),
          TileStencilMaterial(renderer: renderer, stencilRef: renderer.getTileStencilRef(coordinates)),
        ),
      );

  final RendererNode renderer;
  final TileCoordinates coordinates;
}

class TileStencilGeometry extends scene.Geometry {
  TileStencilGeometry({
    required RendererNode renderer,
    required this.coordinates,
  }) {
    final vertexData = ByteData(4 * 8);
    var offset = 0;
    offset = vertexData.setVec2(offset, vm.Vector2(0.0, 0.0));
    offset = vertexData.setVec2(offset, vm.Vector2(1.0, 0.0));
    offset = vertexData.setVec2(offset, vm.Vector2(1.0, 1.0));
    offset = vertexData.setVec2(offset, vm.Vector2(0.0, 1.0));
    final indexData = Uint16List.fromList([0, 1, 2, 0, 2, 3]);

    setVertexShader(renderer.getShader('tile-stencil-vert')!);
    uploadVertexData(vertexData, 4, indexData.buffer.asByteData());
  }

  final TileCoordinates coordinates;

  @override
  void bind(
    RenderPass pass,
    HostBuffer transientsBuffer,
    vm.Matrix4 modelTransform,
    vm.Matrix4 cameraTransform,
    vm.Vector3 cameraPosition,
  ) {
    bindVertexData(pass);

    final tileStencilInfoSlot = vertexShader.getUniformSlot('TileStencilInfo');
    if (tileStencilInfoSlot.sizeInBytes != null) {
      final mvp = cameraTransform * modelTransform;
      final data = ByteData(64);
      data.setMat4(0, mvp);
      pass.bindUniform(tileStencilInfoSlot, transientsBuffer.emplace(data));
    }
  }
}

class TileStencilMaterial extends scene.Material {
  TileStencilMaterial({
    required RendererNode renderer,
    required this.stencilRef,
  }) {
    setFragmentShader(renderer.getShader('empty-material-frag')!);
  }

  final int stencilRef;

  @override
  void bind(RenderPass pass, HostBuffer transientsBuffer, scene.Environment environment) {
    super.bind(pass, transientsBuffer, environment);

    pass.setCullMode(gpu.CullMode.none);

    pass.setColorBlendEnable(false);
    pass.setDepthWriteEnable(false);
    pass.setDepthCompareOperation(gpu.CompareFunction.always);

    // print(stencilRef);
    pass.setStencilReference(stencilRef);
    pass.setStencilConfig(
      gpu.StencilConfig(
        compareFunction: gpu.CompareFunction.always,
        depthStencilPassOperation: gpu.StencilOperation.setToReferenceValue,
        readMask: 0xFF,
        writeMask: 0xFF,
      ),
    );
  }
}
