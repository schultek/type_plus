import 'resolved_type.dart';
import 'type_info.dart';

class TypeSwitcher {
  static dynamic apply(Function fn, List<dynamic> params, List<ResolvedType> args) {
    assert(() {
      var fi = FunctionInfo.from(fn);

      if (fi.args.length != args.length) {
        throw ArgumentError(
            'Function expects different amount of type arguments. Provided ${args.length}, but expected ${fi.args.length}.');
      } else if (args.length > 10) {
        throw ArgumentError('TypePlus only supports generic functions with up to 10 type arguments.');
      }

      if (fi.namedParams.isNotEmpty) {
        throw ArgumentError("Function $fn cannot have named parameters.");
      } else if (params.length < fi.params.length) {
        throw ArgumentError("Function $fn must be called with at least ${fi.params.length} parameters.");
      } else if (params.length > fi.params.length + fi.optionalParams.length) {
        throw ArgumentError(
            "Function $fn must be called with at most ${fi.params.length + fi.optionalParams.length} parameters.");
      } else if (params.length > 10) {
        throw ArgumentError('TypePlus only supports generic functions with up to 10 parameters.');
      }

      return true;
    }());

    dynamic $args({
      Function()? $0,
      Function<A>()? $1,
      Function<A, B>()? $2,
      Function<A, B, C>()? $3,
      Function<A, B, C, E>()? $4,
      Function<A, B, C, E, D>()? $5,
      Function<A, B, C, E, D, F>()? $6,
      Function<A, B, C, E, D, F, G>()? $7,
      Function<A, B, C, E, D, F, G, H>()? $8,
      Function<A, B, C, E, D, F, G, H, I>()? $9,
      Function<A, B, C, E, D, F, G, H, I, J>()? $10,
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

      return switch (args.length) {
        0 => $0?.call(),
        1 => call(<A>() => $1?.call<A>()),
        2 => call(<A>() => call(<B>() => $2?.call<A, B>())),
        3 => call(<A>() => call(<B>() => call(<C>() => $3?.call<A, B, C>()))),
        4 => call(<A>() => call(<B>() => call(<C>() => call(<D>() => $4?.call<A, B, C, D>())))),
        5 => call(<A>() => call(<B>() => call(<C>() => call(<D>() => call(<E>() => $5?.call<A, B, C, D, E>()))))),
        6 => call(<A>() =>
            call(<B>() => call(<C>() => call(<D>() => call(<E>() => call(<F>() => $6?.call<A, B, C, D, E, F>())))))),
        7 => call(<A>() => call(<B>() => call(
            <C>() => call(<D>() => call(<E>() => call(<F>() => call(<G>() => $7?.call<A, B, C, D, E, F, G>()))))))),
        8 => call(<A>() => call(<B>() => call(<C>() => call(
            <D>() => call(<E>() => call(<F>() => call(<G>() => call(<H>() => $8?.call<A, B, C, D, E, F, G, H>())))))))),
        9 => call(<A>() => call(<B>() => call(<C>() => call(<D>() => call(<E>() =>
            call(<F>() => call(<G>() => call(<H>() => call(<I>() => $9?.call<A, B, C, D, E, F, G, H, I>()))))))))),
        10 => call(<A>() => call(<B>() => call(<C>() => call(<D>() => call(<E>() => call(<F>() =>
            call(<G>() => call(<H>() => call(<I>() => call(<J>() => $10?.call<A, B, C, D, E, F, G, H, I, J>())))))))))),
        _ => throw ArgumentError('TypePlus only supports generic functions with up to 10 type arguments.'),
      };
    }

    dynamic $params({
      Function()? $0,
      Function(dynamic)? $1,
      Function(dynamic, dynamic)? $2,
      Function(dynamic, dynamic, dynamic)? $3,
      Function(dynamic, dynamic, dynamic, dynamic)? $4,
      Function(dynamic, dynamic, dynamic, dynamic, dynamic)? $5,
      Function(dynamic, dynamic, dynamic, dynamic, dynamic, dynamic)? $6,
      Function(dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic)? $7,
      Function(dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic)? $8,
      Function(dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic)? $9,
      Function(dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic)? $10,
    }) {
      return switch (params) {
        [] => $0?.call(),
        [var a] => $1?.call(a),
        [var a, var b] => $2?.call(a, b),
        [var a, var b, var c] => $3?.call(a, b, c),
        [var a, var b, var c, var d] => $4?.call(a, b, c, d),
        [var a, var b, var c, var d, var e] => $5?.call(a, b, c, d, e),
        [var a, var b, var c, var d, var e, var f] => $6?.call(a, b, c, d, e, f),
        [var a, var b, var c, var d, var e, var f, var g] => $7?.call(a, b, c, d, e, f, g),
        [var a, var b, var c, var d, var e, var f, var g, var h] => $8?.call(a, b, c, d, e, f, g, h),
        [var a, var b, var c, var d, var e, var f, var g, var h, var i] => $9?.call(a, b, c, d, e, f, g, h, i),
        [var a, var b, var c, var d, var e, var f, var g, var h, var i, var j] =>
          $10?.call(a, b, c, d, e, f, g, h, i, j),
        _ => throw ArgumentError('TypePlus only supports generic functions with up to 10 parameters.'),
      };
    }

    return $args(
      $0: () => $params(
        $0: () => fn(),
        $1: (a) => fn(a),
        $2: (a, b) => fn(a, b),
        $3: (a, b, c) => fn(a, b, c),
        $4: (a, b, c, d) => fn(a, b, c, d),
        $5: (a, b, c, d, e) => fn(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn(a, b, c, d, e, f, g, h, i, j),
      ),
      $1: <A>() => $params(
        $0: () => fn<A>(),
        $1: (a) => fn<A>(a),
        $2: (a, b) => fn<A>(a, b),
        $3: (a, b, c) => fn<A>(a, b, c),
        $4: (a, b, c, d) => fn<A>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A>(a, b, c, d, e, f, g, h, i, j),
      ),
      $2: <A, B>() => $params(
        $0: () => fn<A, B>(),
        $1: (a) => fn<A, B>(a),
        $2: (a, b) => fn<A, B>(a, b),
        $3: (a, b, c) => fn<A, B>(a, b, c),
        $4: (a, b, c, d) => fn<A, B>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A, B>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A, B>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A, B>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A, B>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A, B>(a, b, c, d, e, f, g, h, i, j),
      ),
      $3: <A, B, C>() => $params(
        $0: () => fn<A, B, C>(),
        $1: (a) => fn<A, B, C>(a),
        $2: (a, b) => fn<A, B, C>(a, b),
        $3: (a, b, c) => fn<A, B, C>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A, B, C>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A, B, C>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A, B, C>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A, B, C>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A, B, C>(a, b, c, d, e, f, g, h, i, j),
      ),
      $4: <A, B, C, D>() => $params(
        $0: () => fn<A, B, C, D>(),
        $1: (a) => fn<A, B, C, D>(a),
        $2: (a, b) => fn<A, B, C, D>(a, b),
        $3: (a, b, c) => fn<A, B, C, D>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C, D>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C, D>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A, B, C, D>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A, B, C, D>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A, B, C, D>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A, B, C, D>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A, B, C, D>(a, b, c, d, e, f, g, h, i, j),
      ),
      $5: <A, B, C, D, E>() => $params(
        $0: () => fn<A, B, C, D, E>(),
        $1: (a) => fn<A, B, C, D, E>(a),
        $2: (a, b) => fn<A, B, C, D, E>(a, b),
        $3: (a, b, c) => fn<A, B, C, D, E>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C, D, E>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C, D, E>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A, B, C, D, E>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A, B, C, D, E>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A, B, C, D, E>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A, B, C, D, E>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A, B, C, D, E>(a, b, c, d, e, f, g, h, i, j),
      ),
      $6: <A, B, C, D, E, F>() => $params(
        $0: () => fn<A, B, C, D, E, F>(),
        $1: (a) => fn<A, B, C, D, E, F>(a),
        $2: (a, b) => fn<A, B, C, D, E, F>(a, b),
        $3: (a, b, c) => fn<A, B, C, D, E, F>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C, D, E, F>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C, D, E, F>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A, B, C, D, E, F>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A, B, C, D, E, F>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A, B, C, D, E, F>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A, B, C, D, E, F>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A, B, C, D, E, F>(a, b, c, d, e, f, g, h, i, j),
      ),
      $7: <A, B, C, D, E, F, G>() => $params(
        $0: () => fn<A, B, C, D, E, F, G>(),
        $1: (a) => fn<A, B, C, D, E, F, G>(a),
        $2: (a, b) => fn<A, B, C, D, E, F, G>(a, b),
        $3: (a, b, c) => fn<A, B, C, D, E, F, G>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C, D, E, F, G>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C, D, E, F, G>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A, B, C, D, E, F, G>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A, B, C, D, E, F, G>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A, B, C, D, E, F, G>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A, B, C, D, E, F, G>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A, B, C, D, E, F, G>(a, b, c, d, e, f, g, h, i, j),
      ),
      $8: <A, B, C, D, E, F, G, H>() => $params(
        $0: () => fn<A, B, C, D, E, F, G, H>(),
        $1: (a) => fn<A, B, C, D, E, F, G, H>(a),
        $2: (a, b) => fn<A, B, C, D, E, F, G, H>(a, b),
        $3: (a, b, c) => fn<A, B, C, D, E, F, G, H>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C, D, E, F, G, H>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C, D, E, F, G, H>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A, B, C, D, E, F, G, H>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A, B, C, D, E, F, G, H>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A, B, C, D, E, F, G, H>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A, B, C, D, E, F, G, H>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A, B, C, D, E, F, G, H>(a, b, c, d, e, f, g, h, i, j),
      ),
      $9: <A, B, C, D, E, F, G, H, I>() => $params(
        $0: () => fn<A, B, C, D, E, F, G, H, I>(),
        $1: (a) => fn<A, B, C, D, E, F, G, H, I>(a),
        $2: (a, b) => fn<A, B, C, D, E, F, G, H, I>(a, b),
        $3: (a, b, c) => fn<A, B, C, D, E, F, G, H, I>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C, D, E, F, G, H, I>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C, D, E, F, G, H, I>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A, B, C, D, E, F, G, H, I>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A, B, C, D, E, F, G, H, I>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A, B, C, D, E, F, G, H, I>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A, B, C, D, E, F, G, H, I>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A, B, C, D, E, F, G, H, I>(a, b, c, d, e, f, g, h, i, j),
      ),
      $10: <A, B, C, D, E, F, G, H, I, J>() => $params(
        $0: () => fn<A, B, C, D, E, F, G, H, I, J>(),
        $1: (a) => fn<A, B, C, D, E, F, G, H, I, J>(a),
        $2: (a, b) => fn<A, B, C, D, E, F, G, H, I, J>(a, b),
        $3: (a, b, c) => fn<A, B, C, D, E, F, G, H, I, J>(a, b, c),
        $4: (a, b, c, d) => fn<A, B, C, D, E, F, G, H, I, J>(a, b, c, d),
        $5: (a, b, c, d, e) => fn<A, B, C, D, E, F, G, H, I, J>(a, b, c, d, e),
        $6: (a, b, c, d, e, f) => fn<A, B, C, D, E, F, G, H, I, J>(a, b, c, d, e, f),
        $7: (a, b, c, d, e, f, g) => fn<A, B, C, D, E, F, G, H, I, J>(a, b, c, d, e, f, g),
        $8: (a, b, c, d, e, f, g, h) => fn<A, B, C, D, E, F, G, H, I, J>(a, b, c, d, e, f, g, h),
        $9: (a, b, c, d, e, f, g, h, i) => fn<A, B, C, D, E, F, G, H, I, J>(a, b, c, d, e, f, g, h, i),
        $10: (a, b, c, d, e, f, g, h, i, j) => fn<A, B, C, D, E, F, G, H, I, J>(a, b, c, d, e, f, g, h, i, j),
      ),
    );
  }
}
