import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart';

extension PolygonExtensions on vt.Polygon {
  int get vertexCount {
    var count = exterior.points.length;

    for (final interior in interiors) {
      count += interior.points.length;
    }

    return count;
  }

  Iterable<ui.Offset> get vertices sync* {
    yield* exterior.points;

    for (final interior in interiors) {
      yield* interior.points;
    }
  }
}

extension PolygonListExtensions on List<vt.Polygon> {
  int get vertexCount {
    var count = 0;

    for (final polygon in this) {
      count += polygon.vertexCount;
    }

    return count;
  }
}

extension OffsetExt on Offset {
  Vector2 get vec2 => Vector2(dx, dy);
}
