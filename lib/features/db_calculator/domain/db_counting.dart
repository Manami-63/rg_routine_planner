import '../../../core/scoring/score.dart';
import '../../../core/utils/list_equality.dart';

/// How many body difficulties and risks count towards DB.
///
/// `null` means no limit. Comes from the routine's level; a routine may
/// contain more, the extra ones are simply not counted.
class DbCountLimits {
  const DbCountLimits({this.maxElements, this.maxRisks});

  static const none = DbCountLimits();

  final int? maxElements;
  final int? maxRisks;

  bool get isSet => maxElements != null || maxRisks != null;

  @override
  bool operator ==(Object other) =>
      other is DbCountLimits &&
      other.maxElements == maxElements &&
      other.maxRisks == maxRisks;

  @override
  int get hashCode => Object.hash(maxElements, maxRisks);
}

/// What counts in a routine, by position.
///
/// An element of the routine may stand for several DB (a series), so for
/// each element it records how many of its DB count.
class DbCounting {
  DbCounting._(this.countedPerElement, this.countedRisks);

  /// Selects what counts under [limits]:
  /// - body difficulties: the highest [elementValues], where element `i`
  ///   stands for `dbPerElement[i]` DB of that value (0 for an invalid
  ///   one). An earlier element wins a tie, so the choice is stable;
  /// - risks: the first ones in performance order.
  factory DbCounting.select({
    required List<Score> elementValues,
    required List<int> dbPerElement,
    required int riskCount,
    required DbCountLimits limits,
  }) {
    final dbs =
        [
          for (var i = 0; i < elementValues.length; i++)
            for (var n = 0; n < dbPerElement[i]; n++) i,
        ]..sort((a, b) {
          final diff = elementValues[b].compareTo(elementValues[a]);
          return diff != 0 ? diff : a.compareTo(b);
        });
    final counted = List.filled(elementValues.length, 0);
    for (final i in dbs.take(limits.maxElements ?? dbs.length)) {
      counted[i]++;
    }
    final maxRisks = limits.maxRisks ?? riskCount;
    return DbCounting._(
      List.unmodifiable(counted),
      Set.unmodifiable({for (var i = 0; i < riskCount && i < maxRisks; i++) i}),
    );
  }

  /// For each element of the routine, how many of its DB count.
  final List<int> countedPerElement;

  /// Positions in `DbRoutine.risks` that count.
  final Set<int> countedRisks;

  /// The number of DB that count.
  int get countedDbCount => countedPerElement.fold(0, (sum, n) => sum + n);

  bool isElementCounted(int index) => countedPerElement[index] > 0;

  bool isRiskCounted(int index) => countedRisks.contains(index);

  @override
  bool operator ==(Object other) =>
      other is DbCounting &&
      listEqual(other.countedPerElement, countedPerElement) &&
      setEqual(other.countedRisks, countedRisks);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(countedPerElement),
    Object.hashAllUnordered(countedRisks),
  );
}
