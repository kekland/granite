import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:granite/renderer/core/props/uniform_props.dart';
import 'package:granite/renderer/core/props/vertex_props.dart';
import 'package:granite/renderer/core/tile_layer_geometry.dart';
import 'package:granite/renderer/core/tile_layer_node.dart';
import 'package:granite/renderer/core/ubos/tile_ubo.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/renderer/utils/filter_features.dart';
import 'package:granite/renderer/utils/tessellator.dart';
import 'package:granite/renderer/utils/vt_utils.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math.dart' as vm;
import 'package:vector_math/vector_math_64.dart';

final class LineTileLayerNode extends TileLayerNode<spec.LayerLine> {
  LineTileLayerNode({
    required super.renderer,
    required super.specLayer,
    required super.vtLayer,
    required gpu.Shader vertexShader,
    required gpu.Shader fragmentShader,
    required UniformProps uniformProps,
    required VertexProps vertexProps,
  }) : super(
         geometry: LineTileLayerGeometry(
           renderer: renderer,
           specLayer: specLayer,
           vtLayer: vtLayer,
           vertexShader: vertexShader,
           fragmentShader: fragmentShader,
           uniformProps: uniformProps,
           vertexProps: vertexProps,
         ),
       );
}

class LineTileLayerGeometry extends TileLayerGeometry<spec.LayerLine> {
  LineTileLayerGeometry({
    required super.renderer,
    required super.specLayer,
    required super.vtLayer,
    required super.vertexShader,
    required super.fragmentShader,
    required super.uniformProps,
    required super.vertexProps,
  }) : super(staticBytesPerVertex: 16, ubos: [TileUbo()]);

  @override
  Future<void> prepare() async {
    final features = filterFeatures<vt.LineStringFeature>(
      vtLayer,
      specLayer,
      renderer.prepareEvalContext,
      sortKey: specLayer.layout.lineSortKey,
    );

    if (features.isEmpty) {
      allocateVertices(1);
      allocateIndices(Uint32List(1));
      upload();
      return;
    }

    // TODO: this has to be evaluated per-feature.
    final lineCap = specLayer.layout.lineCap.evaluate(renderer.evalContext);
    const _kLineCapRoundSegments = 16;

    // TODO:
    // final lineJoin = specLayer.layout.lineJoin.evaluate(context.eval);
    // final miterLimit = specLayer.layout.lineMiterLimit.evaluate(context.eval);
    // final roundLimit = specLayer.layout.lineRoundLimit.evaluate(context.eval);

    // Contains the list of (position, normal, lineLength) for each vertex, grouped by feature.
    final vertexData = <List<(Vector2 position, Vector2 normal, double lineLength)>>[];
    final indices = <int>[];
    var vertexCount = 0;
    var currentLength = 0.0;

    void _addRelativeIndices(List<int> idx) {
      indices.addAll(idx.map((i) => i + vertexCount));
    }

    // Add cap going from a to b.
    void _addCap(Vector2 a, Vector2 b) {
      if (lineCap == spec.LayoutLine$LineCap.butt) return;

      final t = (b - a)..normalize();
      final n = Vector2(t.y, -t.x);

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

        vertexData.last.add((center, Vector2.zero(), currentLength));
        final centerIndex = vertexCount;

        for (var i = 0; i <= _kLineCapRoundSegments; i++) {
          final angle = startAngle + i / _kLineCapRoundSegments * math.pi;
          final vec = Vector2(math.cos(angle), math.sin(angle));

          vertexData.last.add((center, vec, currentLength));
        }

        for (var i = 0; i < _kLineCapRoundSegments; i++) {
          indices.addAll([centerIndex, centerIndex + i + 1, centerIndex + i + 2]);
        }

        vertexCount += _kLineCapRoundSegments + 2;
      }
    }

    // Add single line segment from a to b.
    void _addSegment(Vector2 a, Vector2 b) {
      final t = b - a;
      final n = Vector2(t.y, -t.x)..normalize();

      _addRelativeIndices([0, 2, 1, 1, 2, 3]);

      vertexData.last.add((a, n, currentLength));
      vertexData.last.add((a, -n, currentLength));

      currentLength += t.length;

      vertexData.last.add((b, n, currentLength));
      vertexData.last.add((b, -n, currentLength));

      vertexCount += 4;
    }

    // Add join at c, from a to b.
    void _addJoin(Vector2 c, Vector2 a, Vector2 b) {
      final ac = c - a;
      final cb = b - c;

      var na = Vector2(ac.y, -ac.x)..normalize();
      var nb = Vector2(cb.y, -cb.x)..normalize();

      // check direction
      final cross = ac.x * cb.y - ac.y * cb.x;
      final direction = cross < 0 ? -1.0 : 1.0;

      na *= direction;
      nb *= direction;

      // TODO: Miter, round joins
      _addRelativeIndices(cross < 0 ? [0, 2, 1] : [0, 1, 2]);

      vertexData.last.add((c, Vector2.zero(), currentLength));
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

        // _addCap(line.points[0].vec2, line.points[1].vec2);

        for (var i = 0; i < line.points.length - 1; i++) {
          _addSegment(line.points[i].vec2, line.points[i + 1].vec2);

          if (i != 0) {
            _addJoin(line.points[i].vec2, line.points[i - 1].vec2, line.points[i + 1].vec2);
          }
        }

        // _addCap(line.points[line.points.length - 1].vec2, line.points[line.points.length - 2].vec2);

        currentLength = 0.0;
      }
    }

    allocateVertices(vertexCount);
    allocateIndices(Uint32List.fromList(indices));

    var vertexIndex = 0;
    for (var i = 0; i < vertexData.length; i++) {
      final feature = features[i];
      vertexProps.compute(renderer.prepareEvalContext.forFeature(feature), specLayer);

      for (var j = 0; j < vertexData[i].length; j++) {
        final (position, normal, lineLength) = vertexData[i][j];
        setVertex(vertexIndex, position: position, normal: normal);
        vertexIndex++;
      }
    }

    upload();
  }

  void setVertex(int index, {required Vector2 position, required Vector2 normal}) {
    var offset = index * bytesPerVertex;
    offset = vertexData!.setVec2(offset, position);
    offset = vertexData!.setVec2(offset, normal);
    offset = vertexData!.setByteData(offset, vertexProps.data);
  }

  @override
  void bind(
    gpu.RenderPass pass,
    gpu.HostBuffer transientsBuffer,
    vm.Matrix4 modelTransform,
    vm.Matrix4 cameraTransform,
    vm.Vector3 cameraPosition,
  ) {
    super.bind(pass, transientsBuffer, modelTransform, cameraTransform, cameraPosition);
    pass.setDepthWriteEnable(false);
    pass.setDepthCompareOperation(gpu.CompareFunction.always);
  }
}
