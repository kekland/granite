import 'package:equatable/equatable.dart';

/// A class representing a locale in the context of the style spec.
/// 
/// Mirror `dart:ui` class is `ui.Locale`, but it can't be used due to the need to run the code in a Dart-only context.
class Locale with EquatableMixin {
  const Locale({required this.languageCode, this.scriptCode});

  /// Language code of the locale, as defined by ISO 639-1.
  final String languageCode;

  /// Optional script code of the locale, as defined by ISO 15924.
  final String? scriptCode;

  @override
  List<Object?> get props => [languageCode, scriptCode];
}
