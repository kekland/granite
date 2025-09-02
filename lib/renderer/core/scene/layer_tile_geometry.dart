import 'dart:async';
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

  ByteData? vertexByteData;
  ByteData? indexByteData;

  void materialize() {
    if (vertexByteData != null && indexByteData != null) return;
    vertexByteData = vertexData.materialize().asByteData();
    indexByteData = indexData.materialize().asByteData();
  }
}

abstract base class LayerTileGeometry<TNode extends LayerTileNode> extends scene.Geometry {
  LayerTileGeometry({required this.node}) {
    setVertexShader(node.parent.vertexShader);
  }

  bool isEmpty = false;

  RendererNode get renderer => node.renderer;
  VertexProps get vertexProps => node.parent.vertexProps;
  UniformProps get uniformProps => node.parent.uniformProps;

  final TNode node;

  bool _isPrepared = false;
  bool _isPreparing = false;
  FutureOr<void> prepare();
  FutureOr<void> maybePrepare() {
    if (!_isPreparing && !_isPrepared) {
      final v = prepare();
      _isPreparing = true;

      if (v is Future) {
        return v.then((_) => _isPrepared = true);
      } else {
        _isPrepared = true;
      }
    }
  }

  bool get isReady => _isPrepared;

  @override
  void bind(
    gpu.RenderPass pass,
    gpu.HostBuffer transientsBuffer,
    vm.Matrix4 modelTransform,
    vm.Matrix4 cameraTransform,
    vm.Vector3 cameraPosition,
  ) {
    if (!_isPrepared) return;
    bindVertexData(pass);
  }
}
