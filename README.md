# Type Plus

> Give your types superpowers and spice up your generics. Make types great again.

With type_plus you can easily deconstruct any type variable or generic type argument.

```dart
import 'package:type_plus/type_plus.dart';

class Person {}

class Box<T> {}

void main() {
  // first, specify all types using this syntax
  TypePlus.addFactory((f) => f<Person>());
  // or this simple version for non-generic types
  TypePlus.add<Person>();

  // for generic types, use a generic function
  TypePlus.addFactory(<T>(f) => f<Box<T>>());

  // get a type variable
  Type personType = Person;
  // for generic types, use this helper function
  Type boxOfString = typeOf<Box<String>>();

  print(personType.name); // the name of the type: Person
  print(personType.id); // the id of the type: (some unique number)

  print(boxOfString.base); // the base type: Box<dynamic>
  print(boxOfString.args); // the type arguments: [String]

  myFunction<Person>(); // prints "Hi!"
  myFunction<Box<int>>(); // prints "Box of ints"

  // invoke a generic function with the full type
  boxOfString.call(<T>() => print(T)); // prints: "Box<String>"
  // invoke a generic function with the type parameters
  boxOfString.callWithParams(<T>() => print(T)); // prints: "String"

  String boxId = boxOfString.base.id; // id of the base type
  String personId = personType.id;

  // construct a new type by it's id
  Type newType = TypePlus.fromId('$boxId<$personId>');
  print(newType); // prints: "Box<Person>"
}

void myFunction<T>() {
  if (T.base == Person) {
    print("Hi!");
  } else if (T.base == Box) {
    print("Box of ${T.args.first}s");
  }
}

```