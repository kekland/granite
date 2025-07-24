import 'dart:typed_data';

import 'package:granite/renderer/utils/byte_data_utils.dart';
import 'package:granite/spec/spec.dart' as spec;

abstract class PropInstruction {
  PropInstruction({required this.sizeInBytes, this.memberName});

  final String? memberName;
  final int sizeInBytes;

  int execute(spec.EvaluationContext context, spec.Layer layer, ByteData data, int offset);
}

class SetPropInstruction extends PropInstruction {
  SetPropInstruction({
    required this.propertySymbol,
    required this.setter,
    required super.sizeInBytes,
    super.memberName,
  });

  final Symbol propertySymbol;
  final internal_ByteDataSetter setter;

  @override
  int execute(spec.EvaluationContext context, spec.Layer layer, ByteData data, int offset) {
    final prop = layer.paint!.getProperty(propertySymbol);
    final value = prop.evaluate(context);
    return setter(data, offset, value);
  }

  @override
  String toString() => 'SetPropInstruction($propertySymbol, $memberName)';
}

class SetPropWithCrossFadeInstruction extends PropInstruction {
  SetPropWithCrossFadeInstruction({
    required this.propertySymbol,
    required this.setter,
    required super.sizeInBytes,
    super.memberName,
  });

  final Symbol propertySymbol;
  final internal_ByteDataSetter setter;

  @override
  int execute(spec.EvaluationContext context, spec.Layer layer, ByteData data, int offset) {
    final prop = layer.paint!.getProperty(propertySymbol);
    final startValue = prop.evaluate(context.copyWithZoom(context.zoom.floorToDouble()));
    final endValue = prop.evaluate(context.copyWithZoom(context.zoom.ceilToDouble()));

    offset = setter(data, offset, startValue);
    offset = setter(data, offset, endValue);

    return offset;
  }

  @override
  String toString() => 'SetPropWithCrossFadeInstruction($propertySymbol, $memberName)';
}

double _getNearestCeilValue(double value, List<double> stops) {
  for (final stop in stops) {
    if (value <= stop) return stop;
  }

  return stops.last;
}

double _getNearestFloorValue(double value, List<double> stops) {
  for (final stop in stops.reversed) {
    if (value >= stop) return stop;
  }

  return stops.first;
}

class SetPropInterpolationStopsInstruction extends PropInstruction {
  SetPropInterpolationStopsInstruction({
    required this.stops,
    super.memberName,
  }) : super(sizeInBytes: 16);

  final List<double> stops;

  @override
  int execute(spec.EvaluationContext context, spec.Layer layer, ByteData data, int offset) {
    final lower = _getNearestFloorValue(context.zoom, stops);
    final upper = _getNearestCeilValue(context.zoom, stops);

    offset = data.setFloat(offset, lower);
    offset = data.setFloat(offset, upper);

    return offset;
  }

  @override
  String toString() => 'SetPropInterpolationStopsInstruction($stops, $memberName)';
}

class SetPropWithInterpolationInstruction extends PropInstruction {
  SetPropWithInterpolationInstruction({
    required this.propertySymbol,
    required this.stops,
    required this.setter,
    required super.sizeInBytes,
    super.memberName,
  });

  final Symbol propertySymbol;
  final List<double> stops;
  final internal_ByteDataSetter setter;

  @override
  int execute(spec.EvaluationContext context, spec.Layer layer, ByteData data, int offset) {
    final prop = layer.paint!.getProperty(propertySymbol);

    final lower = _getNearestFloorValue(context.zoom, stops);
    final upper = _getNearestCeilValue(context.zoom, stops);

    final startValue = prop.evaluate(context.copyWithZoom(lower));
    final endValue = prop.evaluate(context.copyWithZoom(upper));

    offset = setter(data, offset, startValue);
    offset = setter(data, offset, endValue);

    return offset;
  }

  @override
  String toString() => 'SetPropWithInterpolationInstruction($propertySymbol, $stops, $memberName)';
}
