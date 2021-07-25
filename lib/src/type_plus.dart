import 'resolved_type.dart';
import 'type_info.dart';
import 'types_builder.dart';

extension TypePlus on Type {
  ResolvedType get _resolved => ResolvedType.from(this);

  Type get base => _resolved.base;
  List<Type> get args => _resolved.argsAsTypes;

  String get id => TypeInfo.id(this);

  T call<T>(T Function<U>() fn) => _resolved.call(fn);

  static void add<T>() => typesMap.add((f) => f<T>());
  static void addFactory(Function factory) => typesMap.add(factory);
  static void addFactories(List<Function> factories) =>
      factories.forEach(typesMap.add);

  static void register(TypeProvider provider) => typeProviders.add(provider);
}

Type typeOf<T>() => T;

abstract class TypeProvider {
  Set<Function>? getFactories(String id);
}
