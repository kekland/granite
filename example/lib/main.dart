import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart';
import 'package:granite/granite.dart';
import 'package:granite/renderer/core/camera/map_camera.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite_example/fixtures/maptiler-api-key.dart';
import 'package:granite_example/fixtures/styles.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'debug/metal_debug.dart' as mtl_dbg;

Future<void> main() async {
  HotReloadableShaderLibraryBindings.ensureInitialized();
  await Scene.initializeStaticResources();

  return runApp(
    MaterialApp(
      showPerformanceOverlay: true,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
      ),
      home: TileRendererMapCameraTest(),
    ),
  );
}

class TileRendererMapCameraTest extends StatefulWidget {
  const TileRendererMapCameraTest({super.key});

  @override
  State<TileRendererMapCameraTest> createState() => _TileRendererTestState();
}

class _TileRendererTestState extends State<TileRendererMapCameraTest> with TickerProviderStateMixin {
  late final focusNode = FocusNode();
  late final controller = MapController(
    style: spec.Style.fromJson(jsonDecode(maptilerStreetsStyle)),
    shaderLibraryProvider: HotReloadableShaderLibraryProvider('assets/maptiler-streets.shaderbundle'),
  );

  late final _acLat = AnimationController(vsync: this, duration: const Duration(milliseconds: 75));
  late final _acLon = AnimationController(vsync: this, duration: const Duration(milliseconds: 75));
  late final _acZ = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  late final _acB = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  late final _acP = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));

  late final _bT = Tween<double>(begin: 0.0, end: 0.0);
  late final _pT = Tween<double>(begin: 0.0, end: 0.0);

  // NYC
  // late final _latT = Tween<double>(begin: 40.7128, end: 40.7128);
  // late final _lonT = Tween<double>(begin: -74.0060, end: -74.0060);
  // late final _zT = Tween<double>(begin: 13.0, end: 13.0);

  MapCamera get camera => MapCamera(center: LatLng(lat, lon), zoom: z, bearing: bearing, pitch: pitch);

  // Milano
  // late final _latT = Tween<double>(begin: 45.4642, end: 45.4642);
  // late final _lonT = Tween<double>(begin: 9.1900, end: 9.1900);
  // late final _zT = Tween<double>(begin: 14.0, end: 14.0);

  // Almaty
  // late final _latT = Tween<double>(begin: 43.2220, end: 43.2220);
  // late final _lonT = Tween<double>(begin: 76.8512, end: 76.8512);
  // late final _zT = Tween<double>(begin: 14.0, end: 14.0);

  late final _latT = Tween<double>(begin: 0, end: 0);
  late final _lonT = Tween<double>(begin: 0, end: 0);
  late final _zT = Tween<double>(begin: 0.0, end: 0.0);

  double get lat => _latT.evaluate(_acLat);
  double get lon => _lonT.evaluate(_acLon);
  double get z => _zT.evaluate(_acZ);
  double get bearing => _bT.evaluate(_acB);
  double get pitch => _pT.evaluate(_acP);

  var _capture = false;

  @override
  void reassemble() {
    super.reassemble();

    // _load();
    // rendererNode.removeAll();
    // rendererNode.reassemble();
  }

  @override
  void initState() {
    super.initState();

    controller.camera = camera;
    controller.pixelRatio = 2.0;

    controller.addListener(() => setState(() {}));
    controller.scene.renderer.addListener(() => setState(() {}));

    Listenable.merge([_acLat, _acLon, _acZ, _acB, _acP]).addListener(() {
      controller.camera = camera;
    });
  }

  (double, double) _project(LatLng ll) {
    final lon = ll.longitude;
    final lat = ll.latitude * pi / 180;
    final x = (lon + 180) / 360;
    final y = 0.5 - log(tan(pi / 4 + lat / 2)) / (2 * pi);
    return (x, y);
  }

  LatLng _unproject(double x, double y) {
    // 1) longitude is linear:
    final double lon = x * 360.0 - 180.0;

    // 2) latitude comes from inverting Mercator’s y:
    final double n = pi - 2.0 * pi * y;
    // sinh(n) = (e^n - e^-n) / 2
    final double sinhN = (exp(n) - exp(-n)) / 2.0;
    // lat_rad = atan(sinh(n))
    final double latRad = atan(sinhN);
    final double lat = latRad * 180.0 / pi;

    return LatLng(lat, lon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (_, e) {
          if (e is KeyDownEvent || e is KeyRepeatEvent) {
            const double stepPx = 128.0; // fixed on‑screen pan
            final double zf = pow(2, z).toDouble();
            final double worldSize = RendererNode.kTileSize * zf; // world‑pixels across
            final double dNorm = stepPx / worldSize; // normalized Mercator step

            // current Mercator‐normalized centre:
            final (nx, ny) = _project(LatLng(lat, lon));

            // heading → forward unit vector in normalized coords
            final double brad = -bearing * vm.degrees2Radians;
            final double fx = sin(brad); // east component
            final double fy = -cos(brad); // north component (y ↓)

            // scaled step
            final double dx = fx * dNorm;
            final double dy = fy * dNorm;

            double newNx = nx, newNy = ny;
            if (e.logicalKey == LogicalKeyboardKey.keyW) {
              // forward
              newNx = (nx + dx).clamp(0.0, 1.0);
              newNy = (ny + dy).clamp(0.0, 1.0);
            } else if (e.logicalKey == LogicalKeyboardKey.keyS) {
              // backward
              newNx = (nx - dx).clamp(0.0, 1.0);
              newNy = (ny - dy).clamp(0.0, 1.0);
            } else if (e.logicalKey == LogicalKeyboardKey.keyA) {
              // strafe left = rotate forward CCW 90°
              final double lx = dy;
              final double ly = -dx;
              newNx = (nx + lx).clamp(0.0, 1.0);
              newNy = (ny + ly).clamp(0.0, 1.0);
            } else if (e.logicalKey == LogicalKeyboardKey.keyD) {
              // strafe right = rotate forward CW 90°
              final double rx = -dy;
              final double ry = dx;
              newNx = (nx + rx).clamp(0.0, 1.0);
              newNy = (ny + ry).clamp(0.0, 1.0);
            } else if (e.logicalKey == LogicalKeyboardKey.keyZ) {
              _zT.begin = z;
              _zT.end = (z + 1.0).clamp(0.0, 24.0);
              _acZ.forward(from: 0.0);
            } else if (e.logicalKey == LogicalKeyboardKey.keyX) {
              _zT.begin = z;
              _zT.end = (z - 1.0).clamp(0.0, 24.0);
              _acZ.forward(from: 0.0);
            }

            if (e.logicalKey == LogicalKeyboardKey.keyQ) {
              _bT.begin = bearing;
              _bT.end = (bearing - 10.0);
              _acB.forward(from: 0.0);
            } else if (e.logicalKey == LogicalKeyboardKey.keyE) {
              _bT.begin = bearing;
              _bT.end = (bearing + 10.0);
              _acB.forward(from: 0.0);
            }

            if (e.logicalKey == LogicalKeyboardKey.keyR) {
              _pT.begin = pitch;
              _pT.end = (pitch - 5.0).clamp(0.0, 90.0);
              _acP.forward(from: 0.0);
            } else if (e.logicalKey == LogicalKeyboardKey.keyF) {
              _pT.begin = pitch;
              _pT.end = (pitch + 5.0).clamp(0.0, 90.0);
              _acP.forward(from: 0.0);
            }

            if (newNx != nx || newNy != ny) {
              // update your center
              final vv = _unproject(newNx, newNy);
              _latT.begin = lat;
              _latT.end = vv.latitude;
              _lonT.begin = lon;
              _lonT.end = vv.longitude;
              _acLat.forward(from: 0.0);
              _acLon.forward(from: 0.0);
            }
          }

          return KeyEventResult.handled;
        },
        child: ListenableBuilder(
          listenable: Listenable.merge([_acLat, _acLon, _acZ, _acB, _acP]),
          builder: (context, _) {
            return Stack(
              children: [
                CustomPaint(
                  painter: _ScenePainter(
                    controller,
                    MediaQuery.of(context).devicePixelRatio,
                    _capture,
                  ),
                  child: SizedBox.expand(),
                ),
                Center(
                  child: Container(
                    width: 4.0,
                    height: 4.0,
                    color: Colors.red,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _capture = true;
                            setState(() {});
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _capture = false;
                              setState(() {});
                            });
                          },
                          child: Text('MTL Capture'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(
    this.controller,
    this.pixelRatio,
    this.capture,
  );

  final MapController controller;
  final double pixelRatio;
  final bool capture;

  @override
  void paint(Canvas canvas, Size size) {
    final dimensions = size * pixelRatio;
    controller.pixelRatio = pixelRatio;

    // print('lat: ${center.latitude}, lon: ${center.longitude}, zoom: $zoom, bearing: $bearing, pitch: $pitch');

    // canvas.drawColor(Colors.red, BlendMode.src);
    canvas.scale(1 / pixelRatio);
    if (capture) mtl_dbg.startCapture();
    controller.render(canvas, viewport: Offset.zero & dimensions);
    if (capture) mtl_dbg.stopCapture();
    canvas.scale(pixelRatio);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
