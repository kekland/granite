import 'package:granite/spec/spec.dart';

/// A collator object that specifies the order in which strings should be sorted in the style spec.
class Collator {
  const Collator({
    this.caseSensitive = false,
    this.diacriticSensitive = false,
    this.locale,
  });

  /// Whether the comparison should be case-sensitive.
  final bool caseSensitive;

  /// Whether the comparison should be diacritic-sensitive.
  final bool diacriticSensitive;

  /// The locale to use for the comparison. If not provided, the default locale will be used.
  final Locale? locale;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Collator &&
        other.caseSensitive == caseSensitive &&
        other.diacriticSensitive == diacriticSensitive &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(caseSensitive, diacriticSensitive, locale);
}
