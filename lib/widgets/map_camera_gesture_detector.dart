// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:granite/renderer/core/camera/map_camera.dart';
import 'package:granite/renderer/core/scene/renderer_node.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class MapCameraGestureDetector extends StatefulWidget {
  const MapCameraGestureDetector({
    super.key,
    required this.camera,
    required this.onCameraChanged,
    required this.child,
  });

  final ValueChanged<MapCamera> onCameraChanged;
  final MapCamera camera;
  final Widget child;

  @override
  State<MapCameraGestureDetector> createState() => _MapCameraGestureDetectorState();
}

class _MapCameraGestureDetectorState extends State<MapCameraGestureDetector> {
  MapCamera get camera => widget.camera;

  ScaleStartDetails? _scaleStartDetails;
  ScaleUpdateDetails? _lastScaleUpdateDetails;
  late Size _dimensions;
  late double _pixelRatio;

  void _onScaleStart(ScaleStartDetails details) {
    _scaleStartDetails = details;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final lastScale = _lastScaleUpdateDetails?.scale ?? 1.0;
    final lastFocalPoint = _lastScaleUpdateDetails?.focalPoint ?? _scaleStartDetails!.focalPoint;
    final focalPointDelta = (details.focalPoint - lastFocalPoint) * _pixelRatio;
    final normalizedFocalPoint = details.focalPoint - _dimensions.center(Offset.zero) * _pixelRatio;

    final translation = details.focalPointDelta;
    final transform = vm.Matrix4.identity()..translateByDouble(focalPointDelta.dx, focalPointDelta.dy, 0.0, 1.0);
    print(normalizedFocalPoint);
    // print(_cameraToTransform(camera));

    _applyTransformToCamera(transform);
    _lastScaleUpdateDetails = details;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _lastScaleUpdateDetails = null;
  }

  void _applyTransformToCamera(vm.Matrix4 transform) {
    final newCamera = _cameraFromTransform(transform * _cameraToTransform(camera));
    widget.onCameraChanged(newCamera);
  }

  vm.Matrix4 _cameraToTransform(MapCamera camera) {
    final scale = pow(2.0, camera.zoom).toDouble();
    final worldSize = RendererNode.kTileSize * scale;

    // Convert lat/lng to pixels
    final latRad = camera.center.latitude * vm.degrees2Radians;
    final x = (camera.center.longitude + 180.0) / 360.0 * worldSize;
    final y = worldSize * (0.5 - log(tan(pi / 4 + latRad / 2)) / (2 * pi));

    return vm.Matrix4.identity()
      ..translateByDouble(-x, -y, 0.0, 1.0)
      ..scaleByDouble(scale, scale, 1.0, 1.0);
  }

  MapCamera _cameraFromTransform(vm.Matrix4 transform) {
    final scale = transform.getMaxScaleOnAxis();
    final zoom = log(scale) / log(2.0);
    final worldSize = RendererNode.kTileSize * scale;

    // Convert pixels back to lat/lng
    final translation = transform.getTranslation();
    final x = -translation.x;
    final y = -translation.y;
    final latRad = 2 * atan(exp((0.5 - (y / worldSize)) * 2 * pi)) - pi / 2;
    final lat = latRad * vm.radians2Degrees;
    final lon = (x / worldSize) * 360.0 - 180.0;

    return camera.copyWith(
      center: LatLng(lat, lon),
      zoom: zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    _pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        _dimensions = constraints.biggest;
        return Stack(
          children: [
            GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              behavior: HitTestBehavior.opaque,
              child: widget.child,
            ),
            Positioned(
              left: _dimensions.width / 2,
              top: _dimensions.height / 2,
              child: IgnorePointer(
                child: Transform(
                  transform: _cameraToTransform(camera),
                  child: Container(
                    width: 512.0,
                    height: 512.0,
                    color: Colors.orange.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16.0,
              bottom: 16.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final newCamera = camera.copyWith(zoom: camera.zoom + 0.25);
                      widget.onCameraChanged(newCamera);
                    },
                    child: const Text('Zoom In'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final newCamera = camera.copyWith(zoom: camera.zoom - 0.25);
                      widget.onCameraChanged(newCamera);
                    },
                    child: const Text('Zoom Out'),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_left),
                    onPressed: () {
                      final newCamera = camera.copyWith(
                        center: LatLng(camera.center.latitude, camera.center.longitude - 1.0),
                      );
                      widget.onCameraChanged(newCamera);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right),
                    onPressed: () {
                      final newCamera = camera.copyWith(
                        center: LatLng(camera.center.latitude, camera.center.longitude + 1.0),
                      );
                      widget.onCameraChanged(newCamera);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: () {
                      final newCamera = camera.copyWith(
                        center: LatLng(camera.center.latitude + 1.0, camera.center.longitude),
                      );
                      widget.onCameraChanged(newCamera);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward),
                    onPressed: () {
                      final newCamera = camera.copyWith(
                        center: LatLng(camera.center.latitude - 1.0, camera.center.longitude),
                      );
                      widget.onCameraChanged(newCamera);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

    // final lastScale = _lastScaleUpdateDetails?.scale ?? 1.0;
    // final scaleDelta = details.scale / lastScale;
    // final rotation = details.rotation - (_lastScaleUpdateDetails?.rotation ?? 0.0);
    // var newCamera = camera.copyWith(
    //   bearing: camera.bearing + rotation * vm.radians2Degrees,
    //   zoom: camera.zoom + (log(scaleDelta) / log(2.0)),
    // );

    // final tileSize = RendererNode.kTileSize;
    // final worldSize = tileSize * pow(2.0, newCamera.zoom);
    // final latRad0 = camera.center.latitude * vm.degrees2Radians;
    // final y0 = worldSize * (0.5 - log(tan(pi / 4 + latRad0 / 2)) / (2 * pi));
    // final latRad1 = 2 * atan(exp((0.5 - (y0 + details.focalPointDelta.dy) / worldSize) * 2 * pi)) - pi / 2;
    // final deltaLat = (latRad1 - latRad0) * vm.radians2Degrees;
    // final deltaLon = (details.focalPointDelta.dx / worldSize) * 360.0;
    // newCamera = newCamera.copyWith(
    //   center: LatLng(
    //     camera.center.latitude - deltaLat,
    //     camera.center.longitude - deltaLon,
    //   ),
    // );

    // widget.onCameraChanged(newCamera);