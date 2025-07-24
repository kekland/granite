// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:developer';
import 'dart:typed_data';

import 'package:vector_math/vector_math_64.dart';

typedef internal_ByteDataSetter = int Function(ByteData data, int offset, dynamic value);
internal_ByteDataSetter internal_resolveByteDataSetter(Type type) {
  return switch (type) {
    const (double) => internal_setFloat,
    const (int) => internal_setInt,
    const (Vector2) => internal_setVec2,
    const (Vector3) => internal_setVec3,
    const (Vector4) => internal_setVec4,
    const (Matrix2) => internal_setMat2,
    const (Matrix3) => internal_setMat3,
    const (Matrix4) => internal_setMat4,
    const (ByteData) => internal_setByteData,
    _ => throw ArgumentError('Unsupported type for ByteData setter: $type'),
  };
}

int internal_setFloat(ByteData data, int offset, dynamic v) {
  data.setFloat32(offset, v.toDouble(), Endian.host);
  return offset + 4;
}

int internal_setInt(ByteData data, int offset, dynamic v) {
  data.setInt32(offset, v, Endian.host);
  return offset + 4;
}

int internal_setVec2(ByteData data, int offset, dynamic v) {
  data.setFloat32(offset, v.x, Endian.host);
  data.setFloat32(offset + 4, v.y, Endian.host);
  return offset + 8;
}

int internal_setVec3(ByteData data, int offset, dynamic v) {
  data.setFloat32(offset, v.x, Endian.host);
  data.setFloat32(offset + 4, v.y, Endian.host);
  data.setFloat32(offset + 8, v.z, Endian.host);
  return offset + 12;
}

int internal_setVec4(ByteData data, int offset, dynamic v) {
  data.setFloat32(offset, v.x, Endian.host);
  data.setFloat32(offset + 4, v.y, Endian.host);
  data.setFloat32(offset + 8, v.z, Endian.host);
  data.setFloat32(offset + 12, v.w, Endian.host);
  return offset + 16;
}

int internal_setMat2(ByteData data, int offset, dynamic m) {
  data.setFloat32(offset, m[0], Endian.host);
  data.setFloat32(offset + 4, m[1], Endian.host);
  data.setFloat32(offset + 8, m[2], Endian.host);
  data.setFloat32(offset + 12, m[3], Endian.host);
  return offset + 16;
}

int internal_setMat3(ByteData data, int offset, dynamic m) {
  data.setFloat32(offset, m[0], Endian.host);
  data.setFloat32(offset + 4, m[1], Endian.host);
  data.setFloat32(offset + 8, m[2], Endian.host);
  data.setFloat32(offset + 12, m[3], Endian.host);
  data.setFloat32(offset + 16, m[4], Endian.host);
  data.setFloat32(offset + 20, m[5], Endian.host);
  return offset + 24;
}

int internal_setMat4(ByteData data, int offset, dynamic m) {
  data.setFloat32(offset, m[0], Endian.host);
  data.setFloat32(offset + 4, m[1], Endian.host);
  data.setFloat32(offset + 8, m[2], Endian.host);
  data.setFloat32(offset + 12, m[3], Endian.host);
  data.setFloat32(offset + 16, m[4], Endian.host);
  data.setFloat32(offset + 20, m[5], Endian.host);
  data.setFloat32(offset + 24, m[6], Endian.host);
  data.setFloat32(offset + 28, m[7], Endian.host);
  data.setFloat32(offset + 32, m[8], Endian.host);
  data.setFloat32(offset + 36, m[9], Endian.host);
  data.setFloat32(offset + 40, m[10], Endian.host);
  data.setFloat32(offset + 44, m[11], Endian.host);
  data.setFloat32(offset + 48, m[12], Endian.host);
  data.setFloat32(offset + 52, m[13], Endian.host);
  data.setFloat32(offset + 56, m[14], Endian.host);
  data.setFloat32(offset + 60, m[15], Endian.host);
  return offset + 64;
}

int internal_setByteData(ByteData data, int offset, dynamic b) {
  final length = (b.lengthInBytes) as int;
  data.buffer.asUint8List().setRange(offset, offset + length, b.buffer.asUint8List());
  return offset + length;
}

extension ByteDataUtils on ByteData {
  int setFloat(int offset, double v) => internal_setFloat(this, offset, v);
  int setInt(int offset, int v) => internal_setInt(this, offset, v);
  int setVec2(int offset, Vector2 v) => internal_setVec2(this, offset, v);
  int setVec3(int offset, Vector3 v) => internal_setVec3(this, offset, v);
  int setVec4(int offset, Vector4 v) => internal_setVec4(this, offset, v);
  int setMat2(int offset, Matrix2 m) => internal_setMat2(this, offset, m);
  int setMat3(int offset, Matrix3 m) => internal_setMat3(this, offset, m);
  int setMat4(int offset, Matrix4 m) => internal_setMat4(this, offset, m);
  int setByteData(int offset, ByteData b) => internal_setByteData(this, offset, b);
}
