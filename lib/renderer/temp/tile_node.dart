// import 'dart:math';

// import 'package:flutter_scene/scene.dart';
// import 'package:granite/renderer/core/tile_layer_node.dart';
// import 'package:granite/renderer/renderer.dart';
// import 'package:granite/vector_tile/vector_tile.dart' as vt;
// import 'package:vector_math/vector_math_64.dart';

// Matrix4 _localTransformFromCoordinates(TileCoordinates coordinates) {
//   // 0, 0, 0 -> Identity

//   final scale = pow(2.0, -coordinates.z).toDouble();
//   final offsetX = coordinates.x * 4096.0;
//   final offsetY = coordinates.y * 4096.0;

//   return Matrix4.diagonal3Values(scale, scale, scale)..translateByDouble(offsetX, offsetY, 0.0, 1.0);
// }

// base class TileNode extends Node {
//   TileNode({
//     required this.renderer,
//     required this.tile,
//     required this.coordinates,
//   }) : super(
//          localTransform: _localTransformFromCoordinates(coordinates),
//        );

//   final Renderer renderer;
//   final vt.Tile tile;
//   final TileCoordinates coordinates;

//   bool get isReadyToRender => !children.any((v) => v is TileLayerNode && !v.isReadyToRender);

//   Future<void> prepare() async {
//     if (isReadyToRender) return;
//     await children.whereType<TileLayerNode>().map((v) => v.prepare()).wait;
//   }

//   void renderLayer(SceneEncoder encoder, Matrix4 parentWorldTransform, String layerId) {
//     for (final layer in children.whereType<TileLayerNode>()) {
//       if (!layer.isReadyToRender) continue;
//       if (layer.specLayer.id != layerId) continue;

//       final worldTransform = parentWorldTransform * layer.localTransform;
//       layer.render(encoder, worldTransform);
//     }
//   }
// }
