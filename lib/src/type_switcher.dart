import 'resolved_type.dart';
import 'type_info.dart';

class TypeSwitcher {
  static dynamic apply(
      Function fn, List<dynamic> params, List<ResolvedType> args) {
    var fi = FunctionInfo.from(fn);

    dynamic $args({
      Function()? $0,
      Function<A>()? $1,
      Function<A, B>()? $2,
      Function<A, B, C>()? $3,
      Function<A, B, C, E>()? $4,
      Function<A, B, C, E, D>()? $5,
    }) {
      var a = [...args];
      dynamic call(Function next) {
        if (a.isEmpty)
          return next();
        else {
          var arg = a.removeAt(0);
          return TypeSwitcher.apply(
            arg.factory,
            [if (arg.isNullable) <T>() => next<T?>() else next],
            arg.args,
          );
        }
      }

      switch (fi.args.length) {
        case 0:
          return $0?.call();
        case 1:
          return call(<A>() => $1?.call<A>());
        case 2:
          return call(<A>() => call(<B>() => $2?.call<A, B>()));
        case 3:
          return call(
              <A>() => call(<B>() => call(<C>() => $3?.call<A, B, C>())));
        case 4:
          return call(<A>() => call(
              <B>() => call(<C>() => call(<D>() => $4?.call<A, B, C, D>()))));
        case 5:
          return call(<A>() => call(<B>() => call(<C>() =>
              call(<D>() => call(<E>() => $5?.call<A, B, C, D, E>())))));
        default:
          throw ArgumentError(
              'TypePlus only supports generic functions with up to 5 type arguments.');
      }
    }

    dynamic $params({
      Function()? $0,
      Function(dynamic)? $1,
      Function(dynamic, dynamic)? $2,
      Function(dynamic, dynamic, dynamic)? $3,
      Function(dynamic, dynamic, dynamic, dynamic)? $4,
      Function(dynamic, dynamic, dynamic, dynamic, dynamic)? $5,
    }) {
      if (fi.namedParams.isNotEmpty) {
        throw ArgumentError("Function $fn cannot have named parameters.");
      } else if (params.length < fi.params.length) {
        throw ArgumentError(
            "Function $fn must be called with at least ${fi.params.length} parameters.");
      } else if (params.length > fi.params.length + fi.optionalParams.length) {
        throw ArgumentError(
            "Function $fn must be called with at most ${fi.params.length + fi.optionalParams.length} parameters.");
      }

      switch (params.length) {
        case 0:
          return $0?.call();
        case 1:
          return $1?.call(params[0]);
        case 2:
          return $2?.call(params[0], params[1]);
        case 3:
          return $3?.call(params[0], params[1], params[2]);
        case 4:
          return $4?.call(params[0], params[1], params[2], params[3]);
        case 5:
          return $5?.call(
              params[0], params[1], params[2], params[3], params[4]);
        default:
          throw ArgumentError(
              'TypePlus only supports generic functions with up to 5 parameters.');
      }
    }

    return $args(
      $0: () => $params(
        $0: () => fn(),
        $1: (a) => fn(a),
        $2: (a, b) => fn(a, b),
        $3: (a, b, c) => fn(a, b, c),
        $4: (a, b, c, d) => fn(a, b, c, d),
        $5: (a, b, c, d, e) => fn(a, b, c, d, e),
      ),
      $1: <A>() => $params(
        $0: () => fn<A>(),
        $1: (a) => fn<A>(a),
        $2: (a, b) => fn<A>(a, b),
        $3: (a, b, c) => fn<A>(a, b, c),
        $4: (a, b, c, d) => fn<A>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A>(a, b, c, d, e),
      ),
      $2: <A, B>() => $params(
        $0: () => fn<A, B>(),
        $1: (a) => fn<A, B>(a),
        $2: (a, b) => fn<A, B>(a, b),
        $3: (a, b, c) => fn<A, B>(a, b, c),
        $4: (a, b, c, d) => fn<A, B>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B>(a, b, c, d, e),
      ),
      $3: <A, B, C>() => $params(
        $0: () => fn<A, B, C>(),
        $1: (a) => fn<A, B, C>(a),
        $2: (a, b) => fn<A, B, C>(a, b),
        $3: (a, b, c) => fn<A, B, C>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C>(a, b, c, d, e),
      ),
      $4: <A, B, C, D>() => $params(
        $0: () => fn<A, B, C, D>(),
        $1: (a) => fn<A, B, C, D>(a),
        $2: (a, b) => fn<A, B, C, D>(a, b),
        $3: (a, b, c) => fn<A, B, C, D>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C, D>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C, D>(a, b, c, d, e),
      ),
      $5: <A, B, C, D, E>() => $params(
        $0: () => fn<A, B, C, D, E>(),
        $1: (a) => fn<A, B, C, D, E>(a),
        $2: (a, b) => fn<A, B, C, D, E>(a, b),
        $3: (a, b, c) => fn<A, B, C, D, E>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C, D, E>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C, D, E>(a, b, c, d, e),
      ),
    );
  }
}
