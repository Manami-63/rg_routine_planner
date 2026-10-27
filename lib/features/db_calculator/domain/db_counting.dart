import '../../../core/utils/list_equality.dart';
import 'db_routine.dart';

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

/// Which elements and risks of a routine count, by position.
class DbCounting {
  DbCounting._(this.countedElements, this.countedRisks);

  /// Selects what counts under [limits]:
  /// - body difficulties: the highest-valued ones (an earlier element wins a
  ///   tie, so the choice is stable);
  /// - risks: the first ones in performance order.
  factory DbCounting.select(DbRoutine routine, DbCountLimits limits) {
    final byValue = [for (var i = 0; i < routine.elements.length; i++) i]
      ..sort((a, b) {
        final diff = routine.elements[b].value.compareTo(
          routine.elements[a].value,
        );
        return diff != 0 ? diff : a.compareTo(b);
      });
    final maxElements = limits.maxElements ?? byValue.length;
    final maxRisks = limits.maxRisks ?? routine.risks.length;
    return DbCounting._(
      Set.unmodifiable(byValue.take(maxElements)),
      Set.unmodifiable({
        for (var i = 0; i < routine.risks.length && i < maxRisks; i++) i,
      }),
    );
  }

  /// Positions in `DbRoutine.elements` that count.
  final Set<int> countedElements;

  /// Positions in `DbRoutine.risks` that count.
  final Set<int> countedRisks;

  bool isElementCounted(int index) => countedElements.contains(index);

  bool isRiskCounted(int index) => countedRisks.contains(index);

  @override
  bool operator ==(Object other) =>
      other is DbCounting &&
      setEqual(other.countedElements, countedElements) &&
      setEqual(other.countedRisks, countedRisks);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(countedElements),
    Object.hashAllUnordered(countedRisks),
  );
}
