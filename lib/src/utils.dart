extension PartitionedList<T> on Iterable<Iterable<T>> {
  Iterable<Iterable<T>> power() => _power(Iterable.empty(), this);
}

Iterable<Iterable<T>> _power<T>(Iterable<T> head, Iterable<Iterable<T>> tails) sync* {
  if (tails.isEmpty) {
    yield head;
    return;
  }
  var nextTail = tails.skip(1);
  for (var m in tails.first) {
    yield* _power(head.followedBy([m]), nextTail);
  }
}

/// Helper function to get a type variable from a generic type argument.
Type typeOf<T>() => T;
