import 'dart:convert';

import 'package:granite/controller/utils/http_client.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/tilejson/tilejson.dart' as tilejson;

typedef SourceResolverFn = Future<spec.Source> Function(spec.Source source);

Future<spec.Source> defaultSourceResolver(spec.Source source) async {
  return switch (source) {
    spec.SourceVector vector => _defaultVectorSourceResolver(vector),
    _ => source,
  };
}

Future<spec.SourceVector> _defaultVectorSourceResolver(spec.SourceVector source) async {
  if (source.tiles != null) return source;

  // If tiles are missing, try to load the TileJSON spec.
  if (source.url != null) {
    final tileJson = await _loadTileJson(Uri.parse(source.url!));
    return source.copyWith(tiles: tileJson.tiles, minzoom: tileJson.minzoom, maxzoom: tileJson.maxzoom);
  }

  // This means that the source doesn't have tiles.
  return source;
}

Future<tilejson.TileJson> _loadTileJson(Uri uri) async {
  final response = await httpGet(uri);
  return tilejson.TileJson.fromJson(jsonDecode(response.body));
}
