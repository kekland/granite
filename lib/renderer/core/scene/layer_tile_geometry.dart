import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class GeometryData {
  GeometryData({
    required this.vertexData,
    required this.vertexCount,
    required this.indexData,
  });

  final TransferableTypedData vertexData;
  final int vertexCount;
  final TransferableTypedData indexData;
}

abstract base class LayerTileGeometry<TNode extends LayerTileNode> extends scene.Geometry {
  LayerTileGeometry({required this.node, required this.geometryData}) {
    setVertexShader(node.parent.vertexShader);
  }

  final GeometryData? geometryData;

  bool isEmpty = false;

  RendererNode get renderer => node.renderer;
  VertexProps get vertexProps => node.parent.vertexProps;
  UniformProps get uniformProps => node.parent.uniformProps;

  final TNode node;

  bool _isPrepared = false;
  void prepare();
  void maybePrepare() {
    if (!_isPrepared) {
      prepare();
      _isPrepared = true;
    }
  }

  @override
  void bind(
    gpu.RenderPass pass,
    gpu.HostBuffer transientsBuffer,
    vm.Matrix4 modelTransform,
    vm.Matrix4 cameraTransform,
    vm.Vector3 cameraPosition,
  ) {
    bindVertexData(pass);
  }
}
