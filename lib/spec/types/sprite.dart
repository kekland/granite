import 'package:collection/collection.dart';

/// A class that represents a list of sprite sources in the style spec.
///
/// These sprite sources are loaded from the network and used to render images in the map.
class Sprite {
  const Sprite({required this.sources});

  final List<SpriteSource> sources;

  /// Parses a [Sprite] from a JSON object.
  ///
  /// If the object is a `String`, it's assumed to be the url of a default spritesheet with no `id`.
  factory Sprite.fromJson(dynamic json) {
    if (json is String) {
      return Sprite(sources: [SpriteSource(url: json)]);
    } else if (json is List) {
      return Sprite(sources: json.map((e) => SpriteSource.fromJson(e as Map<String, dynamic>)).toList());
    } else {
      throw Exception('Invalid [Sprite] value: $json');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sprite && const ListEquality().equals(other.sources, sources);
  }

  @override
  int get hashCode => const ListEquality().hash(sources);
}

/// A class that represents a sprite source in the style spec.
class SpriteSource {
  const SpriteSource({this.id, required this.url});

  factory SpriteSource.fromJson(Map<String, dynamic> json) {
    return SpriteSource(id: json['id'] as String, url: json['url'] as String);
  }

  /// The identifier of this spritesheet.
  ///
  /// If the id is `null`, it's the default spritesheet, meaning it's used when an image is requested without specifying
  /// the stylesheet identifier.
  ///
  /// Example:
  /// - `stop_sign` -> uses sprite `stop_sign` in stylesheet with id `null`
  /// - `buildings:hospital` -> uses sprite `hospital` in stylesheet with id `buildings`
  final String? id;

  /// The url from which the sprite is loaded.
  ///
  /// Url should be suffixed with:
  /// - `.json` - to load the sprite index file
  /// - `.png` - to load the sprite image file
  ///
  /// You can use the [getIndexUri] and [getImageUri] methods to get the correct uri for the sprite.
  final String url;

  /// Returns the [Uri] for the sprite index file.
  ///
  /// If [isHighDpi] is `true`, the uri will be suffixed with `@2x` to get the high-dpi version of the sprite.
  Uri getIndexUri({bool isHighDpi = false}) {
    return Uri.parse('$url${isHighDpi ? '@2x' : ''}.json');
  }

  /// Returns the [Uri] for the sprite image file.
  ///
  /// If [isHighDpi] is `true`, the uri will be suffixed with `@2x` to get the high-dpi version of the sprite.
  Uri getImageUri({bool isHighDpi = false}) {
    return Uri.parse('$url${isHighDpi ? '@2x' : ''}.png');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpriteSource && other.id == id && other.url == url;
  }

  @override
  int get hashCode => Object.hash(id, url);
}

/// An enum that specifies how sprite should be resized to fit the text.
enum SpriteTextFit {
  /// The sprite should be stretched or shrunk to fit the text.
  stretchOrShrink,

  /// The sprite will only be stretched to fit the text.
  stretchOnly;

  static SpriteTextFit fromJson(String json) {
    return switch (json) {
      'stretchOrShrink' => SpriteTextFit.stretchOrShrink,
      'stretchOnly' => SpriteTextFit.stretchOnly,
      _ => throw Exception('Unsupported SpriteTextFit value: $json'),
    };
  }
}

/// A class that represents the sprite index that's fetched from the network.
///
/// A sprite index is simply a mapping of sprite names to their respective data (see [SpriteData]).
class SpriteIndex {
  const SpriteIndex({required this.sprites});

  factory SpriteIndex.fromJson(Map<String, dynamic> json) {
    return SpriteIndex(
      sprites: json.map((key, value) => MapEntry(key, SpriteData.fromJson(value as Map<String, dynamic>))),
    );
  }

  final Map<String, SpriteData> sprites;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpriteIndex && const MapEquality().equals(other.sprites, sprites);
  }

  @override
  int get hashCode => const MapEquality().hash(sprites);
}

/// A class that represents the data of a single sprite in the style spec.
class SpriteData {
  const SpriteData({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.pixelRatio,
    this.content,
    this.stretchX,
    this.stretchY,
    this.sdf = false,
    this.textFitWidth = SpriteTextFit.stretchOrShrink,
    this.textFitHeight = SpriteTextFit.stretchOrShrink,
  });

  factory SpriteData.fromJson(Map<String, dynamic> json) {
    return SpriteData(
      width: json['width'] as int,
      height: json['height'] as int,
      x: json['x'] as int,
      y: json['y'] as int,
      pixelRatio: (json['pixelRatio'] as num).toDouble(),
      content: json['content'] != null ? (json['content'] as List).cast<int>() : null,
      stretchX: json['stretchX'] != null ? (json['stretchX'] as List).cast<int>() : null,
      stretchY: json['stretchY'] != null ? (json['stretchY'] as List).cast<int>() : null,
      sdf: json['sdf'] != null ? json['sdf'] as bool : false,
      textFitWidth: json['textFitWidth'] != null
          ? SpriteTextFit.fromJson(json['textFitWidth'] as String)
          : SpriteTextFit.stretchOrShrink,
      textFitHeight: json['textFitHeight'] != null
          ? SpriteTextFit.fromJson(json['textFitHeight'] as String)
          : SpriteTextFit.stretchOrShrink,
    );
  }

  final int width;
  final int height;
  final int x;
  final int y;
  final double pixelRatio;

  final List<int>? content;
  final List<int>? stretchX;
  final List<int>? stretchY;
  final bool sdf;

  final SpriteTextFit textFitWidth;
  final SpriteTextFit textFitHeight;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpriteData &&
        other.width == width &&
        other.height == height &&
        other.x == x &&
        other.y == y &&
        other.pixelRatio == pixelRatio &&
        const ListEquality<int>().equals(other.content, content) &&
        const ListEquality<int>().equals(other.stretchX, stretchX) &&
        const ListEquality<int>().equals(other.stretchY, stretchY) &&
        other.sdf == sdf &&
        other.textFitWidth == textFitWidth &&
        other.textFitHeight == textFitHeight;
  }

  @override
  int get hashCode {
    return Object.hash(
      width,
      height,
      x,
      y,
      pixelRatio,
      const ListEquality<int>().hash(content),
      const ListEquality<int>().hash(stretchX),
      const ListEquality<int>().hash(stretchY),
      sdf,
      textFitWidth,
      textFitHeight,
    );
  }
}
