import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart';
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

abstract base class LayerTileGeometry<TNode extends LayerTileNode> extends scene.Geometry with Preparable {
  LayerTileGeometry({required this.node}) {
    setVertexShader(node.parent.vertexShader);
  }

  bool isEmpty = false;

  RendererNode get renderer => node.renderer;
  VertexProps get vertexProps => node.parent.vertexProps;
  UniformProps get uniformProps => node.parent.uniformProps;

  final TNode node;

  @override
  void bind(
    RenderPass pass,
    HostBuffer transientsBuffer,
    Matrix4 modelTransform,
    Matrix4 cameraTransform,
    Vector3 cameraPosition,
  ) {
    bindVertexData(pass);
  }
}
