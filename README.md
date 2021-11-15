# Type Plus

> Give your types superpowers and spice up your generics. Make types great again.

type_plus is a utility package to bring some advanced capabilities to type variables and generic type arguments
With type_plus you can easily deconstruct any type variable or generic type argument.

- [Getting Started](#getting-started)
- [Working with types](#working-with-types)
- [Type decomposition](#type-decomposition)
- [Generic invocation](#generic-invocation)
- [Type ids](#type-ids)
- [Type inheritance](#type-inheritance)

## Getting started

First you have to register all types you want to use later on. It makes sense to do this early on in the `main()` method of
your dart program. 

> You only need to register custom types. All primitive and default dart types (String, int, ..., List, Map, ...) are already registered by default.

For basic, non-generic types you can do the following:
```dart
TypePlus.add<MyClss>();
```

For generic types, you have to specify a type factory. This is a special kind of function with the following syntax:
```dart
class MyClass<A, B> {}

void main() {
  TypePlus.addFactory(<A, B>(f) => f<MyClass<A, B>>());
}
```

As you can see, the type factory function is a generic function that takes as many type arguments (`A, B`) as your target class defines. 
Then you have to call `f` with your generic type.

After that, whenever you have a generic type argument or type variable, you can use the following properties on it:

```dart
void myGenericFunction<T>() {
  String name = T.name; // the full name of the type
  String id = T.id; // a unique id of the type
    
  Type base = T.base; // the base type of a generic type
  List<Type> args = T.args; // the type arguments of a generic type
}
```

> Read on for a more detailed explanation of the available properties or take a look at the example.

## Working with types

There are two ways you can get an instance of a `Type` in dart:

1. **Generic type argument**  
   This can either come from a generic class or generic function. 
   
	```dart
	class MyClass<T> {
	  String get name => T.name;
	}
	// or
	void myFunction<T>() {
	  String name = T.name;
	}
	```

2. **Type variable**  
   Types can also be used as variables. When using a non-generic type, you can simply assign this type to a variable. When using generic types, you have to use a helper function.
   
	```dart
	void main() {
	  // simple type variable
	  Type a = int;
	  // using the helper function
	  Type b = typeOf<List<int>>();  
	  
	  String aName = a.name;
	  String bName = b.name;
 
      // simple types can also be used in expressions wrapped in ()
      print((double).name);
	}
	```

## Type decomposition

With this package, you can decompose a generic type into its type components. 
Let's say we have the type `Map<String, int>`, then:

- the decomposed base type would be `Map` (or more concrete `Map<dynamic, dynamic>` because of how darts type system works) and 
- the decomposed type arguments would be `String` and `int`.

```dart
void main() {
  var type = typeOf<Map<String, int>>();
  
  String name = T.name; // = "Map<String, int>"
  
  Type base = T.base; // = Map
  List<Type> args = T.args; // = [String, int]
}
```

## Generic invocation

Normally in dart, a generic type argument can only be provided statically. This means you cannot invoke a generic method when you only have a type variable.

With this package however, you can call a generic method and provide type variables for the generic arguments:

```dart
void printType<T>() {
  print(T.name);
}

void main() {
  var type = typeOf<Map<String, int>>();
  
  // prints: "Map<String, int>"
  printType.callWith(typeArguments: [type]);
  
  // prints: "String"
  printType.callWith(typeArguments: [type.args.first]);
}
```

## Type IDs

With type_plus, every type has a unique id.

Additionally to identifying a type, you can use ids to construct a generic type from a string:

```dart
void main() {
  Type a = List;
  Type b = int;
  
  Type newType = TypePlus.fromId('${a.id}<${b.id}>');
  assert(newType.base == a);
  assert(newType.args.first == b);
}
```

When registering a type, you can provide a custom id to be used:

```dart
void main() {
  TypePlus.add<MyClass>(id: 'CoolId');
  
  Type myType = TypePlus.fromId('CoolId');
  assert(myType == MyClass);
}
```

## Type inheritance

When dealing with object variables, there exists the `is` operator for checking the inheritance of an object. However there exists nothing like this for types.

With type_plus, you can do 

- `typeA.implements(typeB)` and
- `typeB.implementedBy(typeA)`

to check the inheritance of types.

In order for this to work, you have to explicitly set the supertypes of any type when registering it. This includes any extends, implements and mixins.

```
class MyClass extends List<int> {}

void main() {
  var listType = typeOf<List<int>>();
  
  TypePlus.add<MyClass>(superTypes: [listType]);
  
  var myType = MyClass;
  
  assert(myType.implements(listType));
  assert(listType.implementedBy(myType));
  
  assert(!myType.implements(List)); // needs to be the full specified type
} 
```