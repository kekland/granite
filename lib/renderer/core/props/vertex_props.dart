import 'dart:typed_data';

import 'package:granite/renderer/core/props/prop_instruction.dart';
import 'package:granite/spec/spec.dart' as spec;

class VertexProps {
  VertexProps({
    required this.instructions,
  });

  final List<PropInstruction> instructions;

  late final ByteData data = ByteData(lengthInBytes);
  late final int lengthInBytes = instructions.fold<int>(0, (acc, v) => acc + v.sizeInBytes);

  void compute(spec.EvaluationContext context, spec.Layer layer) {
    var offset = 0;
    for (final instruction in instructions) {
      offset = instruction.execute(context, layer, data, offset);
    }
  }
}
