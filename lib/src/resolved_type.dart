import 'type_info.dart';
import 'type_plus.dart';
import 'type_switcher.dart';
import 'types_registry.dart';
import 'unresolved_type.dart';
import 'utils.dart';

class TypeMatch {
  List<Function> bases;
  List<TypeMatch> args;
  bool isNullable;

  TypeMatch.fromInfo(TypeInfo info)
      : bases = TypeRegistry.instance.getFactoriesByName(info.type),
        args = info.args.map((i) => TypeMatch.fromInfo(i)).toList(),
        isNullable = info.isNullable;
}

class TypeOption {
  Function base;
  List<TypeOption> args;
  bool isNullable;

  TypeOption(this.base, this.args, {this.isNullable = false});
}

class ResolvedType {
  Type base;
  Function factory;
  List<ResolvedType> args;
  bool isNullable;

  static final Map<Type, ResolvedType> _resolvedTypes = {};
  static final Map<ResolvedType, Type> _reverseTypes = {};

  ResolvedType(this.factory, this.args, {this.isNullable = false})
      : base = factory(typeOf) {
    var reverseType = reverse();
    _resolvedTypes[reverseType] = this;
    _reverseTypes[this] = reverseType;
  }

  factory ResolvedType.unresolved(TypeInfo info) {
    return ResolvedType(
      UnresolvedType.factory(info.args.length),
      info.args.map((i) => ResolvedType.unresolved(i)).toList(),
    );
  }

  Function get nullAwareTypeOf => isNullable ? <T>() => typeOf<T?>() : typeOf;

  Type reverse() {
    return _reverseTypes[this] ??
        TypeSwitcher.apply(factory, [nullAwareTypeOf], args);
  }

  List<Type> get argsAsTypes => args.map((p) => p.base).toList();

  String get id {
    var nullSuffix = isNullable ? '?' : '';
    if (args.isNotEmpty && args.any((t) => t.reverse() != dynamic)) {
      return '${base.id}<${args.map((r) => r.id).join(',')}>$nullSuffix';
    } else {
      return (TypeRegistry.instance.idOf(base) ?? '') + nullSuffix;
    }
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

    ResolvedType resolveOption(TypeOption o) => ResolvedType(
          o.base,
          o.args.map(resolveOption).toList(),
          isNullable: o.isNullable,
        );

    var options = getOptions(match).map(resolveOption);
    var resolved = options.where((o) => o.reverse() == type).firstOrNull;
    return resolved ?? ResolvedType.unresolved(info);
  }

  @override
  String toString() => 'ResolvedType{base: $base, args: $args}';

  bool implements(Type t) {
    if (t == dynamic) return true;
    if (t == base) return true;

    var superFn = TypeRegistry.instance.getSuperFactories(base.id);

    for (var fn in superFn) {
      var st = TypeSwitcher.apply(fn, [typeOf], args) as Type;

      if (st == t || st.implements(t)) {
        return true;
      }
    }
    return false;
  }
}
