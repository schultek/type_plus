import 'package:test/test.dart';
import 'package:type_plus/src/type_info.dart';
import 'package:type_plus/type_plus.dart';

import 'utils.dart';

class A {}

class B implements A {}

class C<T> {}

class D<T extends E> {}

class E {}

extension Info on Type {
  TypeInfo get info => TypeInfo.fromType(this);
}

void main() {
  group('type info', () {
    test('parses basic types', () {
      expect((int).info, isInt);
      expect((A).info, isType('A'));
      expect((C<String>).info, isType('C', args: [isString]));
      expect(
        (C<Map<A, D<E>>>).info,
        isType('C', args: [
          isType('Map', args: [
            isType('A'),
            isType('D', args: [isType('E')])
          ])
        ]),
      );
    });

    test('parses function types', () {
      expect(typeOf<int Function()>().info, isFunctionType(isInt));
      expect(typeOf<void Function(double)>().info, isFunctionType(isVoid, params: [isDouble]));
      expect(
        typeOf<C<A> Function({String a, bool b})>().info,
        isFunctionType(isType('C', args: [isType('A')]), namedParams: {'a': isString, 'b': isBool}),
      );
      expect(
        typeOf<T Function<T>(List<T>)>().info,
        isFunctionType(isType('Y0'), args: [
          isType('Y0')
        ], params: [
          isType('List', args: [isType('Y0')])
        ]),
      );
      expect(
        typeOf<void Function() Function(String)>().info,
        isFunctionType(isFunctionType(isVoid), params: [isString]),
      );
      expect(
        typeOf<void Function<T>() Function<T, A extends String Function<V>()>(String)>().info,
        isFunctionType(isFunctionType(isVoid, args: [isType('F2Y0')]), params: [
          isString
        ], args: [
          isType('Y0'),
          isType('Y1', bound: isFunctionType(isString, args: [isType('F2Y0')]))
        ]),
      );
    });

    test('parses record types', () {
      expect(typeOf<(int,)>().info, isRecordType([isInt]));
      expect(typeOf<(int, String, bool)>().info, isRecordType([isInt, isString, isBool]));
      expect(typeOf<(A, {B b})>().info, isRecordType([isType('A')], named: {'b': isType('B')}));
      expect(
        typeOf<(void Function(), {C<bool> Function<T extends ({String x})>({(int,) p}) fn})>().info,
        isRecordType([
          isFunctionType(isVoid)
        ], named: {
          'fn': isFunctionType(isType('C', args: [isBool]), args: [
            isType('Y0', bound: isRecordType([], named: {'x': isString}))
          ], namedParams: {
            'p': isRecordType([isInt])
          })
        }),
      );
    });

    test("Whitespace bug", () {
      Type a = Map;
      Type b = int;
      
      Type withoutSpaceAfterComma = TypePlus.fromId('${a.id}<${b.id},${b.id}>');
      Type oneSpaceAfterComma = TypePlus.fromId('${a.id}<${b.id}, ${b.id}>');
      Type twoSpaceAfterComma = TypePlus.fromId('${a.id}<${b.id},  ${b.id}>');
      Type spaceAroundComma = TypePlus.fromId('${a.id}<${b.id} , ${b.id}>');

      expect(withoutSpaceAfterComma.base, a);
      withoutSpaceAfterComma.args.forEach((element) => expect(element, b));

      expect(oneSpaceAfterComma, withoutSpaceAfterComma);
      expect(twoSpaceAfterComma, withoutSpaceAfterComma);
      expect(spaceAroundComma, withoutSpaceAfterComma);

    });
  });
}
