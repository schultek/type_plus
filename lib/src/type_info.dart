class TypeInfo {
  String type = '';
  List<TypeInfo> args = [];
  bool isNullable = false;
  TypeInfo? parent;

  @override
  String toString() =>
      '$type${args.isNotEmpty ? '<${args.join(', ')}>${isNullable ? '?' : ''}' : ''}';

  static String id<T>([Type? t]) {
    var input = (t ?? T).toString();
    return input.split('<')[0];
  }

  static TypeInfo fromType<T>([Type? type]) {
    var typeString = (type ?? T).toString();
    var curr = TypeInfo();

    for (var i = 0; i < typeString.length; i++) {
      var c = typeString[i];
      if (c == '<') {
        var t = TypeInfo();
        curr.args.add(t..parent = curr);
        curr = t;
      } else if (c == '>') {
        curr = curr.parent!;
      } else if (c == ' ') {
        continue;
      } else if (c == ',') {
        var t = TypeInfo();
        curr = curr.parent!;
        curr.args.add(t..parent = curr);
        curr = t;
      } else if (c == '?') {
        curr.isNullable = true;
      } else {
        curr.type += c;
      }
    }

    return curr;
  }
}
