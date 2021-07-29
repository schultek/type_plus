/// Represents a type that cannot be resolved.
/// Most likely when the type wasn't previously added with [TypePlus.add()]
class UnresolvedType {
  static Function factory(int length) {
    switch (length) {
      case 0:
        return (f) => f<UnresolvedType>();
      case 1:
        return <A>(f) => f<UnresolvedType>();
      case 2:
        return <A, B>(f) => f<UnresolvedType>();
      case 3:
        return <A, B, C>(f) => f<UnresolvedType>();
      case 4:
        return <A, B, C, D>(f) => f<UnresolvedType>();
      case 5:
        return <A, B, C, D, E>(f) => f<UnresolvedType>();
      default:
        throw Exception(
            'TypePlus only supports generic classes with up to 5 type arguments.');
    }
  }
}
