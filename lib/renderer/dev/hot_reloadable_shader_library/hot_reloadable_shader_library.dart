import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'shader_bundle_impeller.fb.shaderbundle_generated.dart' as ipsb;

import '../../core/gpu/shader_library_provider.dart';
export '../../core/gpu/shader_library_provider.dart';

Map<String, String> _hotReloadSuffixes = {};

/// A class that provides a hot-reloadable [gpu.ShaderLibrary] instance.
///
/// See [HotReloadableShaderLibraryBindings] for more information.
class HotReloadableShaderLibraryProvider extends ShaderLibraryProvider {
  HotReloadableShaderLibraryProvider(this.assetName) {
    HotReloadableShaderLibraryBindings.instance._attachProvider(assetName, _onShaderLibraryReloaded);
    _finalizer.attach(this, assetName);
  }

  final String assetName;

  static final _finalizer = Finalizer<String>((assetName) {
    HotReloadableShaderLibraryBindings.instance._detachProvider(assetName);
  });

  gpu.ShaderLibrary? _shaderLibrary;

  @override
  gpu.ShaderLibrary get shaderLibrary {
    if (_shaderLibrary == null) {
      _shaderLibrary = gpu.ShaderLibrary.fromAsset(assetName);
      _shaderLibrary!.shaders_.clear();
    }

    return _shaderLibrary!;
  }

  @override
  gpu.Shader? operator [](String name) {
    final suffix = _hotReloadSuffixes[assetName];
    if (suffix == null) return shaderLibrary[name];
    return shaderLibrary['$name#$suffix'];
  }

  void _onShaderLibraryReloaded() {
    if (kDebugMode) print('[#$hashCode] re-creating shader library for $assetName');
    _shaderLibrary = null;
    notifyListeners();
  }
}

/// A WidgetsBinding that provides hot-reloadable shader libraries.
///
/// This class works by reading the asset manifest and checking for shaderbundles. The shaderbundles produced by
/// `bin/compile_style.dart` contain a hot-reload suffix that is used to identify the shaderbundle that should be
/// reloaded. This suffix is then used to identify the shader that should be reloaded.
///
/// Instances of [HotReloadableShaderLibraryProvider] can use this class to provide hot-reloadable shader libraries.
class HotReloadableShaderLibraryBindings extends WidgetsFlutterBinding {
  HotReloadableShaderLibraryBindings._() : super() {
    _instance = this;
  }

  static HotReloadableShaderLibraryBindings? _instance;
  static HotReloadableShaderLibraryBindings get instance => _instance!;

  static Future<WidgetsBinding> ensureInitialized() async {
    if (HotReloadableShaderLibraryBindings._instance == null) {
      final instance = HotReloadableShaderLibraryBindings._();
      await instance._readShaderBundles();
    }

    return HotReloadableShaderLibraryBindings.instance;
  }

  final _providerCallbacks = <String, VoidCallback>{};
  void _attachProvider(String assetName, VoidCallback callback) {
    _providerCallbacks[assetName] = callback;
  }

  void _detachProvider(String assetName) {
    _providerCallbacks.remove(assetName);
  }

  Future<void> _readShaderBundles() async {
    // Get the asset manifest and the list of all shaderbundles.
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final shaderbundleAssets = manifest.listAssets().where((v) => v.endsWith('.shaderbundle'));

    for (final key in shaderbundleAssets) {
      rootBundle.evict(key);

      final bytes = await rootBundle.load(key);
      final buffer = ipsb.ShaderBundle(bytes.buffer.asUint8List());

      // Check for a hot-reload suffix.
      final suffixSet = buffer.shaders?.map((v) => v.name?.split('#').last).toSet();
      if (suffixSet == null) continue;
      if (suffixSet.length != 1) continue;
      if (suffixSet.first == null) continue;

      final suffix = suffixSet.first;
      if (_hotReloadSuffixes[key] != suffix) {
        if (kDebugMode) print('- Shader hot reloaded: $key');
        _hotReloadSuffixes[key] = suffix!;

        // Notify providers.
        for (final e in _providerCallbacks.entries) {
          if (e.key == key) e.value();
        }
      }
    }
  }

  @override
  Future<void> performReassemble() async {
    await _readShaderBundles();
    await super.performReassemble();
  }
}
