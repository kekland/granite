import 'vector_tile.dart';

/// A class that represents a vector tile. A vector tile is a collection of layers.
class Tile {
  const Tile({required this.layers});

  /// Layers contained in this tile.
  final List<Layer> layers;
}
