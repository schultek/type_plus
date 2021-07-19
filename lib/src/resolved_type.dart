import 'type_info.dart';
import 'type_plus.dart';
import 'types_builder.dart';
import 'utils.dart';

class TypeMatch {
  Set<Function> bases;
  List<TypeMatch> args;

  TypeMatch.fromInfo(TypeInfo info)
      : bases = typesMap[info.type] ?? {},
        args = info.args.map((i) => TypeMatch.fromInfo(i)).toList();
}

class TypeOption {
  Function base;
  List<TypeOption> args;

  TypeOption(this.base, this.args);
}

class ResolvedType {
  Type base;
  Function factory;
  List<ResolvedType> args;

  ResolvedType(this.factory, this.args) : base = factory(typeOf) {
    resolvedTypes[call(typeOf)] = this;
  }

  List<Type> get argsAsTypes => args.map((p) => p.base).toList();

  static ResolvedType? from<T>([Type? type]) => resolveType<T>(type);

  T call<T>(T Function<U>() fn) => genericCall<T>(fn) as T;

  dynamic genericCall<T>([dynamic value]) {
    var a = [...args];

    dynamic call(dynamic Function<T>() next) {
      var t = a.removeAt(0);
      return t.genericCall(next);
    }

    var fn = factory;
    var v = value ?? typeOf;

    if (args.isEmpty) {
      return fn(v);
    } else if (args.length == 1) {
      return call(<A>() => fn<A>(v));
    } else if (args.length == 2) {
      return call(<A>() => call(<B>() => fn<A, B>(v)));
    } else if (args.length == 3) {
      return call(<A>() => call(<B>() => call(<C>() => fn<A, B, C>(v))));
    } else if (args.length == 4) {
      return call(<A>() =>
          call(<B>() => call(<C>() => call(<D>() => fn<A, B, C, D>(v)))));
    } else if (args.length == 5) {
      return call(<A>() => call(<B>() =>
          call(<C>() => call(<D>() => call(<E>() => fn<A, B, C, D, E>(v))))));
    } else {
      throw Exception(
          'TypePlus only supports generic classes with upt to 5 type arguments.');
    }
  }

  @override
  String toString() => 'ResolvedType{base: $base, args: $args}';
}

final Map<Type, ResolvedType> resolvedTypes = {};

ResolvedType? resolveType<T>([Type? t]) {
  var type = t ?? T;

  if (resolvedTypes[type] != null) {
    return resolvedTypes[type];
  }

  var info = TypeInfo.fromType(type);
  var match = TypeMatch.fromInfo(info);

  List<TypeOption> getOptions(TypeMatch match) => [
        for (var o in match.args.map(getOptions).toList().power())
          for (var b in match.bases) TypeOption(b, o),
      ];

  ResolvedType resolveOption(TypeOption o) => ResolvedType(
        o.base,
        o.args.map(resolveOption).toList(),
      );

  var options = getOptions(match).map(resolveOption);
  return options.where((o) => o.call(typeOf) == type).firstOrNull;
}
