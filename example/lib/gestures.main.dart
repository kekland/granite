// import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/material.dart' hide Material;
// import 'package:flutter_scene/scene.dart';
// import 'package:granite/granite.dart';
// import 'package:granite/renderer/core/camera/map_camera.dart';
// import 'package:granite/spec/spec.dart' as spec;
// import 'package:granite_example/fixtures/maptiler-api-key.dart';
// import 'package:granite_example/fixtures/styles.dart';
// import 'package:latlong2/latlong.dart';

// Future<void> main() async {
//   HotReloadableShaderLibraryBindings.ensureInitialized();
//   await Scene.initializeStaticResources();

//   return runApp(
//     MaterialApp(
//       showPerformanceOverlay: true,
//       theme: ThemeData.from(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.pink,
//           brightness: Brightness.dark,
//         ),
//       ),
//       home: TileRendererMapCameraTest(),
//     ),
//   );
// }

// class TileRendererMapCameraTest extends StatefulWidget {
//   const TileRendererMapCameraTest({super.key});

//   @override
//   State<TileRendererMapCameraTest> createState() => _TileRendererTestState();
// }

// class _TileRendererTestState extends State<TileRendererMapCameraTest> with TickerProviderStateMixin {
//   late final focusNode = FocusNode();
//   late final scene = RendererScene();
//   late final rendererNode = RendererNode(
//     style: spec.Style.fromJson(jsonDecode(maptilerStreetsStyle)),
//     shaderLibraryProvider: HotReloadableShaderLibraryProvider('assets/maptiler-streets.shaderbundle'),
//   );

//   var camera = MapCamera(center: LatLng(0.0, 0.0), zoom: 0.0, bearing: 0.0, pitch: 0.0);

//   @override
//   void reassemble() {
//     super.reassemble();
//     rendererNode.reassemble();
//   }

//   @override
//   void initState() {
//     super.initState();
//     rendererNode.addListener(() => setState(() {}));
//     scene.antiAliasingMode = AntiAliasingMode.msaa;
//     scene.add(rendererNode);

//     _load();
//   }

//   void _load() {
//     final focusX = (0.0 + 180) / 360;
//     final focusY = (1 - log(tan(0.0 * pi / 180) + 1 / cos(0.0 * pi / 180)) / pi) / 2;
//     const range = 0;

//     for (var z = 0; z <= 14; z++) {
//       final xMax = pow(2, z).toInt() - 1;
//       final yMax = pow(2, z).toInt() - 1;
//       final x = (xMax * focusX).floor();
//       final y = (yMax * focusY).floor();

//       final _xmi = (x - range).clamp(0, xMax);
//       final _ymi = (y - range).clamp(0, yMax);
//       final _xma = (x + range).clamp(0, xMax);
//       final _yma = (y + range).clamp(0, yMax);

//       for (var j = _xmi; j <= _xma; j++) {
//         for (var k = _ymi; k <= _yma; k++) {
//           loadVectorTile(z, j, k).then((t) => rendererNode.addTile(TileCoordinates(j, k, z), t));
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: MapCameraGestureDetector(
//         camera: camera,
//         onCameraChanged: (c) => setState(() => camera = c),
//         child: CustomPaint(
//           painter: _ScenePainter(
//             scene: scene,
//             camera: camera,
//             pixelRatio: MediaQuery.devicePixelRatioOf(context),
//           ),
//           child: const SizedBox.expand(),
//         ),
//       ),
//     );
//   }
// }

// class _ScenePainter extends CustomPainter {
//   _ScenePainter({
//     required this.scene,
//     required this.camera,
//     required this.pixelRatio,
//   });

//   final Scene scene;
//   final MapCamera camera;
//   final double pixelRatio;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final dimensions = size * pixelRatio;

//     canvas.scale(1 / pixelRatio);
//     if (scene is RendererScene) {
//       (scene as RendererScene).render(camera, canvas, viewport: Offset.zero & dimensions, pixelRatio: pixelRatio);
//     } else {
//       scene.render(camera, canvas, viewport: Offset.zero & dimensions);
//     }
//     canvas.scale(pixelRatio);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
