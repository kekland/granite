import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/spec.dart';
import 'package:granite_example/fixtures/maptiler-api-key.dart';
import 'package:granite_example/fixtures/styles.dart';
import 'package:granite_example/orthographic_camera.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

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
  late final scene = Scene();
  late final rendererNode = RendererNode(
    style: Style.fromJson(jsonDecode(maptilerStreetsStyle)),
    shaderLibraryProvider: HotReloadableShaderLibraryProvider('assets/maptiler-streets.shaderbundle'),
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
  // var xTween = Tween<double>(begin: 1206.22, end: 1203.0);
  // var yTween = Tween<double>(begin: 1539.99, end: 1546.0);
  // var dTween = Tween<double>(begin: 0.69, end: 0.69);
  // var rotTween = Tween<double>(begin: 0.0, end: 0.0);
  // var phiTween = Tween<double>(begin: 60.0, end: 60.0);

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
  var xTween = Tween<double>(begin: 2000.0, end: 2000.0);
  var yTween = Tween<double>(begin: 2000.0, end: 2000.0);
  var dTween = Tween<double>(begin: 6000.0, end: 6000.0);
  var rotTween = Tween<double>(begin: pi / 2, end: pi / 2);
  var phiTween = Tween<double>(begin: 89.0, end: 89.0);

  // final focusLat = 0.0;
  // final focusLon = 0.0;
  // var xTween = Tween<double>(begin: 0.0, end: 0.0);
  // var yTween = Tween<double>(begin: 0.0, end: 0.0);
  // var dTween = Tween<double>(begin: RendererNode.kTileSize, end: RendererNode.kTileSize);
  // var rotTween = Tween<double>(begin: 90.0, end: 90.0);
  // var phiTween = Tween<double>(begin: 89.0, end: 89.0);

  double get x => xTween.evaluate(_animationControllerX);
  double get y => yTween.evaluate(_animationControllerY);
  double get d => dTween.evaluate(_animationControllerZ);
  double get rot => rotTween.evaluate(_animationControllerRot);
  double get phi => phiTween.evaluate(_phiAnimationController);

  @override
  void reassemble() {
    super.reassemble();

    _load();
    rendererNode.removeAll();
    rendererNode.reassemble();
  }

  @override
  void initState() {
    super.initState();
    rendererNode.addListener(() => setState(() {}));
    scene.add(rendererNode);
    final dim = RendererNode.kTileSize / 64.0;
    final m = Mesh(CuboidGeometry(vm.Vector3(dim, dim, dim)), UnlitMaterial());
    final m2 = Mesh(CuboidGeometry(vm.Vector3(dim * 2, dim * 2, dim * 2)), UnlitMaterial());
    final m3 = Mesh(CuboidGeometry(vm.Vector3(dim * 3, dim * 3, dim * 3)), UnlitMaterial());
    scene.addMesh(m);
    scene.add(Node(localTransform: vm.Matrix4.translation(vm.Vector3(RendererNode.kTileSize, 0.0, 0.0)), mesh: m2));
    scene.add(Node(localTransform: vm.Matrix4.translation(vm.Vector3(0.0, 0.0, RendererNode.kTileSize)), mesh: m3));

    _load();
  }

  void _load() {
    final focusX = (focusLon + 180) / 360;
    final focusY = (1 - log(tan(focusLat * pi / 180) + 1 / cos(focusLat * pi / 180)) / pi) / 2;
    const range = 0;

    for (var z = 14; z <= 14; z++) {
      final xMax = pow(2, z).toInt() - 1;
      final yMax = pow(2, z).toInt() - 1;
      final x = (xMax * focusX).floor();
      final y = (yMax * focusY).floor();

      final _xmi = (x - range).clamp(0, xMax);
      final _ymi = (y - range).clamp(0, yMax);
      final _xma = (x + range).clamp(0, xMax);
      final _yma = (y + range).clamp(0, yMax);

      for (var j = _xmi; j <= _xma; j++) {
        for (var k = _ymi; k <= _yma; k++) {
          loadVectorTile(z, j, k).then((t) => rendererNode.addTile(TileCoordinates(j, k, z), t));
          print('added tile: z=$z, x=$j, y=$k');
        }
      }

      // loadVectorTile(z, x, y).then((t) => rendererNode.addTile(t, TileCoordinates(x, y, z)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is KeyRepeatEvent || e is KeyDownEvent) {
          final step = d * 0.1;
          var dx = 0.0, dy = 0.0;

          if (e.character == 'w') {
            dx = cos(rot * vm.degrees2Radians) * step;
            dy = sin(rot * vm.degrees2Radians) * step;
          } else if (e.character == 's') {
            dx = -cos(rot * vm.degrees2Radians) * step;
            dy = -sin(rot * vm.degrees2Radians) * step;
          } else if (e.character == 'a') {
            dx = -sin(rot * vm.degrees2Radians) * step;
            dy = cos(rot * vm.degrees2Radians) * step;
          } else if (e.character == 'd') {
            dx = sin(rot * vm.degrees2Radians) * step;
            dy = -cos(rot * vm.degrees2Radians) * step;
          } else if (e.character == 'q') {
            rotTween = Tween<double>(begin: rot, end: rot - 10.0);
            _animationControllerRot.forward(from: 0.0);
          } else if (e.character == 'e') {
            rotTween = Tween<double>(begin: rot, end: rot + 10.0);
            _animationControllerRot.forward(from: 0.0);
          } else if (e.character == 'z') {
            dTween = Tween<double>(begin: d, end: d * 0.75);
            _animationControllerZ.forward(from: 0.0);
          } else if (e.character == 'x') {
            dTween = Tween<double>(begin: d, end: d * 1.25);
            _animationControllerZ.forward(from: 0.0);
          } else if (e.character == 'r') {
            phiTween = Tween<double>(begin: phi, end: phi - 10.0);
            _phiAnimationController.forward(from: 0.0);
          } else if (e.character == 'f') {
            phiTween = Tween<double>(begin: phi, end: phi + 10.0);
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

        return KeyEventResult.handled;
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
              scene,
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
    final vm.Vector3 target = vm.Vector3(x, 0.0, y);

    final radius = d;
    final pitchAngle = phi.clamp(0.1, 179.9) * vm.degrees2Radians;
    final cosP = cos(pitchAngle);
    final sinP = sin(pitchAngle);

    final dx = radius * cosP * cos(rot * vm.degrees2Radians);
    final dy = radius * sinP;
    final dz = radius * cosP * sin(rot * vm.degrees2Radians);

    final vm.Vector3 camPos = target + vm.Vector3(dx, dy, dz);

    final camera = PerspectiveCamera(
      position: camPos,
      target: target,
      up: vm.Vector3(0.0, phi > 90 ? 1.0 : -1.0, 0.0),
      fovRadiansY: 45 * vm.degrees2Radians,
      fovNear: 0.0001,
      fovFar: 100000.0,
    );

    // final camera = PerspectiveCamera();

    canvas.scale(1 / pixelRatio);
    scene.render(camera, canvas, viewport: Offset.zero & (size * pixelRatio));
    canvas.scale(pixelRatio);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
