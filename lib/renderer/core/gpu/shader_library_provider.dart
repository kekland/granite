import 'package:flutter/widgets.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// A class that provides a [gpu.ShaderLibrary] instance.
/// 
/// Listeners will be notified if the shader library changes its shaders (e.g. hot-reload).
abstract class ShaderLibraryProvider with ChangeNotifier {
  /// The underlying [gpu.ShaderLibrary] instance.
  gpu.ShaderLibrary get shaderLibrary;

  /// Resolves a shader by its name.
  gpu.Shader? operator [](String name) => shaderLibrary[name];
}

/// A class that provides a static [gpu.ShaderLibrary] instance from an asset.
class AssetShaderLibraryProvider extends ShaderLibraryProvider {
  AssetShaderLibraryProvider(String assetName) : shaderLibrary = gpu.ShaderLibrary.fromAsset(assetName)!;

  @override
  final gpu.ShaderLibrary shaderLibrary;
}
