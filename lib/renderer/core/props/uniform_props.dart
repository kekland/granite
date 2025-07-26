import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:granite/renderer/core/gpu/uniform_utils.dart';
import 'package:granite/renderer/core/props/prop_instruction.dart';
import 'package:granite/spec/expression/evaluation.dart' as spec;
import 'package:granite/spec/gen/style.gen.dart' as spec;

class UniformProps {
  UniformProps({required this.instructions});

  final List<PropInstruction> instructions;

  void bind(
    spec.EvaluationContext context,
    spec.Layer layer,
    gpu.RenderPass pass,
    gpu.Shader shader,
    gpu.HostBuffer transientsBuffer,
  ) {
    final uniformSlot = shader.getUniformSlot('PropUbo');
    if (uniformSlot.sizeInBytes == null) return;

    final data = ByteData(uniformSlot.sizeInBytes!);
    for (final instruction in instructions) {
      final offset = getUniformMemberOffset(uniformSlot, instruction.memberName!)!;
      instruction.execute(context, layer, data, offset);
    }

    final view = transientsBuffer.emplace(data);
    pass.bindUniform(uniformSlot, view);
  }
}
