/// A class that represents a key to an image in the style spec. This class is an extension type of [String].
///
/// An image in the style spec is an element in one of the style's spritesheets.
///
/// The value of this class consists of:
/// - (optional) Spritesheet name, e.g. `buildings`, `roadsigns`, etc
/// - Sprite name
///
/// If spritesheet name is provided, it'll be separated from the sprite name by a colon (`:`). You can use the internal
/// getters [spritesheetName] and [spriteName] to get those values.
extension type ResolvedImage(String image) {
  List<String> get _parts => image.split(':');

  /// The name of the spritesheet, if provided.
  String? get spritesheetName {
    final parts = _parts;
    return parts.length == 2 ? parts.first : null;
  }

  /// The name of the sprite.
  String get spriteName {
    final parts = _parts;
    return parts.length == 2 ? parts.last : parts.first;
  }
}
