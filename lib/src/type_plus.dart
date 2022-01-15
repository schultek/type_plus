import 'resolved_type.dart';
import 'type_info.dart';
import 'type_switcher.dart';
import 'types_registry.dart';

/// Used to deconstruct a generic type
extension TypePlus on Type {
  ResolvedType get _resolved => ResolvedType.from(this);

  /// The base type of a generic type, with all type arguments set to dynamic
  Type get base => _resolved.base;

  /// The type arguments of a generic type
  List<Type> get args => _resolved.argsAsTypes;

  /// The name of the type, without any type arguments
  String get name => TypeInfo.name(this);

  /// The unique id of a type
  String get id => _resolved.id;

  /// The base id of a type
  /// * This can be different to base.id when using type bounds
  ///   and ensures to not contain any type arguments' ids
  String get baseId => _resolved.baseId;

  /// Indicates if this type is nullable
  bool get isNullable => _resolved.isNullable;

  /// Check if a type implements or extends another type
  /// e.g. int implements num, List implements Iterable
  bool implements<T>([Type? t]) => _resolved.implements(t ?? T);

  /// Check if a type is implemented by another type
  bool implementedBy<T>([Type? t]) => (t ?? T).implements(this);

  /// Adds a non-generic type, used as a simpler syntax to [addFactory]
  static void add<T>({String? id, Iterable<Type>? superTypes}) =>
      TypeRegistry.instance.add((f) => f<T>(),
          id: id,
          superTypes: superTypes?.map(
              (t) => (Function<T>() f) => f.callWith(typeArguments: [t])));

  /// Adds a type factory for any generic or non-generic type
  /// @param id: An optional unique id for this type, that will override the default id
  static void addFactory(Function factory,
          {String? id, Iterable<Function>? superTypes}) =>
      TypeRegistry.instance.add(factory, id: id, superTypes: superTypes);

  /// Registers a type provider to be used
  static void register(TypeProvider provider) =>
      TypeRegistry.instance.register(provider);

  /// Constructs a type from a type id
  static Type fromId(String id) => TypeRegistry.instance.fromId(id);
}

/// A TypeProvider is used to handle types without needing to manually add their factory functions
abstract class TypeProvider {
  /// Get a type factory from a type id
  Function? getFactoryById(String id);

  /// Get a list of type factories from a type name
  List<Function> getFactoriesByName(String name);

  /// Get the id of a type
  String? idOf(Type type);
}

// Extension to call any function with generic type arguments
extension FunctionPlus on Function {
  dynamic callWith({
    List<dynamic>? parameters,
    List<Type>? typeArguments,
  }) {
    return TypeSwitcher.apply(this, parameters ?? [],
        typeArguments?.map((t) => ResolvedType.from(t)).toList() ?? []);
  }
}
