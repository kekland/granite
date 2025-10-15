import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:granite/controller/resolvers/glyphs_resolver.dart';
import 'package:granite/controller/resolvers/source_resolver.dart';
import 'package:granite/controller/resolvers/tile_resolver.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:quiver/cache.dart';

class MapController extends ChangeNotifier {
  MapController({
    required spec.Style style,
    required ShaderLibraryProvider shaderLibraryProvider,
    MapCamera? initialCamera,
    double pixelRatio = 1.0,
    this.sourceResolver = defaultSourceResolver,
    this.vectorTileResolver = defaultVectorTileResolver,
    this.glyphsResolver = defaultGlyphsResolver,
  }) : _style = style {
    scene = RendererScene(
      style: style,
      shaderLibraryProvider: shaderLibraryProvider,
      glyphsResolver: (fontStack, rangeFrom) => glyphsResolver(style.glyphs!, fontStack, rangeFrom),
    );

    _camera = initialCamera ?? MapCamera.zero;
    _pixelRatio = pixelRatio;
    _initialize();
  }

  spec.Style get style => _style;
  spec.Style _style;

  late final RendererScene scene;

  final SourceResolverFn sourceResolver;
  final VectorTileResolverFn vectorTileResolver;
  final GlyphsResolverFn glyphsResolver;

  late MapCamera _camera;
  MapCamera get camera => _camera;
  set camera(MapCamera value) {
    if (_camera != value) {
      _camera = value;
      _onCameraChanged();
      notifyListeners();
    }
  }

  late double _pixelRatio;
  double get pixelRatio => _pixelRatio;
  set pixelRatio(double value) {
    if (_pixelRatio != value) {
      _pixelRatio = value;
      _onCameraChanged();
      // notifyListeners();
    }
  }

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> _initialize() async {
    await _loadSources();

    _isLoaded = true;
    notifyListeners();

    _onCameraChanged();
  }

  Future<void> _loadSources() async {
    final resolvedSources = Map.fromIterables(
      style.sources.keys,
      await style.sources.values.map(sourceResolver).wait,
    );

    _style = _style.copyWith(sources: resolvedSources);

    for (final sourceId in resolvedSources.keys) {
      _sourceRequestedTiles[sourceId] = {};
      _sourceVisibleTiles[sourceId] = {};
      _sourceLoadingTiles[sourceId] = {};
    }
  }

  final _sourceRequestedTiles = <Object, Set<TileCoordinates>>{};
  final _sourceVisibleTiles = <Object, Set<TileCoordinates>>{};
  final _sourceLoadingTiles = <Object, Set<TileCoordinates>>{};

  Future<void> _onCameraChanged() async {
    if (!_isLoaded) return;

    final resolvedCamera = _camera.resolve(_pixelRatio);
    final zoom = resolvedCamera.zoom;

    for (final MapEntry(key: id, value: source) in style.sources.entries) {
      if (source is! spec.SourceVector) continue;
      if (source.tiles == null) continue;

      final sourceZoom = zoom.clamp(source.minzoom, source.maxzoom).floor();
      final requestedTiles = resolvedCamera.computeVisibleTiles(scene.renderer.lastDimensions, zoom: sourceZoom);
      _sourceRequestedTiles[id] = requestedTiles;

      for (final coords in requestedTiles) _maybeLoadTile(id, coords);

      final tilesToRemove = _sourceVisibleTiles[id]!.difference(requestedTiles);
      for (final coords in tilesToRemove) {
        scene.renderer.removeTile(coords);
        _sourceVisibleTiles[id]!.remove(coords);
      }
    }
  }

  final _tileCache = MapCache<TileCoordinates, (vt.Tile, List<GeometryData?>)>.lru(maximumSize: 100);

  Future<void> _maybeLoadTile(Object sourceId, TileCoordinates coords) async {
    if (_sourceLoadingTiles[sourceId]!.contains(coords)) return;
    if (_sourceVisibleTiles[sourceId]!.contains(coords)) return;
    final _cached = await _tileCache.get(coords);
    if (_cached != null) {
      scene.renderer.addTile(coords, _cached.$2, _cached.$1);
      _sourceVisibleTiles[sourceId]!.add(coords);
      notifyListeners();
      return;
    }

    _sourceLoadingTiles[sourceId]!.add(coords);

    final source = style.sources[sourceId]!;
    final vtData = await vectorTileResolver(source as spec.SourceVector, coords);
    final vtTile = vt.decodeTileFromBytes(vtData);
    final geometryDatas = await scene.renderer.computeTileGeometryDatas(coords, vtData);
    await _tileCache.set(coords, (vtTile, geometryDatas));

    if (_sourceRequestedTiles[sourceId]!.contains(coords)) {
      scene.renderer.addTile(coords, geometryDatas, vtTile);
      _sourceVisibleTiles[sourceId]!.add(coords);
      notifyListeners();
    }

    _sourceLoadingTiles[sourceId]!.remove(coords);
  }

  void render(ui.Canvas canvas, {ui.Rect? viewport}) {
    scene.render(camera, canvas, viewport: viewport, pixelRatio: pixelRatio);
  }
}
