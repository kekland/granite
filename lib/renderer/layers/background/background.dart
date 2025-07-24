import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:granite/renderer/core/props/uniform_props.dart';
import 'package:granite/renderer/core/props/vertex_props.dart';
import 'package:granite/renderer/core/tile_layer_geometry.dart';
import 'package:granite/renderer/core/tile_layer_node.dart';
import 'package:granite/renderer/core/ubos/tile_ubo.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:vector_math/vector_math.dart' as vm;
import 'package:vector_math/vector_math_64.dart';

final class BackgroundTileLayerNode extends TileLayerNode<spec.LayerBackground> {
  BackgroundTileLayerNode({
    required super.renderer,
    required super.specLayer,
    required super.vtLayer,
    required gpu.Shader vertexShader,
    required gpu.Shader fragmentShader,
    required UniformProps uniformProps,
    required VertexProps vertexProps,
  }) : super(
         geometry: BackgroundTileLayerGeometry(
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

class BackgroundTileLayerGeometry extends TileLayerGeometry<spec.LayerBackground> {
  BackgroundTileLayerGeometry({
    required super.renderer,
    required super.specLayer,
    required super.vtLayer,
    required super.vertexShader,
    required super.fragmentShader,
    required super.uniformProps,
    required super.vertexProps,
  }) : super(staticBytesPerVertex: 8, ubos: [TileUbo()]);

  @override
  Future<void> prepare() async {
    allocateVertices(4);
    allocateIndices(Uint32List.fromList([0, 1, 2, 0, 2, 3]));

    setVertex(0, position: Vector2(-8.0, -8.0));
    setVertex(1, position: Vector2(4104.0, -8.0));
    setVertex(2, position: Vector2(4104.0, 4104.0));
    setVertex(3, position: Vector2(-8.0, 4104.0));

    upload();
  }

  void setVertex(int index, {required Vector2 position}) {
    var offset = index * bytesPerVertex;
    offset = vertexData!.setVec2(offset, position);
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
    pass.setDepthCompareOperation(gpu.CompareFunction.less);
  }
}
