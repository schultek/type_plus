import 'resolved_type.dart';
import 'type_info.dart';
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

  /// Indicates if this type is nullable
  bool get isNullable => _resolved.isNullable;

  /// Calls a generic function with the current type as type parameter
  T call<T>(T Function<U>() fn) => _resolved.call(value: fn);

  /// Calls a generic function with the current types arguments as type parameters
  /// Can take an optional value to call the function with
  T callWithParams<T>(Function fn, {dynamic value}) =>
      _resolved.call(fn: fn, value: value);

  /// Adds a non-generic type, used as a simpler syntax to [addFactory]
  static void add<T>({String? id}) => typeRegistry.add((f) => f<T>(), id: id);

  /// Adds a type factory for any generic or non-generic type
  /// @param id: An optional unique id for this type, that will override the default id
  static void addFactory(Function factory, {String? id}) =>
      typeRegistry.add(factory, id: id);

  /// Registers a type provider to be used
  static void register(TypeProvider provider) =>
      typeRegistry.register(provider);

  /// Constructs a type from a type id
  static Type fromId(String id) => typeRegistry.fromId(id);
}

/// Helper function to get a type variable from a generic type argument
Type typeOf<T>() => T;

/// A TypeProvider is used to handle types without needing to manually add their factory functions
abstract class TypeProvider {
  /// Get a type factory from a type id
  Function? getFactoryById(String id);

  /// Get a list of type factories from a type name
  List<Function> getFactoriesByName(String name);

  /// Get the id of a type
  String? idOf(Type type);
}
