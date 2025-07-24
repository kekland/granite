import 'dart:math';

import 'package:dart_earcut/dart_earcut.dart' as earcut;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

class Tessellator {
  static List<int> tessellatePolygon(vt.Polygon polygon) {
    final vertices = <vm.Vector2>[];
    final holeIndices = <int>[];

    vertices.addAll(polygon.exterior.points);

    for (final interiorRing in polygon.interiors) {
      holeIndices.add(vertices.length);
      vertices.addAll(interiorRing.points);
    }

    return earcut.Earcut.triangulateFromPoints(vertices.map((v) => Point(v.x, v.y)), holeIndices: holeIndices);
  }
}
