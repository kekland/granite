import 'dart:ui' as ui;

/// A class that represents a feature in a vector tile.
///
/// The difference between features in protobuf and features in this library is that the point coordinates are parsed
/// and stored as `ui.Offset` objects, and also attributes are properly mapped to the Dart types.
abstract class Feature {
  const Feature({required this.attributes});

  /// A map of attributes of the feature.
  ///
  /// The keys are the attribute names and the values are the attribute values. The values are guaranteed to be of the
  /// following types:
  /// - `int` (protobuf `int64`, `uint64`, `sint64`)
  /// - `double` (protobuf `double`, `float`)
  /// - `String`
  /// - `bool`
  final Map<String, Object> attributes;
}

/// A class that represents a point feature in a vector tile.
///
/// Can be both a single point or a multi-point feature.
class PointFeature extends Feature {
  const PointFeature({required super.attributes, required this.points});

  final List<ui.Offset> points;

  /// Returns `true` if the feature is a multi-point feature.
  bool get isMultiPoint => points.length > 1;
}

/// A class that represents a line string (i.e. a sequence of connected points).
class LineString {
  const LineString({required this.points});

  final List<ui.Offset> points;
}

/// A class that represents a line string feature in a vector tile.
///
/// Can be both a single line string or a multi-line string feature.
class LineStringFeature extends Feature {
  const LineStringFeature({required super.attributes, required this.lines});

  final List<LineString> lines;

  /// Returns `true` if the feature is a multi-line string feature.
  bool get isMultiLineString => lines.length > 1;
}

/// A class that represents a ring (i.e. a closed line string).
class Ring {
  const Ring({required this.points, required this.isClockwise});

  final List<ui.Offset> points;

  /// Whether the ring is clockwise or not.
  ///
  /// Clockwise rings are considered to be the exterior rings of polygons, while counter-clockwise rings are considered
  /// to be the interior rings (holes) of polygons.
  final bool isClockwise;
}

/// A class that represents a polygon (i.e. a single exterior ring and zero or more interior rings/holes).
class Polygon {
  const Polygon({required this.exterior, required this.interiors});

  final Ring exterior;
  final List<Ring> interiors;
}

/// A class that represents a polygon feature in a vector tile.
///
/// Can be both a single polygon or a multi-polygon feature.
class PolygonFeature extends Feature {
  const PolygonFeature({required super.attributes, required this.polygons});

  final List<Polygon> polygons;

  /// Returns `true` if the feature is a multi-polygon feature.
  bool get isMultiPolygon => polygons.length > 1;
}
