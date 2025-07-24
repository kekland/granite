import 'vector_tile.dart';

/// A layer holds a collection of features and metadata about the features.
class Layer {
  const Layer({required this.version, required this.name, required this.extent, required this.features});

  /// An empty layer.
  static const empty = Layer(version: 1, name: '', extent: 4096, features: []);

  /// Version of the layer. Currently unused.
  final int version;

  /// The name of the layer.
  final String name;

  /// The extent of the tile. Usually 4096.
  final int extent;

  /// A list of features contained in this layer.
  final List<Feature> features;
}
