import 'dart:math';

class TypeInfo {
  String type = '';
  List<TypeInfo> args = [];
  bool isNullable = false;
  TypeInfo? parent;

  static String name<T>([Type? t]) {
    var input = (t ?? T).toString();
    return input.split('<')[0];
  }

  static TypeInfo fromType<T>([Type? type]) {
    return fromString((type ?? T).toString());
  }

  static TypeInfo fromString(String typeString) {
    return TypeInfoBuilder.from(typeString).build();
  }

  @override
  String toString() =>
      '$type${args.isNotEmpty ? '<${args.join(', ')}>' : ''}${isNullable ? '?' : ''}';
}

class FunctionInfo extends TypeInfo {
  TypeInfo returns = TypeInfo();
  List<TypeInfo> params = [];
  List<TypeInfo> optionalParams = [];
  Map<String, TypeInfo> namedParams = {};

  static FunctionInfo from(Function fn) {
    return TypeInfo.fromString(fn.runtimeType.toString()) as FunctionInfo;
  }

  @override
  String toString() {
    var str = "";
    if (args.isNotEmpty) {
      str += '<${args.join(', ')}>';
    }
    str += '(${params.join(', ')}';
    if (params.isNotEmpty &&
        (optionalParams.isNotEmpty || namedParams.isNotEmpty)) {
      str += ', ';
    }
    if (optionalParams.isNotEmpty) {
      str += '[${optionalParams.join(', ')}]';
    } else if (namedParams.isNotEmpty) {
      str +=
          '{${namedParams.entries.map((e) => '${e.value} ${e.key}').join(', ')}}';
    }
    str += ') => $returns';
    if (isNullable) {
      str = '($str)?';
    }
    return str;
  }
}

typedef EndCheck = bool Function();

class TypeInfoBuilder {
  String name = '';
  List<TypeInfo> args = [];
  bool isNullable = false;
  bool isFunction = false;
  TypeInfo? returns;
  List<TypeInfo> params = [];
  List<TypeInfo> optionalParams = [];
  Map<String, TypeInfo> namedParams = {};

  TypeInfo build() {
    if (isFunction) {
      return FunctionInfo()
        ..returns = returns!
        ..params = params
        ..optionalParams = optionalParams
        ..namedParams = namedParams
        ..args = args
        ..isNullable = isNullable;
    } else if (params.length == 1) {
      return params.first..isNullable = isNullable;
    } else {
      return TypeInfo()
        ..type = name
        ..isNullable = isNullable
        ..args = args;
    }
  }

  static from(String typeString) {
    var reader = StringReader(typeString);
    return _visitType(reader);
  }

  static TypeInfoBuilder _visitType(StringReader r, {EndCheck? endWhen}) {
    var b = TypeInfoBuilder();
    while (r.hasNext()) {
      if (endWhen?.call() ?? false) {
        break;
      } else if (r.peek() == '<') {
        var bb = _visitArgs(r..read());
        b.args = bb.args;
      } else if (r.peek() == '(') {
        var bb = _visitParams(r..read());
        b.params = bb.params;
        b.optionalParams = bb.optionalParams;
        b.namedParams = bb.namedParams;
      } else if (r.peek(4) == ' => ') {
        b.isFunction = true;
        r.read(4);
      } else if (r.peek() == '?') {
        b.isNullable = true;
        r.read();
      } else {
        if (b.isFunction) {
          var bb = _visitType(r, endWhen: endWhen);
          b.returns = bb.build();
        } else {
          b.name += r.read();
        }
      }
    }

    return b;
  }

  static TypeInfoBuilder _visitArgs(StringReader r) {
    var b = TypeInfoBuilder();
    while (r.hasNext()) {
      if (r.peek() == '>') {
        r.read();
        break;
      } else if (r.peek(2) == ', ') {
        r.read(2);
        continue;
      } else {
        var bb =
            _visitType(r, endWhen: () => r.peek() == '>' || r.peek(2) == ', ');
        b.args.add(bb.build());
      }
    }
    return b;
  }

  static TypeInfoBuilder _visitParams(StringReader r, [String end = ')']) {
    var b = TypeInfoBuilder();
    while (r.hasNext()) {
      if (r.peek(2) == ', ') {
        r.read(2);
        continue;
      } else if (r.peek() == '[') {
        var bb = _visitParams(r..read(), ']');
        b.optionalParams = bb.params;
      } else if (r.peek() == '{') {
        var bb = _visitNamedParams(r..read());
        b.namedParams = bb.namedParams;
      } else if (r.peek() == end) {
        r.read();
        break;
      } else {
        var bb =
            _visitType(r, endWhen: () => r.peek() == end || r.peek(2) == ', ');
        b.params.add(bb.build());
      }
    }
    return b;
  }

  static TypeInfoBuilder _visitNamedParams(StringReader r) {
    var b = TypeInfoBuilder();
    while (r.hasNext()) {
      if (r.peek(2) == ', ') {
        r.read(2);
        continue;
      } else if (r.peek() == '}') {
        r.read();
        break;
      } else {
        var bb =
            _visitType(r, endWhen: () => r.peek() == '}' || r.peek(2) == ', ');
        if (bb.isFunction) {
          var name = bb.returns!.type.split(' ');
          bb.returns!.type = name[0];
          b.namedParams[name[1]] = bb.build();
        } else {
          var name = bb.name.split(' ');
          bb.name = name[0];
          b.namedParams[name[1]] = bb.build();
        }
      }
    }
    return b;
  }
}

class StringReader {
  String _str;
  int _i;

  StringReader(this._str) : _i = 0;

  bool hasNext() {
    return _i < _str.length;
  }

  String read([int n = 1]) {
    var o = _str.substring(_i, _i + n);
    _i += n;
    return o;
  }

  String peek([int n = 1]) {
    return _str.substring(_i, min(_str.length, _i + n));
  }
}
