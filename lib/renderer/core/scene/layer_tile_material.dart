import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';

abstract base class LayerTileMaterial<TNode extends LayerTileNode> extends scene.Material with Preparable {
  LayerTileMaterial({required this.node}) {
    setFragmentShader(node.parent.fragmentShader);
  }

  UniformProps get uniformProps => node.parent.uniformProps;

  final TNode node;

  @override
  void bind(
    gpu.RenderPass pass,
    gpu.HostBuffer transientsBuffer,
    scene.Environment environment,
  ) {
    pass.setColorBlendEnable(true);
    pass.setColorBlendEquation(
      gpu.ColorBlendEquation(
        colorBlendOperation: gpu.BlendOperation.add,
        sourceColorBlendFactor: gpu.BlendFactor.one,
        destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
        alphaBlendOperation: gpu.BlendOperation.add,
        sourceAlphaBlendFactor: gpu.BlendFactor.one,
        destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
      ),
    );

    pass.setCullMode(gpu.CullMode.backFace);
    pass.setWindingOrder(gpu.WindingOrder.clockwise);
  }
}
