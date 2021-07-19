extension PartitionedList<T> on List<List<T>> {
  List<List<T>> power() =>
      any((l) => l.isEmpty) ? [] : _power(List.filled(length, 0));

  List<List<T>> _power(List<int> indexes) {
    return [
      mapIndex((e, i) => e[indexes[i]]).toList(),
      for (int i = 0; i < length; i++)
        if (indexes[i] < this[i].length - 1)
          ..._power(
            indexes.mapIndex((e, j) => i == j ? e + 1 : e).toList(),
          )
    ];
  }
}

extension IndexMap<T> on Iterable<T> {
  Iterable<U> mapIndex<U>(U Function(T e, int index) fn) {
    int i = 0;
    return map((e) => fn(e, i++));
  }

  T? get firstOrNull => isEmpty ? null : first;
}
