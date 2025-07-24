import 'package:flutter_scene/scene.dart';
import 'package:granite/renderer/core/tile_layer_geometry.dart';
import 'package:granite/renderer/core/tile_layer_mesh.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/gen/style.gen.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math.dart';

abstract base class TileLayerNode<SpecLayer extends spec.Layer> extends Node {
  TileLayerNode({
    required this.renderer,
    required this.specLayer,
    required this.vtLayer,
    required TileLayerGeometry geometry,
  }) : super(
         name: specLayer.id,
         mesh: TileLayerMesh(geometry),
       );

  final Renderer renderer;
  final SpecLayer specLayer;
  final vt.Layer vtLayer;

  bool get isReadyToRender => _readyToRender;
  bool _readyToRender = false;

  TileLayerGeometry get geometry => mesh!.primitives.single.geometry as TileLayerGeometry;

  Future<void> prepare() async {
    if (_readyToRender) return;
    await geometry.prepare();
    _readyToRender = true;
  }

  @override
  void render(SceneEncoder encoder, Matrix4 parentWorldTransform) {
    super.render(encoder, parentWorldTransform);
  }
}
