import 'package:vector_math/vector_math_64.dart' as vm;

vm.Vector2 vector2FromJson(List<dynamic> json) {
  if (json.length != 2) {
    throw ArgumentError('Expected a list of 2 numbers for Vector2, got: $json');
  }
  return vm.Vector2((json[0] as num).toDouble(), (json[1] as num).toDouble());
}

vm.Vector3 vector3FromJson(List<dynamic> json) {
  if (json.length != 3) {
    throw ArgumentError('Expected a list of 3 numbers for Vector3, got: $json');
  }
  return vm.Vector3((json[0] as num).toDouble(), (json[1] as num).toDouble(), (json[2] as num).toDouble());
}

vm.Vector4 vector4FromJson(List<dynamic> json) {
  if (json.length != 4) {
    throw ArgumentError('Expected a list of 4 numbers for Vector4, got: $json');
  }

  return vm.Vector4(
    (json[0] as num).toDouble(),
    (json[1] as num).toDouble(),
    (json[2] as num).toDouble(),
    (json[3] as num).toDouble(),
  );
}
