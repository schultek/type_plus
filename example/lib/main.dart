import 'package:type_plus/type_plus.dart';

class Person {}

class Box<T> {}

abstract class Group extends Iterable<Person> {}

void checkType<T>() {
  if (T.base == Person) {
    print("Hi!");
  } else if (T.base == Box) {
    print("Box of ${T.args.first}s");
  }
}

void printType<T>() {
  print(T);
}

void main() {
  // first, specify all types using this syntax
  TypePlus.addFactory((f) => f<Person>());
  // or this simple version for non-generic types
  TypePlus.add<Person>();

  // for generic types, use a generic function
  TypePlus.addFactory(<T>(f) => f<Box<T>>());
  // for extending classes, make sure to put all supertypes
  TypePlus.add<Group>(superTypes: [Iterable<Person>]);

  // get a type variable
  Type personType = Person;
  Type boxOfString = Box<String>;

  print(personType.name); // the name of the type: Person
  print(personType.id); // the id of the type: (some unique number)

  print(boxOfString.base); // the base type: Box<dynamic>
  print(boxOfString.args); // the type arguments: [String]

  checkType<Person>(); // prints "Hi!"
  checkType<Box<int>>(); // prints "Box of ints"

  // invoke a generic function with the full type
  boxOfString.provideTo(printType); // prints: "Box<String>"

  // invoke a generic function with the type arguments
  printType.callWith(typeArguments: boxOfString.args); // prints: "String"

  String boxId = boxOfString.base.id; // id of the base type
  String personId = personType.id;

  // construct a new type by it's id
  Type newType = TypePlus.fromId('$boxId<$personId>');
  assert(newType == Box<Person>);

  // check if a type implements another type
  assert(newType.implements(Box));
  assert((Group).implements(Iterable<Person>));

  // or the other way around
  assert((num).implementedBy(int));
}
