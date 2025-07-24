import 'package:collection/collection.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart' as scene;
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/gen/style.gen.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart';

abstract base class LayerNode<TSpec extends spec.Layer> extends scene.Node with RendererDescendantNode {
  LayerNode({required this.specLayer, required this.preprocessedLayer}) : super(name: specLayer.id);

  final TSpec specLayer;
  final PreprocessedLayer preprocessedLayer;

  late final vertexShader = renderer.getShader('${specLayer.id}-vert')!;
  late final fragmentShader = renderer.getShader('${specLayer.id}-frag')!;
  late final pipeline = gpu.gpuContext.createRenderPipeline(vertexShader, fragmentShader);
  late final vertexProps = VertexProps(instructions: preprocessedLayer.vertexPropInstructions);
  late final uniformProps = UniformProps(instructions: preprocessedLayer.uniformPropInstructions);

  LayerTileNode createLayerTileNode(TileCoordinates coordinates, vt.Layer vtLayer);

  void addTile(TileCoordinates coordinates, vt.Tile tile) {
    final sourceLayerName = specLayer.sourceLayer;
    final vtLayer = tile.layers.firstWhereOrNull((data) => data.name == sourceLayerName);
    if (vtLayer == null) return;

    final layerTileNode = createLayerTileNode(coordinates, vtLayer);
    add(layerTileNode);
  }

  @override
  List<LayerTileNode> get children => super.children.cast<LayerTileNode>();

  @override
  void add(scene.Node child) {
    super.add(child);

    if (child is LayerTileNode) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      child.prepare().then((_) => renderer.notifyListeners());
    }

    children.sort((a, b) => a.coordinates.z.compareTo(b.coordinates.z));
  }

  @override
  void render(scene.SceneEncoder encoder, Matrix4 parentWorldTransform) {
    encoder.renderPass.clearBindings();
    encoder.renderPass.bindPipeline(pipeline);

    uniformProps.bind(
      renderer.baseEvaluationContext,
      specLayer,
      encoder.renderPass,
      vertexShader,
      encoder.transientsBuffer,
    );

    for (final child in children) {
      child.render(encoder, parentWorldTransform * localTransform);
    }
  }
}
