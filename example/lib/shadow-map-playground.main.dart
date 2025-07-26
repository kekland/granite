import 'dart:math';

import 'package:flutter/material.dart' hide Material;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter_scene/scene.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:vector_math/vector_math.dart' as vm32;

void main() {
  return runApp(
    MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: _Test(),
    ),
  );
}

class _Test extends StatelessWidget {
  const _Test({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadowMapPlayground();
  }
}

class ShadowMapPlayground extends StatefulWidget {
  const ShadowMapPlayground({super.key});

  @override
  State<ShadowMapPlayground> createState() => ShadowMapPlaygroundState();
}

class ShadowMapPlaygroundState extends State<ShadowMapPlayground> with TickerProviderStateMixin {
  late final Scene scene;
  late final Ticker ticker;
  var _elapsedSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    scene = Scene();
    final mesh = Mesh(
      _TestGeometry(vm.Vector3(1, 1, 1)),
      _TestMaterial(),
    );

    final ground = Mesh(
      _TestGeometry(vm.Vector3(4, 0.1, 4)),
      _TestMaterial(),
    );

    final groundNode = Node(mesh: ground, localTransform: vm.Matrix4.translationValues(0, -0.5, 0));
    scene.add(groundNode);
    scene.addMesh(mesh);
    // scene.addMesh(ground);

    ticker = createTicker((elapsed) => setState(() => _elapsedSeconds = elapsed.inMicroseconds / 1e6));
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: _ScenePainter(scene, _elapsedSeconds),
            child: const SizedBox.expand(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (ticker.isActive) {
                      ticker.stop();
                    } else {
                      ticker.start();
                    }
                  },
                  child: const Text('Toggle'),
                ),
                Text('Elapsed time: ${_elapsedSeconds.toStringAsFixed(2)} seconds'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Matrix4 _lightVp = Matrix4.identity();
late gpu.Texture _shadowMapTexture;
var _isShadowPass = false;

class _TestGeometry extends CuboidGeometry {
  _TestGeometry(super.extents) {
    setVertexShader(_examplerShaderLibrary['test-vertex']!);
  }

  @override
  void bind(
    gpu.RenderPass pass,
    gpu.HostBuffer transientsBuffer,
    Matrix4 modelTransform,
    Matrix4 cameraTransform,
    vm.Vector3 cameraPosition,
  ) {
    super.bind(pass, transientsBuffer, modelTransform, cameraTransform, cameraPosition);

    final lightSlot = vertexShader.getUniformSlot('Light');
    if (lightSlot.sizeInBytes != null) {
      final data = ByteData(64);
      data.setMat4(0, _lightVp);
      pass.bindUniform(lightSlot, transientsBuffer.emplace(data));
    }
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.elapsedTime);
  Scene scene;
  double elapsedTime;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      position: vm.Vector3(sin(elapsedTime) * 5, 5, cos(elapsedTime) * 5),
      target: vm.Vector3(0, 0, 0),
      fovFar: 20.0,
    );

    final lightCamera = LightCamera(
      mainCamera: camera,
      direction: vm.Vector3(0.5, -1, 0.5).normalized(),
    );

    // shadow pass
    const shadowMapDimensions = Size(1024, 1024);
    _lightVp = lightCamera.getViewTransform(shadowMapDimensions);

    final shadowMapColorTexture = gpu.gpuContext.createTexture(
      gpu.StorageMode.hostVisible,
      shadowMapDimensions.width.toInt(),
      shadowMapDimensions.height.toInt(),
      format: gpu.gpuContext.defaultColorFormat,
    );
    _shadowMapTexture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      shadowMapDimensions.width.toInt(),
      shadowMapDimensions.height.toInt(),
      format: gpu.PixelFormat.d32FloatS8UInt,
      coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture,
      enableRenderTargetUsage: true,
      enableShaderReadUsage: true,
      enableShaderWriteUsage: false,
    );

    final shadowMapRenderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(
        texture: shadowMapColorTexture,
        loadAction: gpu.LoadAction.clear,
        storeAction: gpu.StoreAction.store,
        clearValue: vm32.Vector4(1.0, 1.0, 1.0, 1.0),
      ),
      depthStencilAttachment: gpu.DepthStencilAttachment(
        texture: _shadowMapTexture,
        depthStoreAction: gpu.StoreAction.store,
        depthLoadAction: gpu.LoadAction.clear,
        depthClearValue: 1.0,
        stencilStoreAction: gpu.StoreAction.dontCare,
        stencilLoadAction: gpu.LoadAction.dontCare,
        stencilClearValue: 0,
      ),
    );

    _isShadowPass = true;
    for (final n in scene.root.children) {
      (n.mesh!.primitives.first.material as dynamic)._presetShader();
    }
    final encoder = SceneEncoder(shadowMapRenderTarget, lightCamera, shadowMapDimensions, Environment());
    scene.root.render(encoder, vm.Matrix4.identity());
    encoder.finish();
    _isShadowPass = false;
    for (final n in scene.root.children) {
      (n.mesh!.primitives.first.material as dynamic)._presetShader();
    }

    final shadowMapImage = _shadowMapTexture.asImage();
    scene.render(camera, canvas, viewport: Offset.zero & size);
    // scene.render(lightCamera, canvas, viewport: Offset.zero & size);
    // canvas.drawImage(shadowMapImage, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

