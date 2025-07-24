import 'dart:ui' as ui;
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math_64.dart';

/// Builds an orthographic projection matrix mapping [left..right], [bottom..top],
/// and [zNear..zFar] into normalized device coordinates.
///
/// Z is mapped into [0..1] (to match your perspective setup).
Matrix4 _matrix4Orthographic(
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

  return Matrix4(
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

Matrix4 _matrix4LookAt(Vector3 position, Vector3 target, Vector3 up) {
  Vector3 forward = (target - position).normalized();
  Vector3 right = up.cross(forward).normalized();
  up = forward.cross(right).normalized();

  return Matrix4(
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

class OrthographicCamera extends Camera {
  OrthographicCamera({
    this.left = -1.0,
    this.right = 1.0,
    this.bottom = -1.0,
    this.top = 1.0,
    this.zNear = 0.1,
    this.zFar = 1000.0,
    Vector3? position,
    Vector3? target,
    Vector3? up,
  }) : position = position ?? Vector3(0, 0, -5),
       target = target ?? Vector3(0, 0, 0),
       up = up ?? Vector3(0, 1, 0);

  /// World‐space bounds of the orthographic frustum.
  final double left;
  final double right;
  final double bottom;
  final double top;

  /// Near and far clipping planes.
  final double zNear;
  final double zFar;

  @override
  Vector3 position;

  /// Point the camera is looking at.
  Vector3 target;

  /// Up direction for the camera.
  Vector3 up;

  @override
  Matrix4 getViewTransform(ui.Size dimensions) {
    // Build orthographic projection, then apply look‐at view.
    return _matrix4Orthographic(
          left,
          right,
          bottom,
          top,
          zNear,
          zFar,
        ) *
        _matrix4LookAt(position, target, up);
  }
}
