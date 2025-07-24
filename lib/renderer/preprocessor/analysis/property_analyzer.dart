import 'package:granite/spec/spec.dart' as spec;

/// How the property is passed to the shader.
enum PropertyShaderType { uniform, sampler, attribute, constant }

/// How the property is interpolated.
enum PropertyInterpolation { crossfade, interpolate, step }

/// Results of property analysis.
///
/// Property analysis checks what dependencies a property's expression has, and determines what kind of data
/// should be passed to the shader.
///
/// It'll also try to optimize the data passed. For example, if the property is data-driven, but it only depends on the
/// camera zoom, then instead of passing the data as vertex attributes, it'll be passed as a uniform.
class PropertyAnalysis {
  PropertyAnalysis({required this.type, this.interpolation, this.constantValue, this.interpolationStops});

  /// Type of how the property is passed to the shader: uniform, attribute, or constant (baked-in).
  final PropertyShaderType type;

  /// Whether the property is interpolated, and if so, how.
  final PropertyInterpolation? interpolation;

  /// If the property has interpolation, the interpolation stops.
  final List<double>? interpolationStops;

  /// If the property is constant, the constant value.
  final Object? constantValue;

  @override
  String toString() {
    final interpolationStr = interpolation != null ? ', interpolation: $interpolation' : '';
    final stopsStr = interpolationStops != null ? ', stops: $interpolationStops' : '';
    final constantStr = constantValue != null ? ', constant: $constantValue' : '';
    return 'PropertyAnalysis(type: $type$interpolationStr$stopsStr$constantStr)';
  }
}

/// An empty evaluation context to use for constant property evaluation.
const _emptyEvaluationContext = spec.EvaluationContext.empty();

/// Analyzes a given property.
///
/// See [PropertyAnalysis] on what the analysis results mean.
PropertyAnalysis analyzeProperty(spec.Property prop) {
  final hasExpression = prop.expression != null;
  final dependencies = hasExpression ? prop.expression!.dependencies : const <spec.ExpressionDependency>{};

  final hasDependencies = dependencies.isNotEmpty;
  final hasDataDependency = hasExpression && dependencies.contains(spec.ExpressionDependency.data);
  final hasCameraDependency = hasExpression && dependencies.contains(spec.ExpressionDependency.camera);

  if (prop is spec.ConstantProperty || !hasExpression || !hasDependencies) {
    // Property value is always constant, no matter the evaluation context.
    // Shader receives the value baked into the shader.
    //
    // This can happen if the property is declared as a [spec.ConstantProperty], or if property has no expression, or if
    // the expression has no dependencies.
    final value = prop.evaluate(_emptyEvaluationContext);
    return PropertyAnalysis(type: PropertyShaderType.constant, constantValue: value);
  }
  //
  else if (prop is spec.DataConstantProperty) {
    // Property value is the same for all features.
    // Shader receives the value as a uniform.
    //
    // This can happen if the property is declared as a [spec.DataConstantProperty].
    assert(!prop.expression!.dependencies.contains(spec.ExpressionDependency.data));
    return PropertyAnalysis(type: PropertyShaderType.uniform);
  }
  //
  else if (prop is spec.CrossFadedProperty || (prop is spec.CrossFadedDataDrivenProperty && !hasDataDependency)) {
    // Property value is the same for all features.
    // Output is cross-faded between two values based on a zoom-dependent interpolation.
    // Shader receives two values to cross-fade between as a uniform.
    //
    // This can happen if the property is declared as a [spec.CrossFadedProperty], or if the property has no data
    // dependencies.
    return PropertyAnalysis(type: PropertyShaderType.uniform, interpolation: PropertyInterpolation.crossfade);
  }
  //
  else if (prop is spec.CrossFadedDataDrivenProperty) {
    // Property value is different between features.
    // Output is cross-faded between two values based on a zoom-dependent interpolation.
    // Shader receives two values to cross-fade between as a vertex attribute.
    assert(prop.expression!.dependencies.contains(spec.ExpressionDependency.data));
    return PropertyAnalysis(type: PropertyShaderType.attribute, interpolation: PropertyInterpolation.crossfade);
  }
  //
  else if (prop is spec.DataDrivenProperty) {
    // Property value is different between features.
    //
    // Depending on the expression type, the following will happen:
    // 1. Zoom is used (subsequently as an input to a step/interpolation):
    //    - Shader will receive the interpolation values for the two nearest zoom levels as vertex attributes
    //    - Shader will have the interpolation code baked in
    //    - Result is interpolated between the two values based on the zoom level
    // 2. Zoom is not used:
    //    - Shader will receive the value as a vertex attribute
    if (hasCameraDependency) {
      if (prop.expression! is spec.StepExpression) {
        final stepExpr = prop.expression! as spec.StepExpression;

        return PropertyAnalysis(
          type: PropertyShaderType.attribute,
          interpolation: PropertyInterpolation.step,
          interpolationStops: stepExpr.stops.map((stop) => stop.$1.toDouble()).toList(),
        );
      } else if (prop.expression! is spec.InterpolateExpression) {
        final interpolateExpr = prop.expression! as spec.InterpolateExpression;

        // TODO: Interpolation settings

        return PropertyAnalysis(
          type: PropertyShaderType.attribute,
          interpolation: PropertyInterpolation.interpolate,
          interpolationStops: interpolateExpr.stops.map((stop) => stop.$1.toDouble()).toList(),
        );
      } else {
        throw UnimplementedError('Expression type not supported: ${prop.expression!.runtimeType}');
      }
    } else {
      return PropertyAnalysis(type: PropertyShaderType.attribute);
    }
  } else {
    throw UnimplementedError('Property type not supported: $prop');
  }
}
