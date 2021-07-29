import 'package:type_plus/src/resolved_type.dart';
import 'package:type_plus/src/type_plus.dart';

import 'type_info.dart';

final typeRegistry = TypeRegistry.from([
  (f) => f<dynamic>(),
  (f) => f<bool>(),
  (f) => f<int>(),
  (f) => f<double>(),
  (f) => f<num>(),
  (f) => f<String>(),
  <T>(f) => f<List<T>>(),
  <T>(f) => f<Iterable<T>>(),
  <T>(f) => f<Set<T>>(),
  <K, V>(f) => f<Map<K, V>>(),
  (f) => f<DateTime>(),
  (f) => f<Type>(),
  (f) => f<Runes>(),
  (f) => f<Symbol>(),
  (f) => f<Object>(),
  (f) => f<Null>(),
  (f) => f<void>(),
]);

class TypeRegistry {
  final Map<String, Set<String>> _nameToId = {};
  final Map<String, Function> _idToFactory = {};
  final Map<int, String> _hashToId = {};

  final Set<TypeProvider> typeProviders = {};

  TypeRegistry._();

  factory TypeRegistry.from(List<Function> factories) {
    var registry = TypeRegistry._();
    factories.forEach(registry.add);
    return registry;
  }

  void add(Function factory, {String? id}) {
    Type type = factory(typeOf);
    var typeId = id ?? '${type.hashCode}';
    _idToFactory[typeId] = factory;
    (_nameToId[type.name] ??= {}).add(typeId);
    _hashToId[type.hashCode] = typeId;
  }

  List<Function> getFactoriesByName(String name) {
    return (_nameToId[name] ?? {})
        .map((h) => _idToFactory[h]!)
        .followedBy(typeProviders.expand((p) => p.getFactoriesByName(name)))
        .toList();
  }

  void register(TypeProvider provider) {
    typeProviders.add(provider);
  }

  String? idOf(Type type) {
    return _hashToId[type.hashCode] ??
        typeProviders.fold(null, (id, p) => id ?? p.idOf(type));
  }

  Type fromId(String id) {
    var info = TypeInfo.fromString(id);

    ResolvedType resolve(TypeInfo info) {
      var factory = _idToFactory[info.type] ??
          typeProviders.fold(null, (f, p) => f ?? p.getFactoryById(info.type));
      return factory != null
          ? ResolvedType(factory, info.args.map(resolve).toList(),
              isNullable: info.isNullable)
          : ResolvedType.unresolved(info);
    }

    return resolve(info).call(value: typeOf);
  }
}
