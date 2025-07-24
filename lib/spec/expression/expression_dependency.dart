/// The outside data that the expression depends on for evaluation.
///
/// The data used is obtained from the [EvaluationContext]. Depending on which properties are used, the expression can
/// be optimized to precompute values, or to evaluate only the necessary data.
enum ExpressionDependency {
  /// This expression depends on the feature data.
  data,

  /// This expression depends on the camera state.
  camera,

  /// This expression depends on the locale.
  locale,
}
