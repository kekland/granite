import 'dart:isolate';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/glyphs/glyphs.dart' as glyphs;
import 'package:granite/renderer/core/atlas/glyph_atlas.dart';
import 'package:granite/renderer/core/camera/light_camera.dart';
import 'package:granite/renderer/core/gpu/customizable_surface.dart';
import 'package:granite/renderer/core/gpu/stencil_ref_buffer.dart';
import 'package:granite/renderer/core/scene/tile_stencil_node.dart';
import 'package:granite/renderer/isolates/isolates.dart';
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
    required this.glyphsResolver,
  }) {
    shaderLibraryProvider.addListener(reassemble);
    initialize();
  }

  final spec.Style style;
  final ShaderLibraryProvider shaderLibraryProvider;
  final Future<glyphs.Glyphs> Function(String fontStack, int rangeFrom) glyphsResolver;

  late PreprocessedStyle _preprocessedStyle;
  PreprocessedStyle get preprocessedStyle => _preprocessedStyle;

  late List<PreprocessedLayer> _preprocessedLayers;
  List<PreprocessedLayer> get preprocessedLayers => _preprocessedLayers;

  spec.EvaluationContext get baseEvaluationContext => _evalContext;
  var _evalContext = spec.EvaluationContext.empty();

  gpu.Shader? getShader(String name) => shaderLibraryProvider[name];

  static const double kTileSize = 512.0;
  static const int kTileExtent = 4096;

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

    // TODO: bring this back later.
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

  Future<void> addTile(TileCoordinates coords, List<GeometryData?> geometryDatas, vt.Tile? vtTile) async {
    _tileStencilRefs[coords] = _stencilRefBuffer.allocate();
    for (var i = 0; i < geometryDatas.length; i++) {
      final layer = children[i];
      final geometryData = geometryDatas[i];

      final vtLayerName = layer.specLayer.sourceLayer;
      final vtLayer = vtTile?.layers.firstWhereOrNull((v) => v.name == vtLayerName);
      layer.addTile(coords, geometryData, vtLayer);
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

  // ----------------------------------------------------------------------------------------------------------------
  // Glyphs
  // ----------------------------------------------------------------------------------------------------------------
  final _resolvingFutures = <(String, int), Future>{};
  Future<dynamic> _resolveAndPutMissingGlyphs(String fontStack, Iterable<int> missingGlyphRanges) async {
    final futures = <Future>[];

    for (final r in missingGlyphRanges) {
      final key = (fontStack, r);
      if (_resolvingFutures.containsKey(key)) {
        futures.add(_resolvingFutures[key]!);
        continue;
      }

      print('resolving: $fontStack, $r');
      final future = glyphsResolver(fontStack, r).then(glyphAtlas.putGlyphs);
      _resolvingFutures[key] = future;
      futures.add(future);
    }

    return futures.wait;
  }

  final glyphAtlas = GlyphAtlas(width: 2048, height: 2048);
  Future<List<GlyphData?>> getGlyphsForText(String fontStack, String text) async {
    final missingGlyphRanges = <int>{};

    for (final rune in text.runes) {
      if (!glyphAtlas.contains(fontStack, rune)) missingGlyphRanges.add((rune ~/ 256) * 256);
    }

    // Load missing glyphs
    await _resolveAndPutMissingGlyphs(fontStack, missingGlyphRanges);

    final result = <GlyphData?>[];
    for (final rune in text.runes) {
      final data = glyphAtlas.getGlyphData(fontStack, rune);
      result.add(data);
    }

    return result;
  }

  Future<List<GlyphData?>> getGlyphsForFormatted(String fontStack, spec.Formatted formatted) async {
    final result = <GlyphData?>[];

    for (final section in formatted.sections) {
      if (section.text != null) {
        final glyphs = await getGlyphsForText(section.fontStack ?? fontStack, section.text!);
        result.addAll(glyphs);
      }
    }

    return result;
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
