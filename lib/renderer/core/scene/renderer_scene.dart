import 'dart:ui' as ui;

import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/glyphs/glyphs.dart' as glyphs;
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/spec.dart' as spec;

base class RendererScene extends scene.Scene {
  RendererScene({
    required spec.Style style,
    required ShaderLibraryProvider shaderLibraryProvider,
    required Future<glyphs.Glyphs> Function(String fontStack, int rangeFrom) glyphsResolver,
  }) {
    final rendererNode = RendererNode(
      style: style,
      shaderLibraryProvider: shaderLibraryProvider,
      glyphsResolver: glyphsResolver,
    );

    root.add(rendererNode);
  }

  RendererNode get renderer => root.children.single as RendererNode;

  @override
  void render(scene.Camera camera, ui.Canvas canvas, {ui.Rect? viewport, double pixelRatio = 1.0}) {
    if (camera is MapCamera) {
      return super.render(camera.resolve(pixelRatio), canvas, viewport: viewport);
    }

    super.render(camera, canvas, viewport: viewport);
  }
}
