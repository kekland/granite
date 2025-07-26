// ignore_for_file: avoid_print

import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';

import '../gen/macos_native_bindings.dart' as bindings;

final _b = bindings.MacosNativeBindings(DynamicLibrary.process());
final _mtlDevice = _b.MTLCreateSystemDefaultDevice();

File? _captureFile;

void startCapture() {
  print('-- start capture');
  final temp = Directory.systemTemp.createTempSync('granite_capture');
  _captureFile = File('${temp.path}/capture.gputrace');

  final descriptor = bindings.MTLCaptureDescriptor();
  descriptor.captureObject = _mtlDevice;
  descriptor.destination = bindings.MTLCaptureDestination.MTLCaptureDestinationGPUTraceDocument;
  descriptor.outputURL = NSURL.fileURLWithPath(_captureFile!.path.toNSString());

  bindings.MTLCaptureManager.sharedCaptureManager().startCaptureWithDescriptor(descriptor, error: nullptr);
}

void stopCapture() {
  print('-- stop capture');

  bindings.MTLCaptureManager.sharedCaptureManager().stopCapture();

  // open capture
  print('-- capture saved to: ${_captureFile!.path}');
  Process.run('open', [_captureFile!.path]);
}
