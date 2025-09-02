import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart' hide Material;
import 'package:flutter_scene/scene.dart';
import 'package:granite/granite.dart';
import 'package:granite/renderer/core/camera/map_camera.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite_example/fixtures/maptiler-api-key.dart';
import 'package:granite_example/fixtures/styles.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.pixelRatio = MediaQuery.devicePixelRatioOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapCameraGestureDetector(
        camera: controller.camera,
        onCameraChanged: (c) => controller.camera = c,
        child: Stack(
          children: [
            CustomPaint(
              painter: _MapPainter(
                controller: controller,
                pixelRatio: MediaQuery.devicePixelRatioOf(context),
              ),
              child: const SizedBox.expand(),
            ),
            Positioned(
              right: 16.0,
              bottom: 16.0,
              child: RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: controller.camera.pitch,
                  min: 0.0,
                  max: 60.0,
                  onChanged: (value) => controller.camera = controller.camera.copyWith(pitch: value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.controller,
    required this.pixelRatio,
  });

  final MapController controller;
  final double pixelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final dimensions = size * pixelRatio;
    // controller.pixelRatio = pixelRatio;

    canvas.scale(1 / pixelRatio);
    controller.render(canvas, viewport: Offset.zero & dimensions);
    canvas.scale(pixelRatio);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
