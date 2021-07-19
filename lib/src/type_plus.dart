import 'resolved_type.dart';
import 'types_builder.dart';

extension TypePlus on Type {
  ResolvedType? get _resolved => ResolvedType.from(this);

  Type get base => _resolved?.base ?? this;
  List<Type> get args => _resolved?.argsAsTypes ?? [];

  T call<T>(T Function<U>() fn) => _resolved?.call(fn) ?? fn();

  static void add(Function factory) => typesMap.add(factory);
  static void addAll(List<Function> factories) =>
      factories.forEach(typesMap.add);
}

extension ImplementsType on dynamic {
  bool implements(Type t) {
    return t._resolved?.call(<T>() => this is T) ?? false;
  }
}

Type typeOf<T>() => T;
