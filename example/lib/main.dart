import 'package:type_plus/type_plus.dart';

class Person {}

class Box<T> {}

void main() {
  // first, specify all classes using this syntax
  TypePlus.addFactory((f) => f<Person>());
  // or this syntax sugar for non-generic classes
  TypePlus.add<Person>();

  // for generic classes, use a generic function
  TypePlus.addFactory(<T>(f) => f<Box<T>>());

  // get a type variable
  Type personType = Person;
  // for generic types, use this helper function
  Type boxOfString = typeOf<Box<String>>();

  print(boxOfString.base); // the base type: Box<dynamic>
  print(boxOfString.args); // the type arguments: [String]

  myFunction<Person>(); // prints "Hi!"
  myFunction<Box<int>>(); // prints "Box of ints"

  // invoke a generic function with the correct type argument
  personType.call(<T>() => print(T)); // prints: "Person"
}

void myFunction<T>() {
  if (T.base == Person) {
    print("Hi!");
  } else if (T.base == Box) {
    print("Box of ${T.args.first}s");
  }
}
