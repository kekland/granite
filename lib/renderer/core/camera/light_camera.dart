import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/core/camera/utils.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class LightCamera extends scene.Camera {
  LightCamera({
    required this.mainCamera,
    required this.direction,
  });

  final scene.Camera mainCamera;
  final vm.Vector3 direction;

  @override
  vm.Vector3 get position => vm.Vector3.zero();

  @override
  vm.Matrix4 getViewTransform(ui.Size dimensions) {
    final vp = mainCamera.getViewTransform(dimensions);
    final lightDirection = direction.normalized();
    final invVp = vp.clone()..invert();

    final corners = ndc.map((p) => invVp.transformed(p)).map((p) => p.xyz / p.w).toList();
    final center = corners.reduce((a, b) => a + b) / 8.0;
    final radius = corners.map((p) => (p - center).length).reduce((a, b) => max(a, b));
    const positionOffset = 1.5;
    final position = center + lightDirection * radius * positionOffset;

    final lightView = matrix4LookAt(position, center, vm.Vector3(0, 0, 1));
    final lightSpace = corners.map((p) => p.clone()..applyMatrix4(lightView)).toList();

    final minX = lightSpace.map((p) => p.x).reduce(min);
    final maxX = lightSpace.map((p) => p.x).reduce(max);
    final minY = lightSpace.map((p) => p.y).reduce(min);
    final maxY = lightSpace.map((p) => p.y).reduce(max);
    final minZ = lightSpace.map((p) => p.z).reduce(min);
    final maxZ = lightSpace.map((p) => p.z).reduce(max);

    const padding = 2.0;
    final width = (maxX - minX) * padding;
    final height = (maxY - minY) * padding;

    final texelWorldSize = (maxX - minX) * padding / dimensions.longestSide;
    final snappedMinX = (minX * padding / texelWorldSize).floor() * texelWorldSize;
    final snappedMinY = (minY * padding / texelWorldSize).floor() * texelWorldSize;
    final snappedMaxX = snappedMinX + width;
    final snappedMaxY = snappedMinY + height;

    final lightProj = matrix4Orthographic(snappedMinX, snappedMaxX, snappedMinY, snappedMaxY, minZ, maxZ);
    return lightProj * lightView;
  }
}
