import 'dart:math' as math;
import 'dart:ui';

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

  @override
  vm.Matrix4 getViewTransform(Size dimensions) {
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

    final bearingRad = bearing * vm.degrees2Radians;
    final pitchRad = pitch * vm.degrees2Radians;
    final groundAngle = math.pi / 2 + pitchRad;
    final topHalfSurfaceDistance = math.sin(halfFov) * cameraToCenterDist / math.sin(math.pi - groundAngle - halfFov);
    final furthestDistance = math.cos(math.pi / 2 - pitchRad) * topHalfSurfaceDistance + cameraToCenterDist;
    final farZ = furthestDistance * 1.01;

    final proj = _matrix4Perspective(fovRad, dimensions.aspectRatio, 1.0, farZ);
    final view = vm.Matrix4.identity()
      ..scaleByDouble(1.0, -1.0, -1.0, 1.0)
      ..translateByDouble(0.0, 0.0, -cameraToCenterDist, 1.0)
      ..rotateX(pitchRad)
      ..rotateZ(bearingRad)
      ..translateByDouble(-x, -y, 0.0, 1.0);
      

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
