/// An annotation that's used to annotate the implementation of an expression.
/// 
/// [name] is the name of the generated Dart class, while [rawName] is the name of the expression in the JSON.
/// 
/// Serialization to/from JSON, equality, and anything related are generated automatically. If you need to override
/// the [fromJson] method, you can set the value for [customFromJson].
/// 
/// The code generator is located in `tool/spec/generate_expressions.dart`, and the output is located in 
/// `lib/src/spec/gen/expressions.gen.dart`.
class ExpressionAnnotation {
  const ExpressionAnnotation(
    this.name, {
    required this.rawName,
    this.customFromJson,
    this.ownDependencies,
  });

  /// The name of the generated Dart class.
  final String name;
  
  /// The name of the expression as in the JSON spec.
  final String rawName; 

  /// A custom implementation of the `fromJson` method.
  /// 
  /// Usually not needed, as the code generator will generate the method for you. However, there are some specific cases
  /// where this might be useful.
  final Object Function(List<dynamic> args)? customFromJson;

  /// The type of the dependency that the expression uses. This field's type can be:
  /// 
  /// - `ExpressionDependence` - to specify a single dependency.
  /// - `Set<ExpressionDependence>` - to specify multiple dependencies.
  /// - `String` - to specify a dependency based on some code provided as a string.
  /// - `null` - to specify that the dependency is based automatically on the dependencies of the children expressions.
  /// 
  /// If set to `null`, the dependency is based automatically on the dependencies of the children expressions.
  final dynamic ownDependencies;
}
