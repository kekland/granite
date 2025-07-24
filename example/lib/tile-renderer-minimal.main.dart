import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart';
import 'package:flutter_scene/scene.dart';
import 'package:granite/renderer/utils/byte_data_utils.dart';

Future<void> main() async {
  await Scene.initializeStaticResources();

  return runApp(
    MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
      ),
      home: TileRendererMinimal(),
    ),
  );
}

class TileRendererMinimal extends StatefulWidget {
  const TileRendererMinimal({super.key});

  @override
  State<TileRendererMinimal> createState() => _TileRendererMinimalState();
}

class _TileRendererMinimalState extends State<TileRendererMinimal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ScenePainter(), child: SizedBox.expand());
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shaderLibrary = ShaderLibrary.fromAsset('assets/maptiler-streets.shaderbundle')!;
    final texture = gpuContext.createTexture(StorageMode.hostVisible, size.width.round(), size.height.round());
    final renderTarget = RenderTarget.singleColor(ColorAttachment(texture: texture));

    final vertexShader = shaderLibrary[('Background-vert')]!;
    final fragmentShader = shaderLibrary[('Background-frag')]!;
    final pipeline = gpuContext.createRenderPipeline(vertexShader, fragmentShader);

    final commandBuffer = gpuContext.createCommandBuffer();
    final renderPass = commandBuffer.createRenderPass(renderTarget);
    renderPass.bindPipeline(pipeline);

    final vertexBuffer = gpuContext.createDeviceBufferWithCopy(
      Float32List.fromList([
        0.0, 0.0, //
        1.0, 0.0, //
        0.0, 1.0, //
        1.0, 1.0, //
      ]).buffer.asByteData(),
    );

    final transientsBuffer = gpuContext.createHostBuffer();
    // final propUbo = vertexShader.getUniformSlot('PropUbo');
    // renderPass.bindUniform(
    //   propUbo,
    //   transientsBuffer.emplace(Float32List.fromList([1.0, 0.0, 0.0, 0.0]).buffer.asByteData()),
    // );

    final vertexTileUbo = vertexShader.getUniformSlot('Tile');
    final fragmentTileUbo = fragmentShader.getUniformSlot('Tile');
    final bytes = ByteData(80);
    bytes.setMat4(0, Matrix4.identity());
    bytes.setFloat(64, 1.0);
    bytes.setFloat(68, 1.0);
    bytes.setFloat(72, 0.1);
    final uboBuffer = gpuContext.createDeviceBufferWithCopy(bytes);

    renderPass.bindUniform(
      vertexTileUbo,
      BufferView(uboBuffer, offsetInBytes: 0, lengthInBytes: uboBuffer.sizeInBytes),
    );
    renderPass.bindUniform(
      fragmentTileUbo,
      BufferView(uboBuffer, offsetInBytes: 0, lengthInBytes: uboBuffer.sizeInBytes),
    );

    renderPass.bindVertexBuffer(BufferView(vertexBuffer, offsetInBytes: 0, lengthInBytes: vertexBuffer.sizeInBytes), 4);
    renderPass.setCullMode(CullMode.none);

    renderPass.draw();
    commandBuffer.submit(completionCallback: print);

    final image = texture.asImage();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
