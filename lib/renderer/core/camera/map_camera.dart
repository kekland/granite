import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart';

class MapCamera extends scene.Camera {
  MapCamera({
    required this.center,
    required this.zoom,
    this.tileSize = RendererNode.kTileSize,
    this.pixelRatio = 1.0,
    this.bearing = 0.0,
    this.pitch = 0.0,
  });

  final LatLng center;
  final double zoom;
  final double tileSize;
  final double pixelRatio;
  final double bearing;
  final double pitch;
  final fov = 60.0;
  final far = 10000.0;
  final near = 10.0;

  @override
  Matrix4 getViewTransform(Size dimensions) {
    final zf = math.pow(2, zoom).toDouble();
    final worldSize = tileSize * zf;
    final (x, y) = _project(center); // [0-1]
    final cx = x * worldSize;
    final cy = y * worldSize;

    final fovRad = fov * degrees2Radians;
    final proj = makePerspectiveMatrix(fovRad, dimensions.width / dimensions.height, near, far);

    final elev = 0.5 / math.tan(fovRad / 2) * (dimensions.height);

    final view = Matrix4.identity()
      ..translateByDouble(0.0, 0.0, -elev, 1.0)
      ..rotateX(-pitch * degrees2Radians)
      ..rotateZ(bearing * degrees2Radians)
      ..translateByDouble(-cx, -cy, 0.0, 1.0);

    final screen = Matrix4.identity()..scaleByDouble(2.0, -2.0, 1.0, 1.0);

    return screen * proj * view;
  }

  @override
  Vector3 get position {
    final worldSize = tileSize * math.pow(2, zoom);
    final (x, y) = _project(center);
    // TODO
    // return Vector3(x * worldSize, 0, y * worldSize);
    return Vector3(0.0, 0.0, 0.0);
  }

  (double, double) _project(LatLng ll) {
    final lon = ll.longitude;
    final lat = ll.latitude * math.pi / 180;
    final x = (lon + 180) / 360;
    final y = 0.5 - math.log(math.tan(math.pi / 4 + lat / 2)) / (2 * math.pi);
    return (x, y);
  }
}
