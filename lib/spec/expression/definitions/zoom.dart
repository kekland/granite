import '../_definition_imports.dart';

@ExpressionAnnotation('ZoomExpression', rawName: 'zoom', ownDependencies: ExpressionDependency.camera)
num zoomExpressionImpl(EvaluationContext context) => context.zoom;
