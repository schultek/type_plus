/// Represents a type that cannot be resolved.
///
/// Most likely when the type wasn't previously added with [TypePlus.add()].
class UnresolvedType {
  static Function factory(int length) {
    return switch (length) {
      0 => (f) => f<UnresolvedType>(),
      1 => <A>(f) => f<UnresolvedType>(),
      2 => <A, B>(f) => f<UnresolvedType>(),
      3 => <A, B, C>(f) => f<UnresolvedType>(),
      4 => <A, B, C, D>(f) => f<UnresolvedType>(),
      5 => <A, B, C, D, E>(f) => f<UnresolvedType>(),
      6 => <A, B, C, D, E, F>(f) => f<UnresolvedType>(),
      7 => <A, B, C, D, E, F, G>(f) => f<UnresolvedType>(),
      8 => <A, B, C, D, E, F, G, H>(f) => f<UnresolvedType>(),
      9 => <A, B, C, D, E, F, G, H, I>(f) => f<UnresolvedType>(),
      10 => <A, B, C, D, E, F, G, H, I, J>(f) => f<UnresolvedType>(),
      _ => throw Exception('TypePlus only supports generic classes with up to 10 type arguments.'),
    };
  }
}
