import 'resolved_type.dart';
import 'type_info.dart';
import 'type_plus.dart';

Function ff<T>() => (f) => f<T>();
var ffObj = ff<Object>();

final _sdkTypes = <Function, Iterable<Function>>{
  (f) => f<dynamic>(): {},
  (f) => f<void>(): {},
  (f) => f<Null>(): {},
  (f) => f<Object>(): {},
  (f) => f<bool>(): {ffObj},
  <T>(f) => f<Comparable<T>>(): {ffObj},
  (f) => f<num>(): {ff<Comparable<num>>()},
  (f) => f<int>(): {ff<num>()},
  (f) => f<double>(): {ff<num>()},
  (f) => f<Pattern>(): {ffObj},
  (f) => f<String>(): {ff<Comparable<String>>(), ff<Pattern>()},
  <T>(f) => f<Iterable<T>>(): {ffObj},
  <T>(f) => f<List<T>>(): {<T>(f) => f<Iterable<T>>()},
  <T>(f) => f<Set<T>>(): {<T>(f) => f<Iterable<T>>()},
  <K, V>(f) => f<Map<K, V>>(): {ffObj},
  (f) => f<DateTime>(): {ff<Comparable<DateTime>>()},
  (f) => f<Type>(): {ffObj},
  (f) => f<Runes>(): {ff<Iterable<int>>()},
  (f) => f<Symbol>(): {ffObj},
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
      _sdkTypes.forEach((fn, st) => _instance!.add(fn, superTypes: st));
    }
    return _instance!;
  }

  TypeRegistry._();

  void add(Function factory, {String? id, Iterable<Function>? superTypes}) {
    Type type = factory(typeOf);
    var typeId = id ?? '${type.hashCode}';
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
    return typeProviders.fold(null, (id, p) => id ?? p.idOf(type)) ??
        _hashToId[type.hashCode];
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

    return resolve(info).reverse();
  }

  Set<Function> getSuperFactories(String id) {
    return _idToSuperFactory[id] ?? {};
  }
}
