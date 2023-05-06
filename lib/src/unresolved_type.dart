/// Represents a type that cannot be resolved.
/// Most likely when the type wasn't previously added with [TypePlus.add()]
class UnresolvedType {
  static Function factory(int length) {
    return switch (length) {
      0 => (f) => f<UnresolvedType>(),
      1 => <A>(f) => f<UnresolvedType>(),
      2 => <A, B>(f) => f<UnresolvedType>(),
      3 => <A, B, C>(f) => f<UnresolvedType>(),
      4 => <A, B, C, D>(f) => f<UnresolvedType>(),
      5 => <A, B, C, D, E>(f) => f<UnresolvedType>(),
      _ => throw Exception('TypePlus only supports generic classes with up to 5 type arguments.'),
    };
  }
}
