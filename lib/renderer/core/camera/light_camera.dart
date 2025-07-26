import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_scene/scene.dart' as scene;
import 'package:vector_math/vector_math_64.dart' as vm;

final _ndc = [
  vm.Vector4(-1, -1, 0, 1),
  vm.Vector4(1, -1, 0, 1),
  vm.Vector4(-1, 1, 0, 1),
  vm.Vector4(1, 1, 0, 1),
  vm.Vector4(-1, -1, 1, 1),
  vm.Vector4(1, -1, 1, 1),
  vm.Vector4(-1, 1, 1, 1),
  vm.Vector4(1, 1, 1, 1),
];

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

    final corners = _ndc.map((p) => invVp.transformed(p)).map((p) => p.xyz / p.w).toList();
    final center = corners.reduce((a, b) => a + b) / 8.0;
    final radius = corners.map((p) => (p - center).length).reduce((a, b) => max(a, b));
    const positionOffset = 1.5;
    final position = center + lightDirection * radius * positionOffset;

    final lightView = _matrix4LookAt(position, center, vm.Vector3(0, 0, 1));
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

    final lightProj = _matrix4Orthographic(snappedMinX, snappedMaxX, snappedMinY, snappedMaxY, minZ, maxZ);
    return lightProj * lightView;
  }
}

vm.Matrix4 _matrix4Orthographic(
  double left,
  double right,
  double bottom,
  double top,
  double zNear,
  double zFar,
) {
  final double dx = right - left;
  final double dy = top - bottom;
  final double dz = zFar - zNear;

  return vm.Matrix4(
    2.0 / dx,
    0.0,
    0.0,
    0.0,
    0.0,
    2.0 / dy,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0 / dz,
    0.0,
    -(right + left) / dx,
    -(top + bottom) / dy,
    -zNear / dz,
    1.0,
  );
}

vm.Matrix4 _matrix4LookAt(vm.Vector3 position, vm.Vector3 target, vm.Vector3 up) {
  vm.Vector3 forward = (target - position).normalized();
  vm.Vector3 right = up.cross(forward).normalized();
  up = forward.cross(right).normalized();

  return vm.Matrix4(
    right.x,
    up.x,
    forward.x,
    0.0, //
    right.y,
    up.y,
    forward.y,
    0.0, //
    right.z,
    up.z,
    forward.z,
    0.0, //
    -right.dot(position),
    -up.dot(position),
    -forward.dot(position),
    1.0, //
  );
}
