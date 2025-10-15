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

  String get vertexShaderName => '${renderer.style.name}/${specLayer.id}-vert';
  String get fragmentShaderName => '${renderer.style.name}/${specLayer.id}-frag';

  late final vertexShader = renderer.getShader(vertexShaderName)!;
  late final fragmentShader = renderer.getShader(fragmentShaderName)!;
  late final pipeline = gpu.gpuContext.createRenderPipeline(vertexShader, fragmentShader);
  late final shadowPassPipeline = gpu.gpuContext.createRenderPipeline(
    vertexShader,
    renderer.getShader('empty-material-frag')!,
  );
  late final vertexProps = VertexProps(instructions: preprocessedLayer.vertexPropInstructions);
  late final uniformProps = UniformProps(instructions: preprocessedLayer.uniformPropInstructions);

  LayerTileNode createLayerTileNode(TileCoordinates coordinates, GeometryData? geometryData, vt.Layer? vtLayer);

  void addTile(TileCoordinates coords, GeometryData? geometryData, vt.Layer? vtLayer) {
    final layerTileNode = createLayerTileNode(coords, geometryData, vtLayer);
    add(layerTileNode);
  }

  void removeTile(TileCoordinates coords) {
    children.removeWhere((v) => v.coordinates == coords);
  }

  @override
  List<LayerTileNode> get children => super.children.cast<LayerTileNode>();

  @override
  void add(scene.Node child) {
    super.add(child);
    (child as LayerTileNode).setGeometryAndMaterial();
    children.sort((a, b) => a.coordinates.z.compareTo(b.coordinates.z));
  }

  @override
  void render(scene.SceneEncoder encoder, Matrix4 parentWorldTransform) {
    encoder.renderPass.clearBindings();
    encoder.renderPass.bindPipeline(renderer.isShadowPass ? shadowPassPipeline : pipeline);

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
