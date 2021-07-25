import 'type_info.dart';
import 'type_plus.dart';
import 'types_builder.dart';
import 'unresolved_type.dart';
import 'utils.dart';

class TypeMatch {
  Set<Function> bases;
  List<TypeMatch> args;

  TypeMatch.fromInfo(TypeInfo info)
      : bases = getTypeFactories(info.type),
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
    resolvedTypes[call(value: typeOf)] = this;
  }

  factory ResolvedType.unresolved(TypeInfo info) {
    return ResolvedType(
      UnresolvedType.factory(info.args.length),
      info.args.map((i) => ResolvedType.unresolved(i)).toList(),
    );
  }

  List<Type> get argsAsTypes => args.map((p) => p.base).toList();

  static ResolvedType from<T>([Type? type]) => resolveType<T>(type);

  dynamic call({Function? fn, dynamic value}) {
    return genericCall(value: value, fn: fn);
  }

  dynamic genericCall({dynamic value, Function? fn}) {
    var a = [...args];

    dynamic call(Function next) {
      var t = a.removeAt(0);
      return t.genericCall(value: next);
    }

    var f = fn ?? factory;
    var v = value;
    var nn = v != null;

    if (args.isEmpty) {
      return nn ? f(v) : f();
    } else if (args.length == 1) {
      return call(<A>() => nn ? f<A>(v) : f<A>());
    } else if (args.length == 2) {
      return call(<A>() => call(<B>() => nn ? f<A, B>(v) : f<A, B>()));
    } else if (args.length == 3) {
      return call(<A>() =>
          call(<B>() => call(<C>() => nn ? f<A, B, C>(v) : f<A, B, C>())));
    } else if (args.length == 4) {
      return call(<A>() => call(<B>() => call(
          <C>() => call(<D>() => nn ? f<A, B, C, D>(v) : f<A, B, C, D>()))));
    } else if (args.length == 5) {
      return call(<A>() => call(<B>() => call(<C>() => call(<D>() =>
          call(<E>() => nn ? f<A, B, C, D, E>(v) : f<A, B, C, D, E>())))));
    } else {
      throw Exception(
          'TypePlus only supports generic classes with up to 5 type arguments.');
    }
  }

  @override
  String toString() => 'ResolvedType{base: $base, args: $args}';
}

final Map<Type, ResolvedType> resolvedTypes = {};

ResolvedType resolveType<T>([Type? t]) {
  var type = t ?? T;

  if (resolvedTypes[type] != null) {
    return resolvedTypes[type]!;
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
  var resolved =
      options.where((o) => o.call(value: typeOf) == type).firstOrNull;

  if (resolved != null) {
    resolvedTypes[type] = resolved;
  }
  return resolved ?? ResolvedType.unresolved(info);
}
