import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_gpu/gpu.dart';
import 'package:granite/renderer/core/ubos/ubo.dart';
import 'package:granite/spec/expression/evaluation.dart';
import 'package:granite/spec/gen/style.gen.dart';
import 'package:vector_math/vector_math.dart' as vm;

class TileUbo extends Ubo {
  TileUbo() : super(name: 'Tile');

  @override
  void bind(
    EvaluationContext context,
    vm.Matrix4 modelTransform,
    vm.Matrix4 cameraTransform,
    vm.Vector3 cameraPosition,
    Layer layer,
    RenderPass pass,
    Shader shader,
    HostBuffer transientsBuffer,
  ) {
    final data = Float32List.fromList([
      ...vm.Matrix4.identity().storage,
      1.0,
      4.0,
      1.0,
      context.zoom,
    ]);

    final slot = shader.getUniformSlot(name);
    if (slot.sizeInBytes == null) return;

    final view = transientsBuffer.emplace(data.buffer.asByteData());
    pass.bindUniform(slot, view);
  }
}
