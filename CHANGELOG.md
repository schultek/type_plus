# 2.1.1

- Fixed bug with generic type ids containing `dynamic`.

# 2.1.0

- Ignore whitespaces in type ids.
- Added support for up to 10 type arguments.

# 2.0.1

- Fixed bug when registering types with conflicting hashCodes.

# 2.0.0

- Increase min sdk version to `3.0.0`
- Added support for records

# 1.1.0

- Increase min sdk version to `2.15.0`
- Performance improvements

# 1.0.0

- Stable release

# 0.8.0

- Added `nonNull` type getter

# 0.7.0

- Fixed bug with bounded types

# 0.6.3

- Fixed type arg resolving

# 0.6.2

- Made name resolution independent from type resolution

# 0.6.1

- Fixed id resolution

# 0.6.0

- All standard types have named ids by default
- Added tests

# 0.5.1

- Added Future and Stream to default types

# 0.5.0

- Added provideTo method
- Improved performance for function invocations

# 0.4.0

- Update readme and example to Dart 2.15
- Deprecate typeOf helper function

# 0.3.3

- TypeProviders can now safely override primitive types
- Fixed bug when using type bounds by adding Type.baseId getter

# 0.3.2

- Fixed reverse nullable type bug

# 0.3.1

- Updated readme

# 0.3.0

- Added generic function invocation
- Added support for supertype checking
- Reworked type parsing

# 0.2.0

- Added support for custom ids and type parsing
- Improved documentation

# 0.1.1

- Added support for type providers and unresolved type

# 0.1.0

- Initial development release
