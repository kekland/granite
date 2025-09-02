/// A class representing a locale in the context of the style spec.
///
/// Mirror `dart:ui` class is `ui.Locale`, but it can't be used due to the need to run the code in a Dart-only context.
class Locale {
  const Locale({required this.languageCode, this.scriptCode});

  /// Language code of the locale, as defined by ISO 639-1.
  final String languageCode;

  /// Optional script code of the locale, as defined by ISO 15924.
  final String? scriptCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Locale && other.languageCode == languageCode && other.scriptCode == scriptCode;
  }

  @override
  int get hashCode => Object.hash(languageCode, scriptCode);
}
