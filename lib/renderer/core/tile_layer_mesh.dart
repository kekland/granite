import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart';
import 'package:granite/renderer/core/tile_layer_geometry.dart';

final class TileLayerMesh extends Mesh {
  TileLayerMesh(TileLayerGeometry geometry) : super(geometry, _DummyMaterial(shader: geometry.fragmentShader));
}

class _DummyMaterial extends Material {
  _DummyMaterial({required this.shader}) {
    setFragmentShader(shader);
  }

  final gpu.Shader shader;

  @override
  void bind(
    gpu.RenderPass pass,
    gpu.HostBuffer transientsBuffer,
    Environment environment,
  ) {
    super.bind(pass, transientsBuffer, environment);
    pass.setWindingOrder(gpu.WindingOrder.clockwise);
    pass.setCullMode(gpu.CullMode.backFace);
  }

  @override
  bool isOpaque() {
    return true;
  }
}
