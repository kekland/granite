import 'package:granite/renderer/isolates/layer_tile_geometry_worker_isolate.dart';

import 'core/worker_isolate_pool.dart';

export 'core/worker_isolate_pool.dart';
export 'core/worker_isolate.dart';

class Isolates {
  Isolates();

  Future<void> spawn() async {
    _layerTileGeometry = LayerTileGeometryWorkerIsolatePool(16);
    await Future.wait(pools.map((pool) => pool!.spawn()));
  }

  void close() {
    for (var pool in pools) {
      pool!.close();
    }

    _layerTileGeometry = null;
  }

  List<WorkerIsolatePool?> get pools => [_layerTileGeometry];

  LayerTileGeometryWorkerIsolatePool? _layerTileGeometry;
  LayerTileGeometryWorkerIsolatePool get layerTileGeometry => _layerTileGeometry!;
}
