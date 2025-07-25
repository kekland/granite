import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:flutter_gpu_shaders/build.dart';

void main(List<String> args) async {
  await build(args, (config, output) async {
    print('build hii1243567424478312339955339566333114433333441330115522353314313145331351444435531555133131133123123163554544445554112312115512113111111111111444431312424311242424111111111111111111');
    await buildShaderBundleJson(
      buildInput: config,
      buildOutput: output,
      manifestFileName: 'shaders/example.shaderbundle.json',
    );
  });
}
