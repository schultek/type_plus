export 'src/type_plus.dart';
export 'src/unresolved_type.dart';

/// Helper function to get a type variable from a generic type argument
@Deprecated(
    'Outdated since Dart 2.15, use type literals or update your Dart SDK')
Type typeOf<T>() => T;
