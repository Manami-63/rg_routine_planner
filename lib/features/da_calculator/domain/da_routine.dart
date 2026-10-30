import '../../../core/floor/floor_cell.dart';
import '../../../core/utils/list_equality.dart';
import '../../../core/utils/time_order.dart';
import 'da_element.dart';

/// The DA part of a routine: apparatus difficulties in performance order.
///
/// Order matters, because DA count in chronological order. Name, level and
/// identity belong to the enclosing `Routine`. Every change returns a new
/// instance.
class DaRoutine {
  /// [times] and [cells] match [elements] by position; when omitted,
  /// nothing has a time or cell.
  DaRoutine({
    required this.rulesetId,
    List<DaElement> elements = const [],
    List<Duration?>? times,
    List<FloorCell?>? cells,
  }) : elements = List.unmodifiable(elements),
       times = List.unmodifiable(
         times ?? List<Duration?>.filled(elements.length, null),
       ),
       cells = List.unmodifiable(
         cells ?? List<FloorCell?>.filled(elements.length, null),
       ) {
    if (this.times.length != this.elements.length) {
      throw ArgumentError('times must match elements');
    }
    if (this.cells.length != this.elements.length) {
      throw ArgumentError('cells must match elements');
    }
  }

  /// The [RulesetVersion.id] this content is planned against.
  final String rulesetId;

  final List<DaElement> elements;

  /// When each element starts in the music (same positions), or `null`
  /// when not marked.
  final List<Duration?> times;

  /// Where on the floor each element starts (same positions), or `null`.
  final List<FloorCell?> cells;

  bool get isEmpty => elements.isEmpty;

  DaRoutine _with(
    List<DaElement> elements,
    List<Duration?> times,
    List<FloorCell?> cells,
  ) => DaRoutine(
    rulesetId: rulesetId,
    elements: elements,
    times: times,
    cells: cells,
  );

  DaRoutine withElementAdded(DaElement element) =>
      _with([...elements, element], [...times, null], [...cells, null]);

  /// Replaces the element at [index], keeping its time and cell.
  DaRoutine withElementReplacedAt(int index, DaElement element) =>
      _with([...elements]..[index] = element, times, cells);

  DaRoutine withElementRemovedAt(int index) => _with(
    [...elements]..removeAt(index),
    [...times]..removeAt(index),
    [...cells]..removeAt(index),
  );

  /// Moves the element at [from] (with its time and cell) so it ends up at
  /// position [to].
  DaRoutine withElementMoved(int from, int to) {
    List<T> moved<T>(List<T> items) {
      final moved = [...items];
      moved.insert(to, moved.removeAt(from));
      return moved;
    }

    return _with(moved(elements), moved(times), moved(cells));
  }

  /// Sets when the element at [index] starts, then puts the timed elements
  /// in time order (which can change which DA count). `null` clears the
  /// time and the cell.
  DaRoutine withElementTimeAt(int index, Duration? time) {
    final times = [...this.times]..[index] = time;
    final cells = [...this.cells];
    if (time == null) cells[index] = null;
    final order = timeOrder(times);
    return _with(
      reorderBy(elements, order),
      reorderBy(times, order),
      reorderBy(cells, order),
    );
  }

  DaRoutine withElementCellAt(int index, FloorCell? cell) =>
      _with(elements, times, [...cells]..[index] = cell);

  /// Clears every time and cell; the order is kept.
  DaRoutine withTimesCleared() => _with(
    elements,
    List.filled(elements.length, null),
    List.filled(elements.length, null),
  );

  /// Removes all elements but keeps the ruleset.
  DaRoutine cleared() => DaRoutine(rulesetId: rulesetId);

  @override
  bool operator ==(Object other) =>
      other is DaRoutine &&
      other.rulesetId == rulesetId &&
      listEqual(other.elements, elements) &&
      listEqual(other.times, times) &&
      listEqual(other.cells, cells);

  @override
  int get hashCode => Object.hash(
    rulesetId,
    Object.hashAll(elements),
    Object.hashAll(times),
    Object.hashAll(cells),
  );
}
