import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_scene/scene.dart';
import 'package:granite/renderer/core/props/uniform_props.dart';
import 'package:granite/renderer/core/props/vertex_props.dart';
import 'package:granite/renderer/core/renderer_root_node.dart';
import 'package:granite/renderer/core/tile_node.dart';
import 'package:granite/renderer/gpu_utils/hot_reloadable_shader_library.dart';
import 'package:granite/renderer/gpu_utils/shader_library_provider.dart';
import 'package:granite/renderer/layers/background/background.dart';
import 'package:granite/renderer/layers/fill/fill.dart';
import 'package:granite/renderer/layers/fill_extrusion/fill_extrusion.dart';
import 'package:granite/renderer/layers/line/line.dart';
import 'package:granite/renderer/preprocessor/preprocessor.dart';
import 'package:granite/spec/spec.dart';
import 'package:granite/vector_tile/vector_tile.dart' as vt;

class Renderer with ChangeNotifier {
  Renderer({
    required this.style,
    required this.shaderLibraryProvider,
  }) {
    scene.antiAliasingMode = AntiAliasingMode.msaa;
    _root.registerAsRoot(scene);

    if (shaderLibraryProvider is HotReloadableShaderLibraryProvider) {
      (shaderLibraryProvider as HotReloadableShaderLibraryProvider).addListener(_onShaderLibraryUpdated);
    }
  }

  @override
  void dispose() {
    if (shaderLibraryProvider is HotReloadableShaderLibraryProvider) {
      (shaderLibraryProvider as HotReloadableShaderLibraryProvider).removeListener(_onShaderLibraryUpdated);
    }

    super.dispose();
  }

  final Style style;
  final ShaderLibraryProvider shaderLibraryProvider;
  late final preprocessedStyle = StylePreprocessor.preprocess(style);

  EvaluationContext _evalContext = EvaluationContext.empty();
  EvaluationContext get evalContext => _evalContext;

  EvaluationContext _prepareEvalContext = EvaluationContext.empty();
  EvaluationContext get prepareEvalContext => _prepareEvalContext;

  final scene = Scene();
  late final _root = RendererRootNode(renderer: this);

  Future<void> _onShaderLibraryUpdated() async {
    final _tiles = <(vt.Tile, TileCoordinates)>[];
    for (final tileNode in scene.root.children.whereType<TileNode>()) {
      _tiles.add((tileNode.tile, tileNode.coordinates));
    }

    scene.removeAll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final (tile, coordinates) in _tiles) {
        addTile(tile, coordinates);
      }

      notifyListeners();
    });
  }

  void onReassemble() => _onShaderLibraryUpdated();

  void addTile(
    vt.Tile tile,
    TileCoordinates coordinates,
  ) {
    final tileNode = TileNode(
      renderer: this,
      tile: tile,
      coordinates: coordinates,
    );

    for (var i = 0; i < preprocessedStyle.layers.length; i++) {
      final specLayer = style.layers[i];
      final preprocessedLayer = preprocessedStyle.layers[i];
      if (preprocessedLayer == null) continue;

      final sourceLayerName = specLayer.sourceLayer;
      final vtLayer = tile.layers.firstWhereOrNull((data) => data.name == sourceLayerName);
      if (specLayer.type != Layer$Type.background && vtLayer == null) continue;

      final tileLayerNode = switch (specLayer.type) {
        Layer$Type.background => BackgroundTileLayerNode(
          renderer: this,
          specLayer: specLayer as LayerBackground,
          vtLayer: vt.Layer.empty,
          vertexShader: shaderLibraryProvider['${specLayer.id}-vert']!,
          fragmentShader: shaderLibraryProvider['${specLayer.id}-frag']!,
          uniformProps: UniformProps(instructions: preprocessedLayer.uniformPropInstructions),
          vertexProps: VertexProps(instructions: preprocessedLayer.vertexPropInstructions),
        ),
        Layer$Type.fill => FillTileLayerNode(
          renderer: this,
          specLayer: specLayer as LayerFill,
          vtLayer: vtLayer!,
          vertexShader: shaderLibraryProvider['${specLayer.id}-vert']!,
          fragmentShader: shaderLibraryProvider['${specLayer.id}-frag']!,
          uniformProps: UniformProps(instructions: preprocessedLayer.uniformPropInstructions),
          vertexProps: VertexProps(instructions: preprocessedLayer.vertexPropInstructions),
        ),
        // Layer$Type.line => LineTileLayerNode(
        //   renderer: this,
        //   specLayer: specLayer as LayerLine,
        //   vtLayer: vtLayer!,
        //   vertexShader: shaderLibraryProvider['${specLayer.id}-vert']!,
        //   fragmentShader: shaderLibraryProvider['${specLayer.id}-frag']!,
        //   uniformProps: UniformProps(instructions: preprocessedLayer.uniformPropInstructions),
        //   vertexProps: VertexProps(instructions: preprocessedLayer.vertexPropInstructions),
        // ),
        Layer$Type.fillExtrusion => FillExtrusionTileLayerNode(
          renderer: this,
          specLayer: specLayer as LayerFillExtrusion,
          vtLayer: vtLayer!,
          vertexShader: shaderLibraryProvider['${specLayer.id}-vert']!,
          fragmentShader: shaderLibraryProvider['${specLayer.id}-frag']!,
          uniformProps: UniformProps(instructions: preprocessedLayer.uniformPropInstructions),
          vertexProps: VertexProps(instructions: preprocessedLayer.vertexPropInstructions),
        ),
        _ => null,
      };

      if (tileLayerNode != null) {
        tileNode.add(tileLayerNode);
      }
    }

    tileNode.prepare().then((_) => notifyListeners());
    scene.add(tileNode);
    scene.root.children.sort((a, b) {
      if (a is TileNode && b is TileNode) {
        return a.coordinates.z.compareTo(b.coordinates.z);
      }

      return 0;
    });
  }
}
