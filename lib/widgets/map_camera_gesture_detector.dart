// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:granite/renderer/core/camera/map_camera.dart';

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
  void _onScaleStart(ScaleStartDetails details) {
    _scaleStartDetails = details;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    print(details);
    final lastScale = _lastScaleUpdateDetails?.scale ?? 1.0;
    final scaleDelta = details.scale - lastScale;
    final newCamera = camera.copyWith(zoom: camera.zoom * details.scale);
    widget.onCameraChanged(newCamera);
    _lastScaleUpdateDetails = details;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _lastScaleUpdateDetails = null;
  }

  void _onVerticalDragStart(DragStartDetails details) {}
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    print(details);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    print(details);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      ),
    );
  }
}
