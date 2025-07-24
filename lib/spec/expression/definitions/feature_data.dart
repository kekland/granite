import '../_definition_imports.dart';

@ExpressionAnnotation('PropertiesExpression', rawName: 'properties', ownDependencies: ExpressionDependency.data)
Map<String, dynamic> propertiesExpressionImpl(EvaluationContext context) {
  return context.properties;
}

@ExpressionAnnotation('FeatureStateExpression', rawName: 'feature-state', ownDependencies: ExpressionDependency.data)
dynamic featureStateExpressionImpl(EvaluationContext context, Expression<String> key) {
  return context.getFeatureState(key(context));
}

@ExpressionAnnotation('GeometryTypeExpression', rawName: 'geometry-type', ownDependencies: ExpressionDependency.data)
String geometryTypeExpressionImpl(EvaluationContext context) {
  return context.geometryType;
}

@ExpressionAnnotation('IdExpression', rawName: 'id', ownDependencies: ExpressionDependency.data)
String? idExpressionImpl(EvaluationContext context) {
  return context.id;
}

@ExpressionAnnotation('LineProgressExpression', rawName: 'line-progress')
double lineProgressExpressionImpl(EvaluationContext context) {
  // TODO
  return context.lineProgress ?? 0.0;
}

@ExpressionAnnotation('AccumulatedExpression', rawName: 'accumulated')
double accumulatedExpressionImpl(EvaluationContext context, Expression<String> key) {
  // TODO
  return 0.0;
}
