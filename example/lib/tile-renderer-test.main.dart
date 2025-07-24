import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_scene/scene.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/spec.dart';
import 'package:granite_example/fixtures/maptiler-api-key.dart';
import 'package:granite_example/fixtures/styles.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'package:granite/renderer/gpu_utils/hot_reloadable_shader_library.dart';

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
      home: TileRendererTest(),
    ),
  );
}

class TileRendererTest extends StatefulWidget {
  const TileRendererTest({super.key});

  @override
  State<TileRendererTest> createState() => _TileRendererTestState();
}

class _TileRendererTestState extends State<TileRendererTest> with TickerProviderStateMixin {
  late final focusNode = FocusNode();
  late final renderer = Renderer(
    style: Style.fromJson(jsonDecode(maptilerStreetsDarkStyle)),
    shaderLibraryProvider: HotReloadableShaderLibraryProvider('assets/maptiler-streets-dark.shaderbundle'),
  );

  late final _animationControllerX = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 75),
  );

  late final _animationControllerY = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 75),
  );

  late final _animationControllerZ = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  late final _animationControllerRot = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  late final _phiAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  // NY
  final focusLat = 40.7128;
  final focusLon = -74.0060;
  var xTween = Tween<double>(begin: 1206.22, end: 1203.0);
  var yTween = Tween<double>(begin: 1539.99, end: 1546.0);
  var dTween = Tween<double>(begin: 0.69, end: 0.69);
  var rotTween = Tween<double>(begin: 0.0, end: 0.0);
  var phiTween = Tween<double>(begin: 60.0, end: 60.0);

  // Milano
  // final focusLat = 45.4642;
  // final focusLon = 9.1900;
  // var xTween = Tween<double>(begin: 2152.22, end: 2152.0);
  // var yTween = Tween<double>(begin: 1465, end: 1465);
  // var dTween = Tween<double>(begin: 0.6, end: 0.6);
  // var rotTween = Tween<double>(begin: 0.0, end: 0.0);
  // var phiTween = Tween<double>(begin: 60.0, end: 60.0);

  // final focusLat = 0.0;
  // final focusLon = 0.0;
  // var xTween = Tween<double>(begin: 2000.0, end: 2000.0);
  // var yTween = Tween<double>(begin: 2000.0, end: 2000.0);
  // var dTween = Tween<double>(begin: 6000.0, end: 6000.0);
  // var rotTween = Tween<double>(begin: pi / 2, end: pi / 2);
  // var phiTween = Tween<double>(begin: 89.0, end: 89.0);

  double get x => xTween.evaluate(_animationControllerX);
  double get y => yTween.evaluate(_animationControllerY);
  double get d => dTween.evaluate(_animationControllerZ);
  double get rot => rotTween.evaluate(_animationControllerRot);
  double get phi => phiTween.evaluate(_phiAnimationController);

  @override
  void reassemble() {
    super.reassemble();
    renderer.onReassemble();
  }

  @override
  void initState() {
    super.initState();
    renderer.addListener(() => setState(() {}));

    final focusX = (focusLon + 180) / 360;
    final focusY = (1 - log(tan(focusLat * pi / 180) + 1 / cos(focusLat * pi / 180)) / pi) / 2;

    for (var z = 14; z <= 14; z++) {
      final xMax = pow(2, z).toInt() - 1;
      final yMax = pow(2, z).toInt() - 1;
      final x = (xMax * focusX).floor();
      final y = (yMax * focusY).floor();

      for (var j = -3; j <= 3; j++) {
        for (var k = -3; k <= 3; k++) {
          final _x = x + j;
          final _y = y + k;

          loadVectorTile(z, _x, _y).then((t) => renderer.addTile(t, TileCoordinates(_x, _y, z)));
        }
      }

      // loadVectorTile(z, x, y).then((t) => renderer.addTile(t, TileCoordinates(x, y, z)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is KeyRepeatEvent || e is KeyDownEvent) {
          final step = d * 0.25;
          var dx = 0.0, dy = 0.0;

          if (e.character == 'w') {
            dx = -cos(rot) * step;
            dy = -sin(rot) * step;
          } else if (e.character == 's') {
            dx = cos(rot) * step;
            dy = sin(rot) * step;
          } else if (e.character == 'a') {
            dx = -sin(rot) * step;
            dy = cos(rot) * step;
          } else if (e.character == 'd') {
            dx = sin(rot) * step;
            dy = -cos(rot) * step;
          } else if (e.character == 'q') {
            rotTween = Tween<double>(begin: rot, end: rot + 0.2);
            _animationControllerRot.forward(from: 0.0);
          } else if (e.character == 'e') {
            rotTween = Tween<double>(begin: rot, end: rot - 0.2);
            _animationControllerRot.forward(from: 0.0);
          } else if (e.character == 'z') {
            dTween = Tween<double>(begin: d, end: d * 0.75);
            _animationControllerZ.forward(from: 0.0);
          } else if (e.character == 'x') {
            dTween = Tween<double>(begin: d, end: d * 1.25);
            _animationControllerZ.forward(from: 0.0);
          } else if (e.character == 'r') {
            phiTween = Tween<double>(begin: phi, end: phi + 10.0);
            _phiAnimationController.forward(from: 0.0);
          } else if (e.character == 'f') {
            phiTween = Tween<double>(begin: phi, end: phi - 10.0);
            _phiAnimationController.forward(from: 0.0);
          }

          if (dx != 0.0 || dy != 0.0) {
            xTween = Tween<double>(begin: x, end: x + dx);
            yTween = Tween<double>(begin: y, end: y + dy);
            _animationControllerX.forward(from: 0.0);
            _animationControllerY.forward(from: 0.0);
          }

          setState(() {});
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _animationControllerX,
          _animationControllerY,
          _animationControllerZ,
          _animationControllerRot,
          _phiAnimationController,
        ]),
        builder: (context, _) {
          return CustomPaint(
            painter: _ScenePainter(
              renderer.scene,
              x,
              y,
              d,
              rot,
              phi,
              MediaQuery.of(context).devicePixelRatio,
            ),
          );
        },
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.x, this.y, this.d, this.rot, this.phi, this.pixelRatio);

  final double pixelRatio;
  Scene scene;
  double x;
  double y;
  double d;
  double rot;
  double phi;

  @override
  void paint(Canvas canvas, Size size) {
    final aspectRatio = size.aspectRatio;
    final viewDimension = d;
    // final camera = OrthographicCamera(
    //   position: vm.Vector3(x, y, 10.0),
    //   target: vm.Vector3(x, y, 0.0),
    //   zNear: 0.1,
    //   zFar: 100000000.0,
    //   left: viewDimension,
    //   right: -viewDimension,
    //   top: -viewDimension / aspectRatio,
    //   bottom: viewDimension / aspectRatio,
    // );

    final vm.Vector3 target = vm.Vector3(x, y, 0.0);

    final radius = d;
    final pitchAngle = phi * vm.degrees2Radians;
    final cosP = cos(pitchAngle);
    final sinP = sin(pitchAngle);

    final dx = radius * cosP * cos(rot);
    final dy = radius * cosP * sin(rot);
    final dz = radius * sinP;

    final vm.Vector3 camPos = target + vm.Vector3(dx, dy, dz);

    final camera = PerspectiveCamera(
      position: camPos,
      target: target,
      up: vm.Vector3(0.0, 0.0, 1.0),
      fovRadiansY: 45 * vm.degrees2Radians,
      fovNear: 0.001,
      fovFar: 100000000.0,
    );

    canvas.scale(1 / pixelRatio);
    scene.render(camera, canvas, viewport: Offset.zero & (size * pixelRatio));
    canvas.scale(pixelRatio);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
