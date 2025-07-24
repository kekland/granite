import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:vector_math/vector_math_64.dart';

class TextureGeometry extends scene.Geometry {
  TextureGeometry({required RendererNode renderer}) {
    setVertexShader(renderer.getShader('texture-vert')!);
  }

  @override
  void bind(
    RenderPass pass,
    HostBuffer transientsBuffer,
    Matrix4 modelTransform,
    Matrix4 cameraTransform,
    Vector3 cameraPosition,
  ) {
    final vertexData = ByteData(4 * 16);
    void setVertex(int index, {required Vector2 position, required Vector2 uv}) {
      var offset = index * 16;
      offset = vertexData.setVec2(offset, position);
      offset = vertexData.setVec2(offset, uv);
    }

    setVertex(0, position: Vector2(-1.0, -1.0), uv: Vector2(0.0, 1.0));
    setVertex(1, position: Vector2(1.0, -1.0), uv: Vector2(1.0, 1.0));
    setVertex(2, position: Vector2(1.0, 1.0), uv: Vector2(1.0, 0.0));
    setVertex(3, position: Vector2(-1.0, 1.0), uv: Vector2(0.0, 0.0));

    final indices = Uint16List.fromList([0, 1, 2, 0, 2, 3]);

    uploadVertexData(vertexData, 4, indices.buffer.asByteData());
    bindVertexData(pass);
  }
}

class TextureMaterial extends scene.Material {
  TextureMaterial({
    required RendererNode renderer,
    required this.texture,
    required this.opacity,
  }) {
    setFragmentShader(renderer.getShader('texture-frag')!);
  }

  final gpu.Texture texture;
  final double opacity;

  @override
  void bind(RenderPass pass, HostBuffer transientsBuffer, scene.Environment environment) {
    super.bind(pass, transientsBuffer, environment);
    
    pass.setColorBlendEnable(true);
    pass.setDepthWriteEnable(false);
    pass.setDepthCompareOperation(gpu.CompareFunction.always);

    // Texture
    final textureSlot = fragmentShader.getUniformSlot('u_texture');
    pass.bindTexture(textureSlot, texture);

    // Texture UBO
    final textureUboSlot = fragmentShader.getUniformSlot('TextureUbo');
    final data = ByteData(textureUboSlot.sizeInBytes!);
    data.setFloat(0, opacity);

    final view = transientsBuffer.emplace(data);
    pass.bindUniform(textureUboSlot, view);
  }
}
