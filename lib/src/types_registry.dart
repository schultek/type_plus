import 'dart:async';

import 'resolved_type.dart';
import 'type_info.dart';
import 'type_plus.dart';
import 'unresolved_type.dart';
import 'utils.dart';

Function ff<T>() => (f) => f<T>();
MapEntry<String, Iterable<Function>?> fd(String id, [Iterable<Function>? st]) => MapEntry(id, st);
final ffObj = ff<Object>();

final _sdkTypes = <(Function, String, Iterable<Function>?)>{
  ((f) => f<dynamic>(), 'dynamic', null),
  ((f) => f<void>(), 'void', null),
  ((f) => f<Null>(), 'Null', null),
  ((f) => f<Object>(), 'Object', null),
  ((f) => f<bool>(), 'bool', {ffObj}),
  (<T>(f) => f<Comparable<T>>(), 'Comparable', {ffObj}),
  ((f) => f<num>(), 'num', {ff<Comparable<num>>()}),
  ((f) => f<int>(), 'int', {ff<num>()}),
  ((f) => f<double>(), 'double', {ff<num>()}),
  ((f) => f<Pattern>(), 'Pattern', {ffObj}),
  ((f) => f<String>(), 'String', {ff<Comparable<String>>(), ff<Pattern>()}),
  (<T>(f) => f<Iterable<T>>(), 'Iterable', {ffObj}),
  (<T>(f) => f<List<T>>(), 'List', {<T>(f) => f<Iterable<T>>()}),
  (<T>(f) => f<Set<T>>(), 'Set', {<T>(f) => f<Iterable<T>>()}),
  (<K, V>(f) => f<Map<K, V>>(), 'Map', {ffObj}),
  ((f) => f<DateTime>(), 'DateTime', {ff<Comparable<DateTime>>()}),
  ((f) => f<Type>(), 'Type', {ffObj}),
  ((f) => f<Runes>(), 'Runes', {ff<Iterable<int>>()}),
  ((f) => f<Symbol>(), 'Symbol', {ffObj}),
  (<T>(f) => f<Future<T>>(), 'Future', {ffObj}),
  (<T>(f) => f<Stream<T>>(), 'Stream', {ffObj}),
};

class TypeRegistry {
  final Map<Type, String> _typeToId = {};
  final Map<String, Set<String>> _nameToId = {};
  final Map<String, Function> _idToFactory = {};
  final Map<String, Set<Function>> _idToSuperFactory = {};

  final Set<TypeProvider> typeProviders = {};

  static TypeRegistry? _instance;
  static TypeRegistry get instance {
    if (_instance == null) {
      _instance = TypeRegistry._();
      for (var (fn, id, sup) in _sdkTypes) {
        _instance!.add(fn, id: id, superTypes: sup);
      }
    }
    return _instance!;
  }

  TypeRegistry._();

  void add(Function factory, {String? id, Iterable<Function>? superTypes}) {
    Type type = factory(typeOf);

    if (id != null) {
      if (_idToFactory.containsKey(id)) {
        Type existingType = _idToFactory[id]!(typeOf);
        if (existingType != type) {
          throw UnsupportedError('Types must have a unique id. You tried to add type $type with id "$id", '
              'but this was already used for type $existingType.');
        }
      }
    }

    var typeId = id ?? _typeToId[type];

    if (typeId == null) {
      typeId = '${type.hashCode}';
      while (_idToFactory.containsKey(typeId)) {
        typeId = '${typeId}_';
      }
    }

    _idToFactory[typeId!] = factory;
    (_nameToId[type.name] ??= {}).add(typeId);
    _typeToId[type] = typeId;
    _idToSuperFactory[typeId] = superTypes?.toSet() ?? {ffObj};

    if (type.base == UnresolvedType) {
      throw ArgumentError('Failed to add type $type. This may happen when you did register '
          'a used bound on a type parameter. Register all needed bounds before this type.');
    }
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
    return _typeToId[type] ?? typeProviders.fold(null, (id, p) => id ?? p.idOf(type));
  }

  Type fromId(String id) {
    var info = TypeInfo.fromString(id);

    ResolvedType resolve(TypeInfo info) {
      var factory = _idToFactory[info.type] ?? typeProviders.fold(null, (f, p) => f ?? p.getFactoryById(info.type));
      return factory != null
          ? ResolvedType(factory, info.args.map(resolve).toList(), isNullable: info.isNullable)
          : ResolvedType.unresolved(info);
    }

    return resolve(info).reversed;
  }

  Set<Function> getSuperFactories(String id) {
    return _idToSuperFactory[id] ?? {};
  }
}
