import 'dart:async';

import 'resolved_type.dart';
import 'type_info.dart';
import 'type_plus.dart';
import 'utils.dart';

Function ff<T>() => (f) => f<T>();
MapEntry<String, Iterable<Function>?> fd(String id, [Iterable<Function>? st]) =>
    MapEntry(id, st);
final ffObj = ff<Object>();

final _sdkTypes = <Function, MapEntry<String, Iterable<Function>?>>{
  (f) => f<dynamic>(): fd('dynamic'),
  (f) => f<void>(): fd('void'),
  (f) => f<Null>(): fd('Null'),
  (f) => f<Object>(): fd('Object'),
  (f) => f<bool>(): fd('bool', {ffObj}),
  <T>(f) => f<Comparable<T>>(): fd('Comparable', {ffObj}),
  (f) => f<num>(): fd('num', {ff<Comparable<num>>()}),
  (f) => f<int>(): fd('int', {ff<num>()}),
  (f) => f<double>(): fd('double', {ff<num>()}),
  (f) => f<Pattern>(): fd('Pattern', {ffObj}),
  (f) => f<String>(): fd('String', {ff<Comparable<String>>(), ff<Pattern>()}),
  <T>(f) => f<Iterable<T>>(): fd('Iterable', {ffObj}),
  <T>(f) => f<List<T>>(): fd('List', {<T>(f) => f<Iterable<T>>()}),
  <T>(f) => f<Set<T>>(): fd('Set', {<T>(f) => f<Iterable<T>>()}),
  <K, V>(f) => f<Map<K, V>>(): fd('Map', {ffObj}),
  (f) => f<DateTime>(): fd('DateTime', {ff<Comparable<DateTime>>()}),
  (f) => f<Type>(): fd('Type', {ffObj}),
  (f) => f<Runes>(): fd('Runes', {ff<Iterable<int>>()}),
  (f) => f<Symbol>(): fd('Symbol', {ffObj}),
  <T>(f) => f<Future<T>>(): fd('Future', {ffObj}),
  <T>(f) => f<Stream<T>>(): fd('Stream', {ffObj}),
};

class TypeRegistry {
  final Map<String, Set<String>> _nameToId = {};
  final Map<String, Function> _idToFactory = {};
  final Map<int, String> _hashToId = {};
  final Map<String, Set<Function>> _idToSuperFactory = {};

  final Set<TypeProvider> typeProviders = {};

  static TypeRegistry? _instance;
  static TypeRegistry get instance {
    if (_instance == null) {
      _instance = TypeRegistry._();
      _sdkTypes.forEach(
          (fn, st) => _instance!.add(fn, id: st.key, superTypes: st.value));
    }
    return _instance!;
  }

  TypeRegistry._();

  void add(Function factory, {String? id, Iterable<Function>? superTypes}) {
    Type type = factory(typeOf);
    var typeId = id ?? '${type.hashCode}';

    if (_idToFactory.containsKey(typeId)) {
      Type existingType = _idToFactory[typeId]!(typeOf);
      if (existingType != type) {
        throw UnsupportedError(
            'Types must have a unique id. You tried to add type $type with id "$typeId", '
            'but this was already used for type $existingType.');
      }
    }

    _idToFactory[typeId] = factory;
    (_nameToId[type.name] ??= {}).add(typeId);
    _hashToId[type.hashCode] = typeId;
    _idToSuperFactory[typeId] = superTypes?.toSet() ?? {ffObj};
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
          ? ResolvedType(info, factory, info.args.map(resolve).toList(),
              isNullable: info.isNullable)
          : ResolvedType.unresolved(info);
    }

    return resolve(info).reverse();
  }

  Set<Function> getSuperFactories(String id) {
    return _idToSuperFactory[id] ?? {};
  }
}
