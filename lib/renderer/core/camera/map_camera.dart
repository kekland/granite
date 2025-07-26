import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/core/camera/utils.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class MapCamera extends scene.Camera {
  MapCamera({
    required this.center,
    required this.zoom,
    this.bearing = 0.0,
    this.pitch = 0.0,
    this.fov = 45.0,
  });

  static final zero = MapCamera(center: LatLng(0.0, 0.0), zoom: 0.0, bearing: 0.0, pitch: 0.0, fov: 45.0);

  final LatLng center;
  final double zoom;
  final double bearing;
  final double pitch;
  final double fov;

  @override
  vm.Matrix4 getViewTransform(ui.Size dimensions) => vm.Matrix4.identity();

  @override
  vm.Vector3 get position => vm.Vector3.zero();

  ResolvedMapCamera resolve(double pixelRatio) => ResolvedMapCamera(
    center: center,
    zoom: zoom,
    bearing: bearing,
    pitch: pitch,
    fov: fov,
    pixelRatio: pixelRatio,
  );

  MapCamera copyWith({
    LatLng? center,
    double? zoom,
    double? bearing,
    double? pitch,
    double? fov,
  }) {
    return MapCamera(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      bearing: bearing ?? this.bearing,
      pitch: pitch ?? this.pitch,
      fov: fov ?? this.fov,
    );
  }

  Set<TileCoordinates> computeVisibleTiles(ui.Size dimensions, {int? zoom}) {
    // Project NDC to world coordinates
    final vp = getViewTransform(dimensions);
    final invVp = vp.clone()..invert();
    final corners = ndc.map((p) => invVp.transformed(p)).map((p) => p.xyz / p.w).toList();
    final minX = corners.map((p) => p.x).reduce(math.min);
    final maxX = corners.map((p) => p.x).reduce(math.max);
    final minY = corners.map((p) => p.y).reduce(math.min);
    final maxY = corners.map((p) => p.y).reduce(math.max);

    final _zoom = this.zoom;
    final z = (zoom ?? _zoom).floor().clamp(0, 1000); // TODO: probably clamp high zoom
    var tileSize = RendererNode.kTileSize;
    tileSize *= math.pow(2.0, (_zoom - z));

    final maxRange = math.pow(2, z).toInt() - 1;

    final xMin = (minX / tileSize).floor().clamp(0, maxRange);
    final xMax = (maxX / tileSize).ceil().clamp(0, maxRange);
    final yMin = (minY / tileSize).floor().clamp(0, maxRange);
    final yMax = (maxY / tileSize).ceil().clamp(0, maxRange);

    final visibleTiles = <TileCoordinates>{};
    for (var x = xMin; x <= xMax; x++) {
      for (var y = yMin; y <= yMax; y++) {
        visibleTiles.add(TileCoordinates(x, y, z));
      }
    }

    return visibleTiles;
  }
}

class ResolvedMapCamera extends MapCamera {
  ResolvedMapCamera({
    required super.center,
    required super.zoom,
    super.bearing = 0.0,
    super.pitch = 0.0,
    super.fov = 45.0,
    this.pixelRatio = 1.0,
  });

  final double pixelRatio;

  double _getCameraToCenterDistance(ui.Size dimensions) {
    final fovRad = fov * vm.degrees2Radians;
    final halfFov = fovRad / 2;
    return 0.5 * (dimensions.height / pixelRatio) / math.tan(halfFov);
  }

  vm.Matrix4 _getViewMatrix(ui.Size dimensions) {
    final tileSize = RendererNode.kTileSize;
    final worldSize = tileSize * math.pow(2, zoom).toDouble();

    final lat = center.latitude;
    final latRad = lat * vm.degrees2Radians;
    final lon = center.longitude;
    final x = (lon + 180) / 360 * worldSize;
    final y = (1.0 - math.log(math.tan(math.pi / 4 + latRad / 2)) / math.pi) / 2 * worldSize;

    final cameraToCenterDist = _getCameraToCenterDistance(dimensions);

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
    final cameraToCenterDist = _getCameraToCenterDistance(dimensions);

    final pitchRad = pitch * vm.degrees2Radians;
    final groundAngle = math.pi / 2 + pitchRad;
    final topRayMissesGround = pitchRad + halfFov >= math.pi / 2.0;
    final double farZ;

    if (!topRayMissesGround) {
      final topHalfSurfaceDistance = math.sin(halfFov) * cameraToCenterDist / math.sin(math.pi - groundAngle - halfFov);
      final furthestDistance = math.cos(math.pi / 2 - pitchRad) * topHalfSurfaceDistance + cameraToCenterDist;
      farZ = (furthestDistance * 1.01).clamp(0.0, 10000.0 / pixelRatio);
    } else {
      final double bottomRayAngle = pitchRad - halfFov; // <= π/2
      final double forwardReach = cameraToCenterDist / math.cos(bottomRayAngle);
      farZ = (forwardReach * 2.0).clamp(0.0, 10000.0 / pixelRatio);
    }

    return matrix4Perspective(fovRad, dimensions.aspectRatio, 1.0, farZ);
  }

  vm.Matrix4 _getOrthographicViewTransform(ui.Size dimensions) {
    final halfW = dimensions.width * 0.5 / pixelRatio;
    final halfH = dimensions.height * 0.5 / pixelRatio;

    final cameraToCenterDist = _getCameraToCenterDistance(dimensions);

    final nearZ = cameraToCenterDist * 0.1;
    final farZ = cameraToCenterDist * 1.1;

    return matrix4Orthographic(-halfW, halfW, -halfH, halfH, nearZ, farZ);
  }

  @override
  vm.Matrix4 getViewTransform(ui.Size dimensions) {
    final ortho = _getOrthographicViewTransform(dimensions);
    final persp = _getPerspectiveViewTransform(dimensions);

    // Interpolate between orthographic and perspective based on pitch
    final t = (pitch / 1.0).clamp(0.0, 1.0);
    final proj = lerpMatrix4(ortho, persp, t);
    final view = _getViewMatrix(dimensions);

    return proj * view;
  }

  @override
  vm.Vector3 get position {
    // Unused.
    return vm.Vector3(0.0, 0.0, 0.0);
  }
}
