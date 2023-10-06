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

typedef EndCheck = bool Function(String);

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
    var reader = TokenIterator(typeString);
    reader.moveNext();
    return _visitType(reader);
  }

  static TypeInfoBuilder _visitType(Iterator<String?> it, {EndCheck? endWhen}) {
    var b = TypeInfoBuilder();
    while (true) {
      var token = it.current;
      if (token == null) {
        break;
      } else if (endWhen?.call(token) ?? false) {
        break;
      } else if (token == '<') {
        it.moveNext();
        var bb = _visitArgs(it);
        b.args = bb.args;
      } else if (token == '(') {
        it.moveNext();
        var bb = _visitParams(it);
        b.params = bb.params;
        b.optionalParams = bb.optionalParams;
        b.namedParams = bb.namedParams;

        // Assume a record until we see a function.
        b.isRecord = true;
      } else if (token == '=>') {
        it.moveNext();
        b.isRecord = false;
        b.isFunction = true;
        var bb = _visitType(it, endWhen: endWhen);
        b.returns = bb.build();
      } else if (token == '?') {
        it.moveNext();
        b.isNullable = true;
      } else if (token == 'extends') {
        it.moveNext();
        var bb = _visitType(it, endWhen: endWhen);
        b.bound = bb.build();
      } else {
        if (b.name.isNotEmpty || b.isRecord || b.isFunction) {
          // The name token belongs to a named param
          break;
        }
        it.moveNext();
        b.name = token;
      }
    }

    return b;
  }

  static TypeInfoBuilder _visitArgs(Iterator<String?> it) {
    var b = TypeInfoBuilder();
    while (true) {
      var token = it.current;
      if (token == null) {
        break;
      } else if (token == '>') {
        it.moveNext();
        break;
      } else if (token == ',') {
        it.moveNext();
        continue;
      } else {
        var bb = _visitType(it, endWhen: (t) => t == '>' || t == ',');
        b.args.add(bb.build());
      }
    }
    return b;
  }

  static TypeInfoBuilder _visitParams(Iterator<String?> it, [String end = ')']) {
    var b = TypeInfoBuilder();
    while (true) {
      var token = it.current;
      if (token == null) {
        break;
      } else if (token == ',') {
        it.moveNext();
        continue;
      } else if (token == end) {
        it.moveNext();
        break;
      } else if (token == '[') {
        it.moveNext();
        var bb = _visitParams(it, ']');
        b.optionalParams = bb.params;
      } else if (token == '{') {
        it.moveNext();
        var bb = _visitNamedParams(it);
        b.namedParams = bb.namedParams;
      } else {
        var bb = _visitType(it, endWhen: (t) => t == end || t == ',');
        b.params.add(bb.build());
      }
    }
    return b;
  }

  static TypeInfoBuilder _visitNamedParams(Iterator<String?> it) {
    var b = TypeInfoBuilder();
    while (true) {
      var token = it.current;
      if (token == null) {
        break;
      } else if (token == ',') {
        it.moveNext();
        continue;
      } else if (token == '}') {
        it.moveNext();
        break;
      } else {
        var bb = _visitType(it, endWhen: (t) => t == '}' || t == ',');
        var name = it.current!;
        it.moveNext();
        b.namedParams[name] = bb.build();
      }
    }
    return b;
  }
}

class TokenIterator implements Iterator<String?> {
  String _str;
  (int, int)? _curr;

  TokenIterator(this._str) : _curr = (0, 0) {
    _str = _str.trim();
  }

  final _whitespace = ' ';

  bool moveNext() {
    var i = _curr!.$2;
    while (i < _str.length && _str.substring(i, i + 1) == _whitespace) {
      i++;
    }
    var e = i;
    if (i >= _str.length) {
      _curr = null;
      return false;
    }

    var isName = false;
    while (e < _str.length) {
      var nextChar = _str.substring(e, e + 1);
      if (nextChar == _whitespace) {
        break;
      } else if ({'<', '>', '(', ')', '[', ']', '{', '}', ',', '?'}.contains(nextChar)) {
        if (!isName) {
          e++;
        }
        break;
      } else if (e < _str.length - 1 && _str.substring(e, e + 2) == '=>') {
        if (!isName) {
          e += 2;
        }
        break;
      } else {
        isName = true;
        e++;
      }
    }

    _curr = (i, e);
    return true;
  }

  String? get current {
    return switch (_curr) {
      null => null,
      (var i, var e) => _str.substring(i, e),
    };
  }
}
