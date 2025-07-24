import 'package:granite/spec/spec.dart';

/// The context with which an [Expression] is evaluated.
class EvaluationContext {
  const EvaluationContext({
    this.id,
    required this.geometryType,
    required this.zoom,
    required this.locale,
    this.lineProgress,
    Map<String, Expression>? bindings,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? featureState,
  }) : bindings = bindings ?? const {},
       properties = properties ?? const {},
       featureState = featureState ?? const {};

  const EvaluationContext.empty()
    : id = null,
      geometryType = '',
      zoom = 0,
      locale = const Locale(languageCode: 'en'),
      lineProgress = null,
      bindings = const {},
      properties = const {},
      featureState = const {};

  /// The ID of the feature being evaluated.
  final String? id;

  /// The type of the feature's geometry being evaluated.
  final String geometryType;

  /// The progress along a line feature being evaluated.
  ///
  /// Only available in GeoJSON sources that have line metrics enabled.
  final double? lineProgress;

  /// The current camera zoom level.
  ///
  /// If evaluted during the layout phase, the zoom level can only be an integer. During the paint phase, it can be
  /// any valid floating point number.
  final double zoom;

  /// The locale that's used for formatting text.
  final Locale locale;

  /// The bindings that are available to the current expression.
  ///
  /// Bindings can come from the [LetExpression] expression, and can be used by other expressions via [VarExpression].
  final Map<String, Expression> bindings;

  /// The properties of the feature being evaluated.
  ///
  /// This comes from the feature's properties in the source data.
  final Map<String, dynamic> properties;

  /// The feature state of the feature being evaluated.
  ///
  /// Currently unsupported, but maybe one day.
  final Map<String, dynamic> featureState;

  /// Extends this evaluation context with the provided values.
  ///
  /// For example, if you want to add a new variable binding, you can do:
  /// - `.extendWith(bindings: {'foo': LiteralExpression<String>('bar')})`
  ///
  /// This method will keep all previously set values for bindings, properties, and featureState, and will add the new
  /// values on top of the existing map with a spread operator.
  EvaluationContext extendWith({
    Map<String, Expression>? bindings,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? featureState,
  }) {
    return EvaluationContext(
      id: id,
      geometryType: geometryType,
      lineProgress: lineProgress,
      locale: locale,
      zoom: zoom,
      bindings: {...this.bindings, ...?bindings},
      properties: {...this.properties, ...?properties},
      featureState: {...this.featureState, ...?featureState},
    );
  }

  /// Creates a copy of this evaluation context with the provided values.
  ///
  /// Unset values will be copied from the existing context.
  EvaluationContext copyWith({
    String? id,
    String? geometryType,
    double? lineProgress,
    double? zoom,
    Locale? locale,
    Map<String, Expression>? bindings,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? featureState,
  }) {
    return EvaluationContext(
      id: id ?? this.id,
      geometryType: geometryType ?? this.geometryType,
      lineProgress: lineProgress ?? this.lineProgress,
      locale: locale ?? this.locale,
      zoom: zoom ?? this.zoom,
      bindings: bindings ?? this.bindings,
      properties: properties ?? this.properties,
      featureState: featureState ?? this.featureState,
    );
  }

  /// Creates a copy of this evaluation context with a given zoom.
  EvaluationContext copyWithZoom(double zoom) {
    return EvaluationContext(
      id: id,
      geometryType: geometryType,
      lineProgress: lineProgress,
      locale: locale,
      zoom: zoom,
      bindings: bindings,
      properties: properties,
      featureState: featureState,
    );
  }

  /// Returns the variable binding with the provided name.
  ///
  /// Returns `null` if the variable binding doesn't exist.
  Expression? getBinding(String name) => bindings[name];

  /// Returns the feature property with the provided name.
  ///
  /// Returns `null` if the property doesn't exist.
  dynamic getProperty(String name) => properties[name];

  /// Returns the feature state with the provided name.
  ///
  /// Returns `null` if the feature state doesn't exist.
  dynamic getFeatureState(String name) => featureState[name];

  /// Returns `true` if a variable binding with the provided name exists.
  bool hasBinding(String name) => bindings.containsKey(name);

  /// Returns `true` if a property with the provided name exists.
  bool hasProperty(String name) => properties.containsKey(name);

  /// Returns `true` if a feature state with the provided name exists.
  bool hasFeatureState(String name) => featureState.containsKey(name);
}
