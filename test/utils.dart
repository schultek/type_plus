import 'package:test/test.dart';
import 'package:type_plus/src/type_info.dart';

Matcher isType(String name, {List<Matcher> args = const [], Matcher? bound}) {
  return isA<TypeInfo>()
      .having((i) => i, 'runtimeType', isNot(anyOf(isA<FunctionInfo>(), isA<RecordInfo>())))
      .having((i) => i.type, 'name', equals(name))
      .having((i) => i.args, 'args', equals(args))
      .having((i) => i.bound, 'bound', bound);
}

Matcher isVoid = isType('void');
Matcher isInt = isType('int');
Matcher isDouble = isType('double');
Matcher isString = isType('String');
Matcher isBool = isType('bool');

Matcher isFunctionType(
  Matcher returns, {
  List<Matcher> args = const [],
  List<Matcher> params = const [],
  List<Matcher> optionalParams = const [],
  Map<String, Matcher> namedParams = const {},
}) {
  return isA<FunctionInfo>()
      .having((i) => i.returns, 'returns', equals(returns))
      .having((i) => i.args, 'args', equals(args))
      .having((i) => i.params, 'params', equals(params))
      .having((i) => i.optionalParams, 'optionalParams', equals(optionalParams))
      .having((i) => i.namedParams, 'namedParams', equals(namedParams));
}

Matcher isRecordType(
  List<Matcher> params, {
  Map<String, Matcher> named = const {},
}) {
  return isA<RecordInfo>()
      .having((i) => i.params, 'params', equals(params))
      .having((i) => i.namedParams, 'namedParams', equals(named));
}
