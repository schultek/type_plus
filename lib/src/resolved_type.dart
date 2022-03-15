import 'type_info.dart';
import 'type_plus.dart';
import 'type_switcher.dart';
import 'types_registry.dart';
import 'unresolved_type.dart';
import 'utils.dart';

class TypeMatch {
  final List<Function> bases;
  final List<TypeMatch> args;
  final bool isNullable;

  TypeMatch.fromInfo(TypeInfo info)
      : bases = TypeRegistry.instance.getFactoriesByName(info.type),
        args = info.args.map((i) => TypeMatch.fromInfo(i)).toList(),
        isNullable = info.isNullable;
}

class TypeOption {
  final Function base;
  final List<TypeOption> args;
  final bool isNullable;

  TypeOption(this.base, this.args, {this.isNullable = false});
}

class ResolvedType {
  final Type base;
  final Function factory;
  final List<ResolvedType> args;
  final bool isNullable;

  static final Map<Type, ResolvedType> _resolvedTypes = {};

  late final Function _resolvedFactory;
  late final Type _reverseType;

  ResolvedType(this.factory, this.args, {this.isNullable = false})
      : base = factory(typeOf) {
    _resolvedFactory = TypeSwitcher.apply(factory,
        [isNullable ? <T>() => (f) => f<T?>() : <T>() => (f) => f<T>()], args);
    _reverseType = _resolvedFactory(typeOf);
    _resolvedTypes[_reverseType] = this;
  }

  factory ResolvedType.unresolved(TypeInfo info) {
    return ResolvedType(
      UnresolvedType.factory(info.args.length),
      info.args.map((i) => ResolvedType.unresolved(i)).toList(),
    );
  }

  R provideTo<R>(R Function<U>() fn) {
    return _resolvedFactory(fn);
  }

  Type get reversed => _reverseType;

  List<Type> get argsAsTypes => args.map((p) => p.reversed).toList();

  String get id {
    var nullSuffix = isNullable ? '?' : '';
    if (args.isNotEmpty && args.any((t) => t.reversed != dynamic)) {
      return '${base.baseId}<${args.map((r) => r.id).join(',')}>$nullSuffix';
    } else {
      return '$baseId$nullSuffix';
    }
  }

  String get baseId {
    return TypeRegistry.instance.idOf(base) ?? '';
  }

  static ResolvedType from<T>([Type? t]) {
    var type = t ?? T;

    if (_resolvedTypes[type] != null) {
      return _resolvedTypes[type]!;
    }

    var info = TypeInfo.fromType(type);
    var match = TypeMatch.fromInfo(info);

    List<TypeOption> getOptions(TypeMatch match) => [
          for (var o in match.args.map(getOptions).toList().power())
            for (var b in match.bases)
              TypeOption(b, o, isNullable: match.isNullable),
        ];

    ResolvedType resolveOption(TypeOption o) =>
        ResolvedType(o.base, o.args.map(resolveOption).toList(),
            isNullable: o.isNullable);

    var options = getOptions(match).map(resolveOption);
    var resolved = options.where((o) => o.reversed == type).firstOrNull;
    return resolved ?? ResolvedType.unresolved(info);
  }

  @override
  String toString() => 'ResolvedType{base: $base, args: $args}';

  bool implements(Type t) {
    if (t == dynamic) return true;
    if (t == base) return true;

    var superFn = TypeRegistry.instance.getSuperFactories(baseId);

    for (var fn in superFn) {
      var st = TypeSwitcher.apply(fn, [typeOf], args) as Type;

      if (st == t || st.implements(t)) {
        return true;
      }
    }
    return false;
  }
}
