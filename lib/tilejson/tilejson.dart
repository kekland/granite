import 'gen/tilejson.gen.dart';
export 'gen/tilejson.gen.dart';

/// A class representing a TileJSON object.
///
/// This class can take in any of the supported TileJSON versions:
/// - 1.0.0
/// - 2.0.0
/// - 2.0.1
/// - 2.1.0
/// - 2.2.0
/// - 3.0.0
///
/// and acts as an interface to extract the common properties from different versions.
///
/// See the [$TileJson] class for the raw generated class.
class TileJson {
  const TileJson(this.value);

  factory TileJson.fromJson(Map<String, dynamic> json) {
    return TileJson($TileJson.fromJson(json));
  }

  final $TileJson value;

  String get tilejson => value.tilejson;
  List<String> get tiles => value.tiles;
  String? get attribution => value.attribution;
  String? get version => value.version;
  int? get minzoom => value.minzoom;
  int? get maxzoom => value.maxzoom;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => other is TileJson && value == other.value;
}
