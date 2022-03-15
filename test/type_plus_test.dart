import 'package:test/test.dart';
import 'package:type_plus/type_plus.dart';

class A {}

class B implements A {}

class C<T> {}

void main() {
  group('basic types', () {
    test('basic types work', () {
      // id
      expect((int).id, equals('int'));
      expect(typeOf<Map<bool, List<int>>>().id, equals('Map<bool,List<int>>'));
      // name
      expect((String).name, equals('String'));
      // base
      expect(typeOf<List<int>>().base, equals(List));
      // args
      expect(typeOf<Future<String>>().args, equals([String]));
      expect(typeOf<List<Future<String>>>().args.first,
          equals(typeOf<Future<String>>()));
      // baseId
      expect(typeOf<Stream<double>>().baseId, equals('Stream'));
      // nullable
      expect((int).isNullable, equals(false));
      expect(typeOf<bool?>().isNullable, equals(true));
    });

    test('custom types work', () {
      // unresolved
      expect((A).id, equals(''));
      expect((A).name, equals('A'));
      expect((A).base, equals(UnresolvedType));

      TypePlus.add<A>(id: '_A');

      // resolved
      expect((A).id, equals('_A'));

      TypePlus.add<B>(superTypes: {A});

      // super types
      expect((B).implements<A>(), equals(true));
      expect((A).implementedBy(B), equals(true));

      TypePlus.addFactory(<T>(f) => f<C<T>>());

      expect(typeOf<C<int>>().args.first, equals(int));

      expect(() => TypePlus.add<B>(id: '_A'), throwsUnsupportedError);
      expect(() => TypePlus.add<A>(id: '_A'), returnsNormally);
    });

    test('type composition works', () {
      expect(TypePlus.fromId('Future<int>'), equals(typeOf<Future<int>>()));

      expect((int).provideTo(<T>() => T.id), equals('int'));
      expect(typeOf<Iterable<num>>().provideTo(<T>() => T.args.first),
          equals(num));
      expect(typeOf<List<String>>().args.first.provideTo(<T>() => T.name),
          equals('String'));
    });
  });
}