final _examplerShaderLibrary = gpu.ShaderLibrary.fromAsset('build/shaderbundles/example.shaderbundle')!;

class _TestMaterial extends Material {
  _TestMaterial() {
    setFragmentShader(_examplerShaderLibrary['test-fragment']!);
  }

  void _presetShader() {
    // if (_isShadowPass) {
    //   setFragmentShader(_examplerShaderLibrary['shadow-pass-fragment']!);
    //   return;
    // }

    setFragmentShader(_examplerShaderLibrary['test-fragment']!);
  }

  @override
  void bind(gpu.RenderPass pass, gpu.HostBuffer transientsBuffer, Environment environment) {
    // if (_isShadowPass) {
    //   return;
    // }

    final shadowMapSlot = fragmentShader.getUniformSlot('u_shadow_map');
    pass.bindTexture(
      shadowMapSlot,
      _shadowMapTexture,
      sampler: gpu.SamplerOptions(
        widthAddressMode: gpu.SamplerAddressMode.repeat,
        heightAddressMode: gpu.SamplerAddressMode.repeat,
      ),
    );

    super.bind(pass, transientsBuffer, environment);
  }
}

class LightCamera extends Camera {
  LightCamera({required this.mainCamera, required this.direction});

  final Camera mainCamera;
  final vm.Vector3 direction;

  @override
  vm.Vector3 get position => vm.Vector3.zero();

  @override
  Matrix4 getViewTransform(Size dimensions) {
    final vp = mainCamera.getViewTransform(dimensions);
    final lightDirection = direction.normalized();
    final invVp = vp.clone()..invert();

    final _ndc = [
      vm.Vector4(-1, -1, 0, 1),
      vm.Vector4(1, -1, 0, 1),
      vm.Vector4(-1, 1, 0, 1),
      vm.Vector4(1, 1, 0, 1),
      vm.Vector4(-1, -1, 1, 1),
      vm.Vector4(1, -1, 1, 1),
      vm.Vector4(-1, 1, 1, 1),
      vm.Vector4(1, 1, 1, 1),
    ];

    final corners = _ndc.map((p) => invVp.transformed(p)).map((p) => p.xyz / p.w).toList();
    final center = corners.reduce((a, b) => a + b) / 8.0;
    final radius = corners.map((p) => (p - center).length).reduce((a, b) => max(a, b));
    const positionOffset = 1.5;
    final position = center - lightDirection * radius * positionOffset;
    // print(center);
    // final lightView = _matrix4LookAt(vm.Vector3(-4.0, 1.0, -4.0), vm.Vector3.zero(), vm.Vector3(0.0, 1.0, 0.0));
    final lightView = _matrix4LookAt(position, center, vm.Vector3(0, 1, 0));

    final lightSpace = corners.map((p) => p.clone()..applyMatrix4(lightView)).toList();
    final minX = lightSpace.map((p) => p.x).reduce(min);
    final maxX = lightSpace.map((p) => p.x).reduce(max);
    final minY = lightSpace.map((p) => p.y).reduce(min);
    final maxY = lightSpace.map((p) => p.y).reduce(max);
    final minZ = lightSpace.map((p) => p.z).reduce(min);
    final maxZ = lightSpace.map((p) => p.z).reduce(max);

    final lightProj = _matrix4Orthographic(minX, maxX, minY, maxY, minZ, maxZ);
    return lightProj * lightView;
  }
}

vm.Matrix4 _matrix4Orthographic(
  double left,
  double right,
  double bottom,
  double top,
  double zNear,
  double zFar,
) {
  final double dx = right - left;
  final double dy = top - bottom;
  final double dz = zFar - zNear;

  return Matrix4(
    2.0 / dx,
    0.0,
    0.0,
    0.0,
    0.0,
    2.0 / dy,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0 / dz,
    0.0,
    -(right + left) / dx,
    -(top + bottom) / dy,
    -zNear / dz,
    1.0,
  );
}

vm.Matrix4 _matrix4LookAt(vm.Vector3 position, vm.Vector3 target, vm.Vector3 up) {
  vm.Vector3 forward = (target - position).normalized();
  vm.Vector3 right = up.cross(forward).normalized();
  up = forward.cross(right).normalized();

  return Matrix4(
    right.x,
    up.x,
    forward.x,
    0.0, //
    right.y,
    up.y,
    forward.y,
    0.0, //
    right.z,
    up.z,
    forward.z,
    0.0, //
    -right.dot(position),
    -up.dot(position),
    -forward.dot(position),
    1.0, //
  );
}

vm.Matrix4 _matrix4Perspective(
  double fovRadiansY,
  double aspectRatio,
  double zNear,
  double zFar,
) {
  double height = tan(fovRadiansY * 0.5);
  double width = height * aspectRatio;

  return Matrix4(
    1.0 / width,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0 / height,
    0.0,
    0.0,
    0.0,
    0.0,
    zFar / (zFar - zNear),
    1.0,
    0.0,
    0.0,
    -(zFar * zNear) / (zFar - zNear),
    0.0,
  );
}
