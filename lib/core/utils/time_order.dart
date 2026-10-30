/// The order of items after putting the ones with a time in time order:
/// `result[i]` is the old position of the item that ends up at position
/// `i`.
///
/// Items without a time keep their positions; timed items fill the other
/// positions sorted by time (equal times keep their order).
List<int> timeOrder(List<Duration?> times) {
  final timedPositions = [
    for (final (i, time) in times.indexed)
      if (time != null) i,
  ];
  final sorted = [...timedPositions]
    ..sort((a, b) {
      final byTime = times[a]!.compareTo(times[b]!);
      return byTime != 0 ? byTime : a.compareTo(b);
    });
  final order = List.generate(times.length, (i) => i);
  for (final (slot, position) in timedPositions.indexed) {
    order[position] = sorted[slot];
  }
  return order;
}

/// [items] rearranged by [order] (from [timeOrder]).
List<T> reorderBy<T>(List<T> items, List<int> order) => [
  for (final i in order) items[i],
];
