import 'dart:ui';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;

class CustomizableSurface extends scene.Surface {
  final int _maxFramesInFlight = 2;
  final List<gpu.RenderTarget> _renderTargets = [];
  int _cursor = 0;
  Size _previousSize = const Size(0, 0);

  @override
  gpu.RenderTarget getNextRenderTarget(Size size, bool enableMsaa) {
    if (size != _previousSize) {
      _cursor = 0;
      _renderTargets.clear();
      _previousSize = size;
    }
    if (_cursor == _renderTargets.length) {
      final gpu.Texture colorTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.devicePrivate,
        size.width.toInt(),
        size.height.toInt(),
        enableRenderTargetUsage: true,
        enableShaderReadUsage: true,
        coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture,
      );
      final colorAttachment = gpu.ColorAttachment(texture: colorTexture);
      if (enableMsaa) {
        final gpu.Texture msaaColorTexture = gpu.gpuContext.createTexture(
          gpu.StorageMode.devicePrivate,
          size.width.toInt(),
          size.height.toInt(),
          sampleCount: 4,
          enableRenderTargetUsage: true,
          enableShaderReadUsage: true,
          coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture,
        );
        colorAttachment.resolveTexture = colorAttachment.texture;
        colorAttachment.texture = msaaColorTexture;
        colorAttachment.storeAction = gpu.StoreAction.multisampleResolve;
      }
      final gpu.Texture depthTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.devicePrivate,
        size.width.toInt(),
        size.height.toInt(),
        sampleCount: enableMsaa ? 4 : 1,
        format: gpu.gpuContext.defaultDepthStencilFormat,
        enableRenderTargetUsage: true,
        enableShaderReadUsage: true,
        coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture,
      );
      final renderTarget = gpu.RenderTarget.singleColor(
        colorAttachment,
        depthStencilAttachment: gpu.DepthStencilAttachment(
          texture: depthTexture,
          depthClearValue: 1.0,
        ),
      );
      _renderTargets.add(renderTarget);
    }
    gpu.RenderTarget result = _renderTargets[_cursor];
    _cursor = (_cursor + 1) % _maxFramesInFlight;
    return result;
  }
}
