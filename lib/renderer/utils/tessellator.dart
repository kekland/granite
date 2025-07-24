import 'dart:math';
import 'dart:ui' as ui;

import 'package:dart_earcut/dart_earcut.dart' as earcut;
import 'package:granite/vector_tile/vector_tile.dart' as vt;

class Tessellator {
  static List<int> tessellatePolygon(vt.Polygon polygon) {
    final vertices = <ui.Offset>[];
    final holeIndices = <int>[];

    vertices.addAll(polygon.exterior.points);

    for (final interiorRing in polygon.interiors) {
      holeIndices.add(vertices.length);
      vertices.addAll(interiorRing.points);
    }

    return earcut.Earcut.triangulateFromPoints(vertices.map((v) => Point(v.dx, v.dy)), holeIndices: holeIndices);
  }
}
