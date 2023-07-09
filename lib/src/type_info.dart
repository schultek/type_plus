import 'dart:math';

class TypeInfo {
  String type = '';
  List<TypeInfo> args = [];
  TypeInfo? bound;
  bool isNullable = false;
  TypeInfo? parent;

  static final Map<Type, TypeInfo> _typeInfo = {};

  static TypeInfo fromType<T>([Type? type]) {
    var t = type ?? T;
    if (_typeInfo[t] != null) {
      return _typeInfo[t]!;
    }
    return _typeInfo[t] = fromString(t.toString());
  }

  static TypeInfo fromString(String typeString) {
    return TypeInfoBuilder.from(typeString).build();
  }

  @override
  String toString() =>
      '$type${args.isNotEmpty ? '<${args.join(', ')}>' : ''}${isNullable ? '?' : ''}${bound != null ? ' extends $bound' : ''}';
}

class FunctionInfo extends TypeInfo {
  TypeInfo returns = TypeInfo();
  List<TypeInfo> params = [];
  List<TypeInfo> optionalParams = [];
  Map<String, TypeInfo> namedParams = {};

  static FunctionInfo from(Function fn) {
    return TypeInfo.fromType(fn.runtimeType) as FunctionInfo;
  }

  @override
  String toString() {
    var str = "";
    if (args.isNotEmpty) {
      str += '<${args.join(', ')}>';
    }
    str += '(${params.join(', ')}';
    if (params.isNotEmpty && (optionalParams.isNotEmpty || namedParams.isNotEmpty)) {
      str += ', ';
    }
    if (optionalParams.isNotEmpty) {
      str += '[${optionalParams.join(', ')}]';
    } else if (namedParams.isNotEmpty) {
      str += '{${namedParams.entries.map((e) => '${e.value} ${e.key}').join(', ')}}';
    }
    str += ') => $returns';
    if (isNullable) {
      str = '($str)?';
    }
    return str;
  }
}

class RecordInfo extends TypeInfo {
  String get type {
    return '('
        '${params.indexed.map((r) => '\$${r.$1}').join(', ')}'
        '${params.isNotEmpty && namedParams.isNotEmpty ? ', ' : ''}'
        '${namedParams.isNotEmpty ? '{'
        '${namedParams.entries.map((e) => '${e.key}').join(', ')}'
        '}' : ''}'
        ')';
  }

  List<TypeInfo> get args {
    return [...params, ...namedParams.values];
  }

  List<TypeInfo> params = [];
  List<TypeInfo> optionalParams = [];
  Map<String, TypeInfo> namedParams = {};

  static RecordInfo from(Record r) {
    return TypeInfo.fromType(r.runtimeType) as RecordInfo;
  }

  @override
  String toString() {
    var str = "";
    str += '(${params.join(', ')}';
    if (params.isNotEmpty && (optionalParams.isNotEmpty || namedParams.isNotEmpty)) {
      str += ', ';
    }
    if (optionalParams.isNotEmpty) {
      str += '[${optionalParams.join(', ')}]';
    } else if (namedParams.isNotEmpty) {
      str += '{${namedParams.entries.map((e) => '${e.value} ${e.key}').join(', ')}}';
    }
    str += ')';
    if (isNullable) {
      str = '$str?';
    }
    return str;
  }
}

typedef EndCheck = bool Function();

class TypeInfoBuilder {
  String name = '';
  List<TypeInfo> args = [];
  TypeInfo? bound;
  bool isNullable = false;
  bool isRecord = false;
  bool isFunction = false;
  TypeInfo? returns;
  List<TypeInfo> params = [];
  List<TypeInfo> optionalParams = [];
  Map<String, TypeInfo> namedParams = {};

  TypeInfo build() {
    if (isFunction) {
      assert(name.isEmpty);
      return FunctionInfo()
        ..returns = returns!
        ..params = params
        ..optionalParams = optionalParams
        ..namedParams = namedParams
        ..args = args
        ..isNullable = isNullable;
    } else if (isRecord) {
      assert(name.isEmpty);
      assert(args.isEmpty);
      assert(optionalParams.isEmpty);
      return RecordInfo()
        ..params = params
        ..namedParams = namedParams
        ..isNullable = isNullable;
    } else {
      assert(params.isEmpty);
      assert(optionalParams.isEmpty);
      assert(namedParams.isEmpty);
      return TypeInfo()
        ..type = name
        ..isNullable = isNullable
        ..args = args
        ..bound = bound;
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
        if (r.peek(4) == ' => ') {
          b.isFunction = true;
          r.read(4);
          var bb = _visitType(r, endWhen: endWhen);
          b.returns = bb.build();
        } else {
          b.isRecord = true;
        }
      } else if (r.peek() == '?') {
        b.isNullable = true;
        r.read();
      } else if (r.peek(9) == ' extends ') {
        r.read(9);
        var bb = _visitType(r, endWhen: endWhen);
        b.bound = bb.build();
      } else {
        b.name += r.read();
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
        var bb = _visitType(r, endWhen: () => r.peek() == '>' || r.peek(2) == ', ');
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
        var bb = _visitType(r, endWhen: () => r.peek() == end || r.peek(2) == ', ');
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
        var bb = _visitType(r, endWhen: () => r.peek() == '}' || r.peek(2) == ', ');
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
