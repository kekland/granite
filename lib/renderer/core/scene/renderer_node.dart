import 'dart:isolate';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/core/camera/light_camera.dart';
import 'package:granite/renderer/core/gpu/customizable_surface.dart';
import 'package:granite/renderer/core/gpu/stencil_ref_buffer.dart';
import 'package:granite/renderer/core/scene/tile_stencil_node.dart';
import 'package:granite/renderer/isolates/isolates.dart';
import 'package:granite/spec/spec.dart' as spec;

import 'package:granite/renderer/renderer.dart';
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

  late List<PreprocessedLayer> _preprocessedLayers;
  List<PreprocessedLayer> get preprocessedLayers => _preprocessedLayers;

  spec.EvaluationContext get baseEvaluationContext => _evalContext;
  var _evalContext = spec.EvaluationContext.empty();

  gpu.Shader? getShader(String name) => shaderLibraryProvider[name];

  static const double kTileSize = 512.0;
  static const int kTileExtent = 4096;

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
    isolates.spawn();

    _preprocessedStyle = StylePreprocessor.preprocess(style);
    _preprocessedLayers = _preprocessedStyle.layers.nonNulls.toList();
    for (var i = 0; i < _preprocessedStyle.layers.length; i++) {
      final specLayer = style.layers[i];
      final preprocessedLayer = _preprocessedStyle.layers[i];
      if (preprocessedLayer == null) continue;

      add(createLayerNode(specLayer, preprocessedLayer));
    }
  }

  final isolates = Isolates();

  /// Reassemble can be used to completely rebuild the node and its children.
  ///
  /// This can be called when hot-reloading shaders or styles.
  void reassemble() {
    final oldChildren = List.of(children);
    removeAll();
    initialize();

    // TODO: do this later.
    // // If count of layers is mismatched, we cannot reassemble correctly.
    // if (oldChildren.length != children.length) return;

    // // Collect old layer data.
    // final oldTiles = <TileCoordinates, Uint8List>{};
    // for (final oldLayer in oldChildren) {
    //   for (final tile in oldLayer.children.whereType<LayerTileNode>()) {
    //     final coordinates = tile.coordinates;
    //     final vtData = tile.vtData;
    //     oldTiles[coordinates] = vtData;
    //   }
    // }

    // // Assemble new layers into tiles and add them to the new children.
    // for (final MapEntry(key: coords, value: vtData) in oldTiles.entries) {
    //   addTile(coords, vtData);
    // }
  }

  Future<List<GeometryData?>> computeTileGeometryDatas(TileCoordinates coords, Uint8List vtData) async {
    return isolates.layerTileGeometry.execute((
      evalContext: baseEvaluationContext.copyWithZoom(coords.z.toDouble()),
      preprocessedLayers: _preprocessedLayers,
      style: style,
      vtData: TransferableTypedData.fromList([vtData]),
    ));
  }

  final _stencilRefBuffer = StencilRefBuffer();
  final _tileStencilRefs = <TileCoordinates, int>{};
  int getTileStencilRef(TileCoordinates coords) => _tileStencilRefs[coords]!;

  Future<void> addTile(TileCoordinates coords, List<GeometryData?> geometryDatas) async {
    _tileStencilRefs[coords] = _stencilRefBuffer.allocate();
    for (var i = 0; i < geometryDatas.length; i++) {
      final layer = children[i];
      final geometryData = geometryDatas[i];
      layer.addTile(coords, geometryData);
    }
  }

  void removeTile(TileCoordinates coords) {
    final value = _tileStencilRefs.remove(coords)!;
    _stencilRefBuffer.deallocate(value);

    for (final layer in children) {
      layer.removeTile(coords);
    }
  }

  final _shadowPassSurface = CustomizableSurface();
  final _shadowMapSize = ui.Size(2048, 2048);
  gpu.Texture get shadowMapTexture =>
      _shadowPassSurface.getNextRenderTarget(_shadowMapSize, false).depthStencilAttachment!.texture;

  vm.Matrix4 get lightCameraVp => _lightCameraVp;
  var _lightCameraVp = vm.Matrix4.identity();

  bool get isShadowPass => _isShadowPass;
  var _isShadowPass = false;

  List<TileCoordinates> get tileCoordinates => children
      .expand((l) => l.children)
      .map((v) => v.coordinates)
      .toSet()
      .toList()
      .sorted((a, b) => a.z.compareTo(b.z));

  void _performShadowPass(scene.Camera mainCamera, vm.Matrix4 parentWorldTransform) {
    _isShadowPass = true;

    // Compute light
    final light = style.light ?? spec.Light.withDefaults();
    final lightPosition = light.position.evaluate(baseEvaluationContext);
    final a = lightPosition.y * vm.degrees2Radians;
    final p = lightPosition.z * vm.degrees2Radians;
    final lightDirection = vm.Vector3(cos(a) * sin(p), sin(a) * sin(p), cos(p));

    // First up - shadow pass.
    // We create a new camera and an encoder, and render everything into that pass.
    final shadowPassRenderTarget = _shadowPassSurface.getNextRenderTarget(_shadowMapSize, false);
    final lightCamera = LightCamera(
      mainCamera: mainCamera,
      direction: vm.Vector3(-lightDirection.x, -lightDirection.y, lightDirection.z),
    );
    final shadowPassEncoder = scene.SceneEncoder(
      shadowPassRenderTarget,
      lightCamera,
      _shadowMapSize,
      scene.Environment(),
    );

    _lightCameraVp = shadowPassEncoder.cameraTransform;

    for (final c in children.whereType<FillExtrusionLayerNode>()) {
      c.render(shadowPassEncoder, parentWorldTransform);
    }

    shadowPassEncoder.finish();
    _isShadowPass = false;
  }

  void _performStencilPass(scene.SceneEncoder encoder, vm.Matrix4 parentWorldTransform) {
    for (final c in tileCoordinates) {
      final stencilNode = TileStencilNode(renderer: this, coordinates: c);
      stencilNode.render(encoder, parentWorldTransform);
    }
  }

  void _performForwardPass(scene.SceneEncoder encoder, vm.Matrix4 parentWorldTransform) {
    super.render(encoder, parentWorldTransform);
  }

  ui.Size get lastDimensions => _lastDimensions;
  late ui.Size _lastDimensions;

  @override
  void render(scene.SceneEncoder encoder, vm.Matrix4 parentWorldTransform) {
    final camera = encoder.camera as ResolvedMapCamera;
    _evalContext = _evalContext.copyWithZoom(camera.zoom);
    _lastDimensions = encoder.dimensions;

    _performShadowPass(camera, parentWorldTransform);
    _performStencilPass(encoder, parentWorldTransform);
    _performForwardPass(encoder, parentWorldTransform);

    // final stencilTexture = encoder.renderTarget.depthStencilAttachment!.texture;
    // final stencilImage = stencilTexture.asImage();

    // encoder.encode(
    //   vm.Matrix4.identity(),
    //   TextureGeometry(renderer: this),
    //   TextureMaterial(renderer: this, texture: stencilTexture, opacity: 0.5),
    // );
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
