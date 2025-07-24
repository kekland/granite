import 'package:equatable/equatable.dart';
import 'package:granite/spec/spec.dart';

/// A collator object that specifies the order in which strings should be sorted in the style spec.
class Collator with EquatableMixin {
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
  List<Object?> get props => [caseSensitive, diacriticSensitive, locale];
}
