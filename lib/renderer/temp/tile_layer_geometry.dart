// import 'dart:typed_data';

// import 'package:flutter_gpu/gpu.dart' as gpu;
// import 'package:granite/renderer/core/props/uniform_props.dart';
// import 'package:granite/renderer/core/props/vertex_props.dart';
// import 'package:granite/renderer/core/ubos/ubo.dart';
// import 'package:granite/renderer/renderer.dart';
// import 'package:granite/spec/spec.dart' as spec;

// import 'package:flutter_scene/scene.dart';
// import 'package:granite/vector_tile/vector_tile.dart' as vt;
// import 'package:vector_math/vector_math_64.dart' as vm;

// abstract class TileLayerGeometry<SpecLayer extends spec.Layer> extends UnskinnedGeometry {
//   TileLayerGeometry({
//     required this.renderer,
//     required this.specLayer,
//     required this.vtLayer,
//     required gpu.Shader vertexShader,
//     required gpu.Shader fragmentShader,
//     required this.uniformProps,
//     required this.vertexProps,
//     required this.staticBytesPerVertex,
//     this.ubos = const [],
//   }) {
//     setVertexShader(vertexShader);
//     _fragmentShader = fragmentShader;
//   }

//   final Renderer renderer;
//   final SpecLayer specLayer;
//   final vt.Layer vtLayer;
//   final List<Ubo> ubos;

//   final UniformProps uniformProps;
//   final VertexProps vertexProps;
//   final int staticBytesPerVertex;
//   late final int bytesPerVertex = staticBytesPerVertex + vertexProps.lengthInBytes;

//   ByteData? vertexData;
//   int? _vertexCount;

//   ByteData? _indexData;

//   gpu.Shader? _fragmentShader;
//   gpu.Shader get fragmentShader {
//     if (_fragmentShader == null) {
//       throw Exception('Fragment shader has not been set');
//     }
//     return _fragmentShader!;
//   }

//   Future<void> prepare();

//   void allocateVertices(int count) {
//     _vertexCount = count;
//     vertexData = ByteData(count * bytesPerVertex);
//   }

//   void allocateIndices(Uint32List indices) {
//     _indexData = indices.buffer.asByteData();
//   }

//   void upload() {
//     uploadVertexData(vertexData!, _vertexCount!, _indexData!, indexType: gpu.IndexType.int32);
//   }

//   @override
//   void bind(
//     gpu.RenderPass pass,
//     gpu.HostBuffer transientsBuffer,
//     vm.Matrix4 modelTransform,
//     vm.Matrix4 cameraTransform,
//     vm.Vector3 cameraPosition,
//   ) {
//     super.bind(pass, transientsBuffer, modelTransform, cameraTransform, cameraPosition);
//     uniformProps.bind(renderer.evalContext, specLayer, pass, vertexShader, transientsBuffer);

//     for (final ubo in ubos) {
//       ubo.bind(
//         renderer.evalContext,
//         modelTransform,
//         cameraTransform,
//         cameraPosition,
//         specLayer,
//         pass,
//         vertexShader,
//         transientsBuffer,
//       );

//       ubo.bind(
//         renderer.evalContext,
//         modelTransform,
//         cameraTransform,
//         cameraPosition,
//         specLayer,
//         pass,
//         fragmentShader,
//         transientsBuffer,
//       );
//     }
//   }
// }
