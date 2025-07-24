// import 'package:flutter_scene/scene.dart';
// import 'package:granite/renderer/core/tile_layer_node.dart';
// import 'package:granite/renderer/core/tile_node.dart';
// import 'package:granite/renderer/renderer.dart';
// import 'package:vector_math/vector_math_64.dart';

// final class RendererRootNode extends Node {
//   RendererRootNode({
//     required this.renderer,
//   });

//   final Renderer renderer;

//   @override
//   void render(SceneEncoder encoder, Matrix4 parentWorldTransform) {
//     for (final layer in renderer.preprocessedStyle.layers.nonNulls) {
//       for (final child in children.whereType<TileNode>()) {
//         child.renderLayer(encoder, parentWorldTransform * localTransform, layer.id);
//       }
//     }
//   }
// }
