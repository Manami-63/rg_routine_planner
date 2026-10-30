import '../../../core/utils/list_equality.dart';
import '../../../core/utils/time_order.dart';
import 'da_element.dart';

/// The DA part of a routine: apparatus difficulties in performance order.
///
/// Order matters, because DA count in chronological order. Name, level and
/// identity belong to the enclosing `Routine`. Every change returns a new
/// instance.
class DaRoutine {
  /// [times] matches [elements] by position; when omitted, nothing has a
  /// time.
  DaRoutine({
    required this.rulesetId,
    List<DaElement> elements = const [],
    List<Duration?>? times,
  }) : elements = List.unmodifiable(elements),
       times = List.unmodifiable(
         times ?? List<Duration?>.filled(elements.length, null),
       ) {
    if (this.times.length != this.elements.length) {
      throw ArgumentError('times must match elements');
    }
  }

  /// The [RulesetVersion.id] this content is planned against.
  final String rulesetId;

  final List<DaElement> elements;

  /// When each element starts in the music (same positions), or `null`
  /// when not marked.
  final List<Duration?> times;

  bool get isEmpty => elements.isEmpty;

  DaRoutine _with(List<DaElement> elements, List<Duration?> times) =>
      DaRoutine(rulesetId: rulesetId, elements: elements, times: times);

  DaRoutine withElementAdded(DaElement element) =>
      _with([...elements, element], [...times, null]);

  /// Replaces the element at [index], keeping its time.
  DaRoutine withElementReplacedAt(int index, DaElement element) =>
      _with([...elements]..[index] = element, times);

  DaRoutine withElementRemovedAt(int index) =>
      _with([...elements]..removeAt(index), [...times]..removeAt(index));

  /// Moves the element at [from] (with its time) so it ends up at position
  /// [to].
  DaRoutine withElementMoved(int from, int to) {
    final elements = [...this.elements];
    final times = [...this.times];
    elements.insert(to, elements.removeAt(from));
    times.insert(to, times.removeAt(from));
    return _with(elements, times);
  }

  /// Sets when the element at [index] starts (`null` to clear it), then
  /// puts the timed elements in time order (which can change which DA
  /// count).
  DaRoutine withElementTimeAt(int index, Duration? time) {
    final times = [...this.times]..[index] = time;
    final order = timeOrder(times);
    return _with(reorderBy(elements, order), reorderBy(times, order));
  }

  /// Clears every time; the order is kept.
  DaRoutine withTimesCleared() =>
      _with(elements, List.filled(elements.length, null));

  /// Removes all elements but keeps the ruleset.
  DaRoutine cleared() => DaRoutine(rulesetId: rulesetId);

  @override
  bool operator ==(Object other) =>
      other is DaRoutine &&
      other.rulesetId == rulesetId &&
      listEqual(other.elements, elements) &&
      listEqual(other.times, times);

  @override
  int get hashCode =>
      Object.hash(rulesetId, Object.hashAll(elements), Object.hashAll(times));
}
