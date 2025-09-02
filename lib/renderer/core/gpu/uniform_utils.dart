import 'package:flutter_gpu/gpu.dart' as gpu;

Map<(String, String), int?> _uniformOffsetCache = {};

int? getUniformMemberOffset(gpu.UniformSlot slot, String memberName) {
  final key = (slot.uniformName, memberName);
  // if (_uniformOffsetCache.containsKey(key)) return _uniformOffsetCache[key];

  final offset = slot.getMemberOffsetInBytes(memberName);
  // _uniformOffsetCache[key] = offset;
  return offset;
}
