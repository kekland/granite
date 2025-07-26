import 'dart:typed_data';

import 'package:granite/controller/utils/http_client.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/spec.dart' as spec;

typedef VectorTileResolverFn = Future<Uint8List> Function(spec.SourceVector source, TileCoordinates coords);

Future<Uint8List> defaultVectorTileResolver(spec.SourceVector source, TileCoordinates coords) async {
  final uri = Uri.parse(
    source.tiles!.first
        .replaceFirst('{x}', coords.x.toString())
        .replaceFirst('{y}', coords.y.toString())
        .replaceFirst('{z}', coords.z.toString()),
  );

  final response = await httpGet(uri);
  return response.bodyBytes;
}
