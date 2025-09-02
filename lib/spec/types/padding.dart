/// A class representing padding in the context of the style spec.
class Padding {
  const Padding({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  /// Creates a padding with the same value on all sides.
  const Padding.all(num value) : top = value, right = value, bottom = value, left = value;

  final num top;
  final num right;
  final num bottom;
  final num left;

  /// Creates a padding from a JSON array.
  ///
  /// Depending on the length of the JSON array, the padding will be created as follows:
  /// - 1: All sides will have the same value.
  /// - 2: The first value will be used for the vertical sides and the second value for the horizontal sides.
  /// - 3: The first value will be used for the top side, the second value for the horizontal sides, and the third value
  ///   for the bottom side.
  /// - 4: The values will be used for the top, right, bottom, and left sides, respectively.
  factory Padding.fromJson(List<num> json) {
    if (json.length == 1) {
      return Padding.all(json[0]);
    } else if (json.length == 2) {
      final vertical = json[0];
      final horizontal = json[1];

      return Padding(top: vertical, right: horizontal, bottom: vertical, left: horizontal);
    } else if (json.length == 3) {
      final top = json[0];
      final horizontal = json[1];
      final bottom = json[2];

      return Padding(top: top, right: horizontal, bottom: bottom, left: horizontal);
    } else if (json.length == 4) {
      return Padding(
        top: json[0],
        right: json[1],
        bottom: json[2],
        left: json[3],
      );
    }

    throw Exception('Invalid padding value: $json');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Padding && other.top == top && other.right == right && other.bottom == bottom && other.left == left;
  }

  @override
  int get hashCode => Object.hash(top, right, bottom, left);
}
