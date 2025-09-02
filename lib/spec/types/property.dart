// ignore_for_file: null_check_on_nullable_type_parameter

import '../utils/type_utils.dart';
import '../utils/vector_json_utils.dart';

import 'package:granite/spec/spec.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

T? _parseJsonForKnownTypes<T>(dynamic json) {
  if (json is T) {
    return json;
  } else if ((T == List<num>) && json is List && isListWithElementType<num>(json)) {
    return json.cast<num>() as T;
  } else if ((T == vm.Vector2) && json is List && isListWithElementType<num>(json) && json.length == 2) {
    return vector2FromJson(json) as T;
  } else if ((T == vm.Vector3) && json is List && isListWithElementType<num>(json) && json.length == 3) {
    return vector3FromJson(json) as T;
  } else if ((T == vm.Vector4) && json is List && isListWithElementType<num>(json) && json.length == 4) {
    return vector4FromJson(json) as T;
  } else if ((T == List<String>) && json is List && isListWithElementType<String>(json)) {
    return json.cast<String>() as T;
  } else if (T == Color && json is String) {
    return Color.fromJson(json) as T;
  } else if (T == Formatted && json is String) {
    return Formatted.fromJson(json) as T;
  } else if (T == Padding && json is List && isListWithElementType<num>(json)) {
    return Padding.fromJson(json.cast<num>()) as T;
  } else if (T == ResolvedImage && json is String) {
    return ResolvedImage(json) as T;
  } else if (T == Sprite && (json is String || json is List)) {
    return Sprite.fromJson(json) as T;
  } else if (T == VariableAnchorOffsetCollection) {
    return VariableAnchorOffsetCollection.fromJson(json) as T;
  } else if (isTypeEnum<T>() && json is String) {
    return parseEnumJson<T>(json);
  } else {
    return null;
  }
}

abstract class Property<T> {
  Property({required this.isExpression, this.value, this.expression, this.defaultValue});

  Property.value(this.value, {this.defaultValue}) : expression = null, isExpression = false;

  Property.expression(this.expression, {this.defaultValue}) : value = null, isExpression = true;

  final T? value;
  final Expression<T>? expression;
  final T? defaultValue;
  final Type type = T;

  final bool isExpression;

  T evaluate(EvaluationContext context) {
    if (isExpression) {
      try {
        return expression!.evaluate(context);
      } catch (e) {
        print('Error evaluating expression: $e. Using default value: $defaultValue');
        return defaultValue!;
      }
    } else {
      return value!;
    }
  }

  Set<ExpressionDependency> get dependencies => expression?.dependencies ?? const {};
}

class ConstantProperty<T> extends Property<T> {
  ConstantProperty.value(T super.value, {super.defaultValue}) : super.value();

  factory ConstantProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return ConstantProperty.value(value);

    throw UnimplementedError();
  }

  ConstantProperty<T> withDefaultValue(T? defaultValue) {
    return ConstantProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
  }
}

class DataDrivenProperty<T> extends Property<T> {
  DataDrivenProperty.value(T super.value, {super.defaultValue}) : super.value();
  DataDrivenProperty.expression(Expression<T> super.expression, {super.defaultValue}) : super.expression();

  factory DataDrivenProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return DataDrivenProperty.value(value);

    return DataDrivenProperty.expression(Expression<T>.fromJson(json));
  }

  DataDrivenProperty<T> withDefaultValue(T? defaultValue) {
    if (isExpression) {
      return DataDrivenProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return DataDrivenProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}

class CrossFadedProperty<T> extends Property<T> {
  CrossFadedProperty.value(T super.value, {super.defaultValue}) : super.value();
  CrossFadedProperty.expression(Expression<T> super.expression, {super.defaultValue}) : super.expression();

  factory CrossFadedProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return CrossFadedProperty.value(value);

    return CrossFadedProperty.expression(Expression<T>.fromJson(json));
  }

  CrossFadedProperty<T> withDefaultValue(T? defaultValue) {
    if (isExpression) {
      return CrossFadedProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return CrossFadedProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}

class DataConstantProperty<T> extends Property<T> {
  DataConstantProperty.value(T super.value, {super.defaultValue}) : super.value();
  DataConstantProperty.expression(Expression<T> super.expression, {super.defaultValue}) : super.expression();

  factory DataConstantProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return DataConstantProperty.value(value);

    return DataConstantProperty.expression(Expression<T>.fromJson(json));
  }

  DataConstantProperty<T> withDefaultValue(T? defaultValue) {
    if (isExpression) {
      return DataConstantProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return DataConstantProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}

class ColorRampProperty extends Property<Color> {
  ColorRampProperty.value(Color super.value, {super.defaultValue}) : super.value();
  ColorRampProperty.expression(Expression<Color> super.expression, {super.defaultValue}) : super.expression();

  factory ColorRampProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<Color>(json);
    if (value != null) return ColorRampProperty.value(value);

    return ColorRampProperty.expression(Expression<Color>.fromJson(json));
  }

  ColorRampProperty withDefaultValue(Color? defaultValue) {
    if (isExpression) {
      return ColorRampProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return ColorRampProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}

class CrossFadedDataDrivenProperty<T> extends Property<T> {
  CrossFadedDataDrivenProperty.value(T super.value, {super.defaultValue}) : super.value();
  CrossFadedDataDrivenProperty.expression(Expression<T> super.expression, {super.defaultValue}) : super.expression();

  factory CrossFadedDataDrivenProperty.fromJson(dynamic json) {
    final value = _parseJsonForKnownTypes<T>(json);
    if (value != null) return CrossFadedDataDrivenProperty.value(value);

    return CrossFadedDataDrivenProperty.expression(Expression<T>.fromJson(json));
  }

  CrossFadedDataDrivenProperty<T> withDefaultValue(T? defaultValue) {
    if (isExpression) {
      return CrossFadedDataDrivenProperty.expression(expression!, defaultValue: defaultValue ?? this.defaultValue);
    } else {
      return CrossFadedDataDrivenProperty.value(value!, defaultValue: defaultValue ?? this.defaultValue);
    }
  }
}
