// TODO: keeping this here for now

// import 'package:flutter/foundation.dart';
// import 'package:flutter_gpu/gpu.dart' as gpu;
// import 'package:flutter_scene/scene.dart' as scene;
// import 'package:granite/renderer/core/gpu/shader_library_provider.dart';
// import 'package:granite/renderer/isolates/isolates.dart';
// import 'package:granite/renderer/layers/layers.dart';
// import 'package:granite/renderer/preprocessor/preprocessor.dart';
// import 'package:granite/spec/spec.dart' as spec;

// base class RendererScene extends scene.Scene with ChangeNotifier {
//   RendererScene({
//     required this.style,
//     required this.shaderLibraryProvider,
//   });

//   final spec.Style style;
//   final ShaderLibraryProvider shaderLibraryProvider;

//   late PreprocessedStyle _preprocessedStyle;
//   PreprocessedStyle get preprocessedStyle => _preprocessedStyle;

//   late List<PreprocessedLayer> _preprocessedLayers;
//   List<PreprocessedLayer> get preprocessedLayers => _preprocessedLayers;

//   spec.EvaluationContext get evalContext => _evalContext;
//   var _evalContext = spec.EvaluationContext.empty();

//   static const double kTileSize = 512.0;
//   static const int kTileExtent = 4096;

//   final isolates = Isolates();

//   gpu.Shader? getShader(String name) => shaderLibraryProvider[name];

//   void reassemble() {}

//   Future<void> initialize() async {
//     final root = RendererRootNode(renderer: this);
//     root.registerAsRoot(this);

//     await isolates.spawn();

//     _preprocessedStyle = StylePreprocessor.preprocess(style);
//     _preprocessedLayers = _preprocessedStyle.layers.nonNulls.toList();
//     for (var i = 0; i < _preprocessedStyle.layers.length; i++) {
//       final specLayer = style.layers[i];
//       final preprocessedLayer = _preprocessedStyle.layers[i];
//       if (preprocessedLayer == null) continue;

//       add(createLayerNode(specLayer, preprocessedLayer));
//     }
//   }
// }

// base class RendererRootNode extends scene.Node {
//   RendererRootNode({required this.renderer});

//   final RendererScene renderer;
// }

// base mixin RendererDescendantNode on scene.Node {
//   RendererScene? _renderer;
//   RendererScene get renderer {
//     // Cache the renderer to avoid traversing the tree multiple times.
//     if (_renderer != null) return _renderer!;

//     var parent = this.parent;

//     while (parent != null) {
//       if (parent is RendererRootNode) {
//         _renderer = parent.renderer;
//         return _renderer!;
//       }

//       parent = parent.parent;
//     }

//     throw StateError('RendererDescendantNode must be a descendant of a RendererNode');
//   }

//   @override
//   void detach() {
//     _renderer = null;
//     super.detach();
//   }
// }
