import 'package:type_plus/src/type_plus.dart';

import 'type_info.dart';

final typesMap = TypesBuilder.from([
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

final Set<TypeProvider> typeProviders = {};

Set<Function> getTypeFactories(String id) {
  return typesMap[id] ??
      typeProviders.fold<Set<Function>?>(
          null, (t, p) => t ?? p.getFactories(id)) ??
      {};
}

extension TypesBuilder on Map<String, Set<Function>> {
  static Map<String, Set<Function>> from(List<Function> list) {
    var map = <String, Set<Function>>{};
    list.forEach(map.add);
    return map;
  }

  void add(Function factory) {
    var id = factory(TypeInfo.id);
    (this[id] ??= {}).add(factory);
  }
}
