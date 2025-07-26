
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:vector_math/vector_math_64.dart' as vm;

final ndc = [
  vm.Vector4(-1, -1, 0, 1),
  vm.Vector4(1, -1, 0, 1),
  vm.Vector4(-1, 1, 0, 1),
  vm.Vector4(1, 1, 0, 1),
  vm.Vector4(-1, -1, 1, 1),
  vm.Vector4(1, -1, 1, 1),
  vm.Vector4(-1, 1, 1, 1),
  vm.Vector4(1, 1, 1, 1),
];

vm.Matrix4 matrix4Orthographic(
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

vm.Matrix4 matrix4LookAt(vm.Vector3 position, vm.Vector3 target, vm.Vector3 up) {
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

vm.Matrix4 matrix4Perspective(
  double fovRadiansY,
  double aspectRatio,
  double zNear,
  double zFar,
) {
  double height = math.tan(fovRadiansY * 0.5);
  double width = height * aspectRatio;

  return vm.Matrix4(
    1.0 / width,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0 / height,
    0.0,
    0.0,
    0.0,
    0.0,
    zFar / (zFar - zNear),
    1.0,
    0.0,
    0.0,
    -(zFar * zNear) / (zFar - zNear),
    0.0,
  );
}

vm.Matrix4 lerpMatrix4(vm.Matrix4 a, vm.Matrix4 b, double t) {
  return vm.Matrix4(
    ui.lerpDouble(a[0], b[0], t)!,
    ui.lerpDouble(a[1], b[1], t)!,
    ui.lerpDouble(a[2], b[2], t)!,
    ui.lerpDouble(a[3], b[3], t)!,
    ui.lerpDouble(a[4], b[4], t)!,
    ui.lerpDouble(a[5], b[5], t)!,
    ui.lerpDouble(a[6], b[6], t)!,
    ui.lerpDouble(a[7], b[7], t)!,
    ui.lerpDouble(a[8], b[8], t)!,
    ui.lerpDouble(a[9], b[9], t)!,
    ui.lerpDouble(a[10], b[10], t)!,
    ui.lerpDouble(a[11], b[11], t)!,
    ui.lerpDouble(a[12], b[12], t)!,
    ui.lerpDouble(a[13], b[13], t)!,
    ui.lerpDouble(a[14], b[14], t)!,
    ui.lerpDouble(a[15], b[15], t)!,
  );
}
