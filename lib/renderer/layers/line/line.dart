import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/renderer/utils/filter_features.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

final class LineLayerNode extends LayerNode<spec.LayerLine> {
  LineLayerNode({required super.specLayer, required super.preprocessedLayer});

  @override
  LayerTileNode createLayerTileNode(TileCoordinates coordinates, vt.Layer vtLayer) =>
      LineLayerTileNode(coordinates: coordinates, vtLayer: vtLayer);
}

final class LineLayerTileNode extends LayerTileNode<spec.LayerLine, LineLayerNode> {
  LineLayerTileNode({required super.coordinates, required super.vtLayer});

  @override
  void setGeometryAndMaterial() {
    geometry = LineLayerTileGeometry(node: this);
    material = LineLayerTileMaterial(node: this);
  }
}

final class LineLayerTileGeometry extends LayerTileGeometry<LineLayerTileNode> {
  LineLayerTileGeometry({required super.node});

  @override
  Future<void> prepare() async {
    final vtLayer = node.vtLayer;
    final specLayer = node.specLayer;
    final evalContext = renderer.baseEvaluationContext.copyWithZoom(node.coordinates.z.toDouble());

    final features = filterFeatures<vt.LineStringFeature>(
      vtLayer,
      specLayer,
      evalContext,
      sortKey: specLayer.layout.lineSortKey,
    );

    if (features.isEmpty) {
      isEmpty = true;
      return;
    }

    // TODO: this has to be evaluated per-feature.
    final lineCap = specLayer.layout.lineCap.evaluate(evalContext);
    const _kLineCapRoundSegments = 16;

    // TODO:
    // final lineJoin = specLayer.layout.lineJoin.evaluate(context.eval);
    // final miterLimit = specLayer.layout.lineMiterLimit.evaluate(context.eval);
    // final roundLimit = specLayer.layout.lineRoundLimit.evaluate(context.eval);

    // Contains the list of (position, normal, lineLength) for each vertex, grouped by feature.
    final vertexData = <List<(vm.Vector2 position, vm.Vector2 normal, double lineLength)>>[];
    final indices = <int>[];
    var vertexCount = 0;
    var currentLength = 0.0;

    void _addRelativeIndices(List<int> idx) {
      indices.addAll(idx.map((i) => i + vertexCount));
    }

    // Add cap going from a to b.
    void _addCap(vm.Vector2 a, vm.Vector2 b) {
      if (lineCap == spec.LayoutLine$LineCap.butt) return;

      final t = (b - a)..normalize();
      final n = vm.Vector2(t.y, -t.x);

      if (lineCap == spec.LayoutLine$LineCap.square) {
        _addRelativeIndices([0, 2, 1, 2, 0, 3]);

        vertexData.last.add((a, n, currentLength));
        vertexData.last.add((a, -n, currentLength));

        vertexData.last.add((a, t + n, currentLength));
        vertexData.last.add((a, t - n, currentLength));

        vertexCount += 4;
      } else if (lineCap == spec.LayoutLine$LineCap.round) {
        final center = a;
        final startAngle = math.atan2(-n.y, -n.x);

        vertexData.last.add((center, vm.Vector2.zero(), currentLength));
        final centerIndex = vertexCount;

        for (var i = 0; i <= _kLineCapRoundSegments; i++) {
          final angle = startAngle + i / _kLineCapRoundSegments * math.pi;
          final vec = vm.Vector2(math.cos(angle), math.sin(angle));

          vertexData.last.add((center, vec, currentLength));
        }

        for (var i = 0; i < _kLineCapRoundSegments; i++) {
          indices.addAll([centerIndex, centerIndex + i + 1, centerIndex + i + 2]);
        }

        vertexCount += _kLineCapRoundSegments + 2;
      }
    }

    // Add single line segment from a to b.
    void _addSegment(vm.Vector2 a, vm.Vector2 b) {
      final t = b - a;
      final n = vm.Vector2(t.y, -t.x)..normalize();

      _addRelativeIndices([0, 2, 1, 1, 2, 3]);

      vertexData.last.add((a, n, currentLength));
      vertexData.last.add((a, -n, currentLength));

      currentLength += t.length;

      vertexData.last.add((b, n, currentLength));
      vertexData.last.add((b, -n, currentLength));

      vertexCount += 4;
    }

    // Add join at c, from a to b.
    void _addJoin(vm.Vector2 c, vm.Vector2 a, vm.Vector2 b) {
      final ac = c - a;
      final cb = b - c;

      var na = vm.Vector2(ac.y, -ac.x)..normalize();
      var nb = vm.Vector2(cb.y, -cb.x)..normalize();

      // check direction
      final cross = ac.x * cb.y - ac.y * cb.x;
      final direction = cross < 0 ? -1.0 : 1.0;

      na *= direction;
      nb *= direction;

      // TODO: Miter, round joins
      // clockwise winding order
      _addRelativeIndices(cross <= 0 ? [0, 2, 1] : [1, 0, 2]);

      vertexData.last.add((c, vm.Vector2.zero(), currentLength));
      vertexData.last.add((c, na, currentLength));
      vertexData.last.add((c, nb, currentLength));

      vertexCount += 3;
    }

    for (final feature in features) {
      vertexData.add([]);

      // Line consists of:
      // Cap - Segment - Join - Segment - Join - ... - Segment - Cap
      for (final line in feature.lines) {
        if (line.points.length < 2) continue;

        _addCap(line.points[0], line.points[1]);

        for (var i = 0; i < line.points.length - 1; i++) {
          if (i != 0) {
            _addJoin(line.points[i], line.points[i - 1], line.points[i + 1]);
          }

          _addSegment(line.points[i], line.points[i + 1]);
        }

        _addCap(line.points[line.points.length - 1], line.points[line.points.length - 2]);

        currentLength = 0.0;
      }
    }

    const staticBytesPerVertex = 16;
    final bytesPerVertex = staticBytesPerVertex + vertexProps.lengthInBytes;
    final vertexByteData = ByteData(bytesPerVertex * vertexCount);
    void setVertex(
      int index, {
      required vm.Vector2 position,
      required vm.Vector2 normal,
    }) {
      var offset = index * bytesPerVertex;
      offset = vertexByteData.setVec2(offset, position);
      offset = vertexByteData.setVec2(offset, normal);
      offset = vertexByteData.setByteData(offset, vertexProps.data);
    }

    var vertexIndex = 0;
    for (var i = 0; i < vertexData.length; i++) {
      final feature = features[i];
      vertexProps.compute(evalContext.forFeature(feature), specLayer);

      for (var j = 0; j < vertexData[i].length; j++) {
        final (position, normal, lineLength) = vertexData[i][j];
        setVertex(vertexIndex, position: position, normal: normal);
        vertexIndex++;
      }
    }

    uploadVertexData(
      vertexByteData,
      vertexCount,
      Uint32List.fromList(indices).buffer.asByteData(),
      indexType: gpu.IndexType.int32,
    );
  }
}

final class LineLayerTileMaterial extends LayerTileMaterial<LineLayerTileNode> {
  LineLayerTileMaterial({required super.node});

  @override
  void bind(gpu.RenderPass pass, gpu.HostBuffer transientsBuffer, scene.Environment environment) {
    super.bind(pass, transientsBuffer, environment);
    pass.setDepthWriteEnable(false);
    pass.setDepthCompareOperation(gpu.CompareFunction.always);
  }
}
