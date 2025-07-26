import 'dart:typed_data';

import 'package:vector_math/vector_math_64.dart' as vm;
import 'gen/vector_tile.pb.dart' as proto;
import 'vector_tile.dart' as vt;

/// Decodes a protobuf Tile object into a [TileData] object.
vt.Tile decodeTile(proto.Tile tile) {
  return vt.Tile(layers: tile.layers.map(decodeLayer).toList());
}

vt.Tile decodeTileFromBytes(Uint8List bytes) {
  final tile = proto.Tile.fromBuffer(bytes);
  return decodeTile(tile);
}

/// Unwraps a protobuf Tile_Value object into a Dart primitive.
Object _decodeProtoValue(proto.Tile_Value value) {
  // dart format off

  if (value.hasStringValue()) return value.stringValue;
  else if (value.hasFloatValue()) return value.floatValue;
  else if (value.hasDoubleValue()) return value.doubleValue;
  else if (value.hasIntValue()) return value.intValue.toInt();
  else if (value.hasUintValue()) return value.uintValue.toInt();
  else if (value.hasSintValue()) return value.sintValue.toInt();
  else if (value.hasBoolValue()) return value.boolValue;
  else throw ArgumentError('Unknown value type');

  // dart format on
}

/// Decodes a protobuf Tile_Layer object into a [LayerData] object.
vt.Layer decodeLayer(proto.Tile_Layer layer) {
  final attributeKeys = layer.keys;
  final attributeValues = layer.values.map(_decodeProtoValue).toList();

  return vt.Layer(
    version: layer.version,
    name: layer.name,
    extent: layer.extent,
    features: layer.features.map((f) => decodeFeature(f, attributeKeys, attributeValues)).toList(),
  );
}

/// Decodes a protobuf Tile_Feature object into a [Feature] object. The keys and values are used to map the attribute
/// indices (from the feature tags) to the actual attributes.
vt.Feature decodeFeature(proto.Tile_Feature feature, List<String> keys, List<Object> values) {
  final featureAttributes = <String, Object>{};

  for (var i = 0; i < feature.tags.length; i += 2) {
    final keyIndex = feature.tags[i];
    final valueIndex = feature.tags[i + 1];

    final key = keys[keyIndex];
    final value = values[valueIndex];

    featureAttributes[key] = value;
  }

  return switch (feature.type) {
    proto.Tile_GeomType.POINT => decodePointFeature(feature, featureAttributes),
    proto.Tile_GeomType.LINESTRING => decodeLineStringFeature(feature, featureAttributes),
    proto.Tile_GeomType.POLYGON => parsePolygonFeature(feature, featureAttributes),
    _ => throw ArgumentError('Unknown geometry type: ${feature.type}'),
  };
}

const _commandMoveTo = 1;
const _commandLineTo = 2;
const _commandClosePath = 7;

int _parameterInteger(int v) => ((v >> 1) ^ (-(v & 1)));

/// Decodes a list of geometry commands into a list of points.
///
/// The [geometry] list contains a list of commands and parameters. See the Vector Tile specification for more details.
///
/// [callback] is called for each command in the geometry. The [type] parameter is the command type, and [point] is the
/// current cursor position.
void _withGeometry(List<int> geometry, void Function(int type, vm.Vector2 point) callback) {
  var cursor = vm.Vector2.zero();

  var i = 0;
  while (i < geometry.length) {
    final value = geometry[i];

    final id = value & 0x7;
    final count = value >> 3;

    i += 1;
    for (var j = 0; j < count; j++) {
      if (id == _commandMoveTo) {
        cursor = cursor + vm.Vector2(
          _parameterInteger(geometry[i]).toDouble(),
          _parameterInteger(geometry[i + 1]).toDouble(),
        );

        i += 2;
      } else if (id == _commandLineTo) {
        cursor = cursor + vm.Vector2(
          _parameterInteger(geometry[i]).toDouble(),
          _parameterInteger(geometry[i + 1]).toDouble(),
        );

        i += 2;
      } else if (id == _commandClosePath) {
        // No-op
      } else {
        throw ArgumentError('Unknown command ID: $id');
      }

      callback(id, cursor);
    }
  }
}

/// Decodes a protobuf Tile_Feature object into a [PointFeature] object.
vt.PointFeature decodePointFeature(proto.Tile_Feature feature, Map<String, Object> attributes) {
  assert(feature.type == proto.Tile_GeomType.POINT);

  final points = <vm.Vector2>[];

  // Each move-to command is a single point.
  _withGeometry(feature.geometry, (type, point) {
    assert(type == _commandMoveTo);
    points.add(point);
  });

  return vt.PointFeature(attributes: attributes, points: points);
}

/// Decodes a protobuf Tile_Feature object into a [LineStringFeature] object.
vt.LineStringFeature decodeLineStringFeature(proto.Tile_Feature feature, Map<String, Object> attributes) {
  assert(feature.type == proto.Tile_GeomType.LINESTRING);

  final lines = <vt.LineString>[];

  // move-to represents the start of a new line string.
  // line-to represents the continuation of the current line string.
  _withGeometry(feature.geometry, (type, point) {
    assert(type == _commandMoveTo || type == _commandLineTo);

    if (type == _commandMoveTo) {
      lines.add(vt.LineString(points: [point]));
    } else if (type == _commandLineTo) {
      lines.last.points.add(point);
    }
  });

  return vt.LineStringFeature(attributes: attributes, lines: lines);
}

/// Calculates the area of a polygon using the shoelace formula.
double _shoelaceFormula(List<vm.Vector2> points) {
  var area = 0.0;

  final length = points.length;
  for (var i = 0; i < length; i++) {
    final previousI = i == 0 ? length - 1 : i - 1;
    final nextI = i == length - 1 ? 0 : i + 1;

    area += points[i].y * (points[previousI].x - points[nextI].x);
  }

  return area.toDouble() / 2;
}

/// Decodes a protobuf Tile_Feature object into a [PolygonFeature] object.
vt.PolygonFeature parsePolygonFeature(proto.Tile_Feature feature, Map<String, Object> attributes) {
  assert(feature.type == proto.Tile_GeomType.POLYGON);

  final polygons = <vt.Polygon>[];

  final pointsBuffer = <vm.Vector2>[];
  vt.Ring? exterior;
  final interiors = <vt.Ring>[];

  // Flush the current [exterior] and [interiors] rings into a polygon.
  void _flushPolygon() {
    polygons.add(vt.Polygon(exterior: exterior!, interiors: List.of(interiors)));
    interiors.clear();
  }

  // move-to and line-to commands are used to define the polygon rings' points.
  // close-to commands are used to define the end of a ring:
  // - if the ring is clockwise, it is considered the exterior ring. if there is already an exterior ring set, flush
  //   the current polygon and start a new one.
  // - if the ring is counter-clockwise, it is considered an interior ring. add it to the [interiors] list.
  _withGeometry(feature.geometry, (type, point) {
    if (type == _commandMoveTo || type == _commandLineTo) {
      pointsBuffer.add(point);
    } else if (type == _commandClosePath) {
      final isClockwise = _shoelaceFormula(pointsBuffer) > 0;

      final ring = vt.Ring(points: List.of(pointsBuffer), isClockwise: isClockwise);
      pointsBuffer.clear();

      if (isClockwise) {
        if (exterior != null) _flushPolygon();
        exterior = ring;
      } else {
        interiors.add(ring);
      }
    }
  });

  if (exterior != null) _flushPolygon();
  return vt.PolygonFeature(attributes: attributes, polygons: polygons);
}
