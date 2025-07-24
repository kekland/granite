import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:granite/spec/spec.dart' as spec;
import 'package:vector_math/vector_math.dart' as vm;

abstract class Ubo {
  Ubo({required this.name});

  final String name;

  void bind(
    spec.EvaluationContext context,
    vm.Matrix4 modelTransform,
    vm.Matrix4 cameraTransform,
    vm.Vector3 cameraPosition,
    spec.Layer layer,
    gpu.RenderPass pass,
    gpu.Shader shader,
    gpu.HostBuffer transientsBuffer,
  );
}
