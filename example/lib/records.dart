import 'package:type_plus/src/type_info.dart';
import 'package:type_plus/type_plus.dart';

void main() {

  var r = (1, 2.0, x: 'test');

  printType(r.runtimeType);

  var d = typeOf<Map<String, (int, {String? s})>?>();

  printType(d);

  TypePlus.add<(int, {String? s})>();

  printType(d);
}

void printType(Type t) {
  print('TYPE $t');
  print('BASE ${t.base}');
  print('BASEID ${t.baseId}');
  print('ARGS ${t.args}');
  print('ID ${t.id}');
  print('NONNULL ${t.nonNull}');
}


extension RecordToJson on Record {

  Map<String, dynamic> toJson() {
    var info = RecordInfo.from(this);

    var index = 1;
    for (var p in info.params) {
      this.;
    }
  }

}










