import 'package:type_plus/type_plus.dart';

class Person {}

class Box<T> {}

void main() {
  // first, specify all classes using this syntax
  TypePlus.add((f) => f<Person>());
  // for generic classes, use a generic function
  TypePlus.add(<T>(f) => f<Box<T>>());

  // get a type variable
  Type personType = Person;
  // for generic types, use this helper function
  Type boxOfString = typeOf<Box<String>>();

  print(personType.base); // the base type: Person
  print(boxOfString.args); // the type arguments: [String]

  myFunction<Person>(); // prints "Hi!"
  myFunction<Box<int>>(); // prints "Box of numbers"
}

void myFunction<T>() {
  print("Called with $T");

  if (T.base == Person) {
    print("Hi!");
  } else if (T.base == Box) {
    if (T.args.first == int) {
      print("Box of numbers");
    } else {
      print("Box of ${T.args.first}s");
    }
  }
}
