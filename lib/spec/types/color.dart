import '../utils/color_utils.dart';
import '../utils/parse_css_color.dart';

import 'package:vector_math/vector_math_64.dart';

/// A type that represents a color in the style spec.
///
/// It's an extension type of [Vector4] to simplify its usage in shaders.
///
/// Mirror `dart:ui` class is `ui.Color`, but it can't be used due to the need to run the code in a Dart-only context.
extension type Color._(Vector4 vec) {
  Color({required double r, required double g, required double b, double a = 1.0}) : this._(Vector4(r, g, b, a));

  /// Creates a new color from a list of numbers.
  ///
  /// The list must have at least 3 numbers, representing the red, green, and blue channels in the range 0-255.
  ///
  /// The fourth element is optional and represents the alpha channel in range 0-1. If it's not provided, default alpha
  /// value of 1.0 is used.
  factory Color.fromList(List<num> value) {
    return Color(
      r: value[0] / 255,
      g: value[1] / 255,
      b: value[2] / 255,
      a: value.length == 4 ? value[3].toDouble() : 1.0,
    );
  }

  /// Creates a new color from HSL(A) values.
  factory Color.fromHsl(double h, double s, double l, [double a = 1.0]) {
    return hslToRgb(h, s, l, a);
  }

  /// Creates a new color from a CSS color string.
  factory Color.fromJson(String value) {
    return parseCssColor(value);
  }

  /// Returns the red channel of the color in range `0-1`.
  double get r => vec.r;

  /// Returns the green channel of the color in range `0-1`.
  double get g => vec.g;

  /// Returns the blue channel of the color in range `0-1`.
  double get b => vec.b;

  /// Returns the alpha channel of the color in range `0-1`.
  double get a => vec.a;

  /// Returns the color representation as a list of numbers.
  List<double> get asRgbaList => vec.storage;
}
