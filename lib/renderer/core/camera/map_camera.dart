import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class MapCamera extends scene.Camera {
  MapCamera({
    required this.center,
    required this.zoom,
    this.pixelRatio = 1.0,
    this.bearing = 0.0,
    this.pitch = 0.0,
    this.fov = 45.0,
  });

  final LatLng center;
  final double zoom;
  final double pixelRatio;
  final double bearing;
  final double pitch;
  final double fov;

  vm.Matrix4 _getViewMatrix(ui.Size dimensions) {
    final tileSize = RendererNode.kTileSize;
    final worldSize = tileSize * math.pow(2, zoom).toDouble();

    final lat = center.latitude;
    final latRad = lat * vm.degrees2Radians;
    final lon = center.longitude;
    final x = (lon + 180) / 360 * worldSize;
    final y = (1.0 - math.log(math.tan(math.pi / 4 + latRad / 2)) / math.pi) / 2 * worldSize;

    final fovRad = fov * vm.degrees2Radians;
    final halfFov = fovRad / 2;
    final cameraToCenterDist = 0.5 * dimensions.height / math.tan(halfFov);

    final pitchRad = pitch * vm.degrees2Radians;
    final bearingRad = bearing * vm.degrees2Radians;

    final view = vm.Matrix4.identity()
      ..scaleByDouble(1.0, -1.0, -1.0, 1.0)
      ..translateByDouble(0.0, 0.0, -cameraToCenterDist, 1.0)
      ..rotateX(pitchRad)
      ..rotateZ(bearingRad)
      ..translateByDouble(-x, -y, 0.0, 1.0);

    return view;
  }

  vm.Matrix4 _getPerspectiveViewTransform(ui.Size dimensions) {
    final fovRad = fov * vm.degrees2Radians;
    final halfFov = fovRad / 2;
    final cameraToCenterDist = 0.5 * dimensions.height / math.tan(halfFov);

    final pitchRad = pitch * vm.degrees2Radians;
    final groundAngle = math.pi / 2 + pitchRad;
    final topRayMissesGround = pitchRad + halfFov >= math.pi / 2.0;
    final double farZ;

    if (!topRayMissesGround) {
      final topHalfSurfaceDistance = math.sin(halfFov) * cameraToCenterDist / math.sin(math.pi - groundAngle - halfFov);
      final furthestDistance = math.cos(math.pi / 2 - pitchRad) * topHalfSurfaceDistance + cameraToCenterDist;
      farZ = (furthestDistance * 1.01).clamp(0.0, 10000.0);
    } else {
      final double bottomRayAngle = pitchRad - halfFov; // <= π/2
      final double forwardReach = cameraToCenterDist / math.cos(bottomRayAngle);
      farZ = (forwardReach * 2.0).clamp(0.0, 10000.0);
    }
    print('topRayMissesGround: $topRayMissesGround, farZ: $farZ');

    return _matrix4Perspective(fovRad, dimensions.aspectRatio, 1.0, farZ);
  }

  vm.Matrix4 _getOrthographicViewTransform(ui.Size dimensions) {
    final halfW = dimensions.width * 0.5;
    final halfH = dimensions.height * 0.5;

    final fovRad = fov * vm.degrees2Radians;
    final halfFov = fovRad / 2;
    final cameraToCenterDist = 0.5 * dimensions.height / math.tan(halfFov);

    final nearZ = cameraToCenterDist * 0.1;
    final farZ = cameraToCenterDist * 1.1;

    return _matrix4Orthographic(-halfW, halfW, -halfH, halfH, nearZ, farZ);
  }

  @override
  vm.Matrix4 getViewTransform(ui.Size dimensions) {
    final ortho = _getOrthographicViewTransform(dimensions);
    final persp = _getPerspectiveViewTransform(dimensions);

    // Interpolate between orthographic and perspective based on pitch
    final t = (pitch / 1.0).clamp(0.0, 1.0);
    final proj = _lerpMat4(ortho, persp, t);
    final view = _getViewMatrix(dimensions);

    return proj * view;
  }

  @override
  vm.Vector3 get position {
    // Unused.
    return vm.Vector3(0.0, 0.0, 0.0);
  }
}

vm.Matrix4 _matrix4Perspective(
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

vm.Matrix4 _lerpMat4(vm.Matrix4 a, vm.Matrix4 b, double t) {
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
