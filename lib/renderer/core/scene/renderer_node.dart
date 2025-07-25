import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/core/camera/map_camera.dart';
import 'package:granite/spec/spec.dart' as spec;

import 'package:granite/renderer/renderer.dart';
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

// TODOS:
// - No attach() method in flutter_scene, so if this is detached, it will never be reattached.

final class RendererNode extends scene.Node with ChangeNotifier {
  RendererNode({
    super.name,
    super.localTransform,
    required this.style,
    required this.shaderLibraryProvider,
  }) {
    shaderLibraryProvider.addListener(reassemble);
    initialize();
  }

  final spec.Style style;
  final ShaderLibraryProvider shaderLibraryProvider;

  late PreprocessedStyle _preprocessedStyle;
  PreprocessedStyle get preprocessedStyle => _preprocessedStyle;

  spec.EvaluationContext get baseEvaluationContext => _evalContext;
  var _evalContext = spec.EvaluationContext.empty();

  gpu.Shader? getShader(String name) => shaderLibraryProvider[name];

  /// The tile size.
  static const double kTileSize = 512.0;

  double get pixelRatio => 2.0;

  @override
  void detach() {
    super.detach();
    shaderLibraryProvider.removeListener(reassemble);
  }

  @override
  List<LayerNode> get children => super.children.cast<LayerNode>();

  /// Initializes this renderer and prepares its children.
  void initialize() {
    _preprocessedStyle = StylePreprocessor.preprocess(style);
    for (var i = 0; i < _preprocessedStyle.layers.length; i++) {
      final specLayer = style.layers[i];
      final preprocessedLayer = _preprocessedStyle.layers[i];
      if (preprocessedLayer == null) continue;

      add(createLayerNode(specLayer, preprocessedLayer));
    }
  }

  /// Reassemble can be used to completely rebuild the node and its children.
  ///
  /// This can be called when hot-reloading shaders or styles.
  void reassemble() {
    final oldChildren = List.of(children);
    removeAll();
    initialize();

    // If count of layers is mismatched, we cannot reassemble correctly.
    if (oldChildren.length != children.length) return;

    // Collect old layer data.
    final oldLayers = <TileCoordinates, List<vt.Layer>>{};
    for (final oldLayer in oldChildren) {
      for (final tile in oldLayer.children.whereType<LayerTileNode>()) {
        final coordinates = tile.coordinates;
        final vtLayer = tile.vtLayer;

        oldLayers[coordinates] ??= [];
        oldLayers[coordinates]!.add(vtLayer);
      }
    }

    // Assemble new layers into tiles and add them to the new children.
    final tiles = oldLayers.map((k, v) => MapEntry(k, vt.Tile(layers: v)));
    for (final layer in children) {
      for (final e in tiles.entries) {
        layer.addTile(e.key, e.value);
      }
    }
  }

  void addTile(TileCoordinates coordinates, vt.Tile tile) {
    for (final layer in children) {
      layer.addTile(coordinates, tile);
    }
  }

  @override
  void render(scene.SceneEncoder encoder, vm.Matrix4 parentWorldTransform) {
    final camera = encoder.camera as MapCamera;
    _evalContext = _evalContext.copyWithZoom(camera.zoom);

    super.render(encoder, parentWorldTransform);
  }
}

/// A mixin for scene nodes that are guaranteed to be descendants of a [RendererNode].
base mixin RendererDescendantNode on scene.Node {
  RendererNode? _renderer;
  RendererNode get renderer {
    // Cache the renderer to avoid traversing the tree multiple times.
    if (_renderer != null) return _renderer!;

    var parent = this.parent;

    while (parent != null) {
      if (parent is RendererNode) {
        _renderer = parent;
        return parent;
      }

      parent = parent.parent;
    }

    throw StateError('RendererDescendantNode must be a descendant of a RendererNode');
  }

  @override
  void detach() {
    _renderer = null;
    super.detach();
  }
}

/// A mixin for objects that need to be prepared before rendering.
base mixin Preparable {
  bool _isReady = false;
  bool get isReady => _isReady;

  Future<void> prepare() async {
    if (_isReady) return;
    await prepareImpl();
    _isReady = true;
  }

  Future<void> prepareImpl() async {
    // No-op by default.
  }
}
