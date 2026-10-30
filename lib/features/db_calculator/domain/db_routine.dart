import '../../../core/utils/list_equality.dart';
import '../../../core/utils/time_order.dart';
import 'db_element.dart';
import 'db_element_options.dart';
import 'risk.dart';

/// The DB part of a routine: body difficulty elements and risks.
///
/// Name, level and identity belong to the enclosing `Routine`, so a future
/// DA part can sit alongside this one. Every change returns a new instance.
class DbRoutine {
  /// [elementOptions] and [elementTimes] match [elements] by position, and
  /// [riskTimes] matches [risks]; when omitted, every element has the
  /// default options and nothing has a time.
  DbRoutine({
    required this.rulesetId,
    List<DbElement> elements = const [],
    List<DbElementOptions>? elementOptions,
    List<Duration?>? elementTimes,
    List<RiskElement> risks = const [],
    List<Duration?>? riskTimes,
  }) : elements = List.unmodifiable(elements),
       elementOptions = List.unmodifiable(
         elementOptions ?? List.filled(elements.length, DbElementOptions.none),
       ),
       elementTimes = List.unmodifiable(
         elementTimes ?? List<Duration?>.filled(elements.length, null),
       ),
       risks = List.unmodifiable(risks),
       riskTimes = List.unmodifiable(
         riskTimes ?? List<Duration?>.filled(risks.length, null),
       ) {
    if (this.elementOptions.length != this.elements.length) {
      throw ArgumentError('elementOptions must match elements');
    }
    if (this.elementTimes.length != this.elements.length) {
      throw ArgumentError('elementTimes must match elements');
    }
    if (this.riskTimes.length != this.risks.length) {
      throw ArgumentError('riskTimes must match risks');
    }
  }

  /// The [RulesetVersion.id] this content is planned against.
  final String rulesetId;

  /// Body difficulty elements in performance order. The same element may
  /// appear twice.
  final List<DbElement> elements;

  /// How each element in [elements] is performed (same positions).
  final List<DbElementOptions> elementOptions;

  /// When each element in [elements] starts in the music (same
  /// positions), or `null` when not marked.
  final List<Duration?> elementTimes;

  /// Risks in performance order.
  final List<RiskElement> risks;

  /// When each risk in [risks] starts in the music, or `null`.
  final List<Duration?> riskTimes;

  bool get isEmpty => elements.isEmpty && risks.isEmpty;

  DbRoutine _copyWith({
    List<DbElement>? elements,
    List<DbElementOptions>? elementOptions,
    List<Duration?>? elementTimes,
    List<RiskElement>? risks,
    List<Duration?>? riskTimes,
  }) => DbRoutine(
    rulesetId: rulesetId,
    elements: elements ?? this.elements,
    elementOptions: elementOptions ?? this.elementOptions,
    elementTimes: elementTimes ?? this.elementTimes,
    risks: risks ?? this.risks,
    riskTimes: riskTimes ?? this.riskTimes,
  );

  DbRoutine withElementAdded(
    DbElement element, [
    DbElementOptions options = DbElementOptions.none,
  ]) => _copyWith(
    elements: [...elements, element],
    elementOptions: [...elementOptions, options],
    elementTimes: [...elementTimes, null],
  );

  /// Removes by position rather than by id, because a routine can contain
  /// the same element more than once.
  DbRoutine withElementRemovedAt(int index) => _copyWith(
    elements: [...elements]..removeAt(index),
    elementOptions: [...elementOptions]..removeAt(index),
    elementTimes: [...elementTimes]..removeAt(index),
  );

  /// Moves the element at [from] (with its options and time) so it ends up
  /// at position [to].
  DbRoutine withElementMoved(int from, int to) => _copyWith(
    elements: _moved(elements, from, to),
    elementOptions: _moved(elementOptions, from, to),
    elementTimes: _moved(elementTimes, from, to),
  );

  DbRoutine withElementOptionsAt(int index, DbElementOptions options) =>
      _copyWith(elementOptions: [...elementOptions]..[index] = options);

  /// Sets when the element at [index] starts (`null` to clear it), then
  /// puts the timed elements in time order.
  DbRoutine withElementTimeAt(int index, Duration? time) {
    final times = [...elementTimes]..[index] = time;
    final order = timeOrder(times);
    return _copyWith(
      elements: reorderBy(elements, order),
      elementOptions: reorderBy(elementOptions, order),
      elementTimes: reorderBy(times, order),
    );
  }

  DbRoutine withRiskAdded(RiskElement risk) =>
      _copyWith(risks: [...risks, risk], riskTimes: [...riskTimes, null]);

  DbRoutine withRiskRemovedAt(int index) => _copyWith(
    risks: [...risks]..removeAt(index),
    riskTimes: [...riskTimes]..removeAt(index),
  );

  /// Moves the risk at [from] (with its time) so it ends up at position
  /// [to].
  DbRoutine withRiskMoved(int from, int to) => _copyWith(
    risks: _moved(risks, from, to),
    riskTimes: _moved(riskTimes, from, to),
  );

  /// Sets when the risk at [index] starts (`null` to clear it), then puts
  /// the timed risks in time order (which can change which risks count).
  DbRoutine withRiskTimeAt(int index, Duration? time) {
    final times = [...riskTimes]..[index] = time;
    final order = timeOrder(times);
    return _copyWith(
      risks: reorderBy(risks, order),
      riskTimes: reorderBy(times, order),
    );
  }

  /// Clears every element and risk time; the order is kept.
  DbRoutine withTimesCleared() => _copyWith(
    elementTimes: List.filled(elements.length, null),
    riskTimes: List.filled(risks.length, null),
  );

  static List<T> _moved<T>(List<T> items, int from, int to) {
    final moved = [...items];
    moved.insert(to, moved.removeAt(from));
    return moved;
  }

  /// Removes all elements and risks but keeps the ruleset.
  DbRoutine cleared() => DbRoutine(rulesetId: rulesetId);

  @override
  bool operator ==(Object other) =>
      other is DbRoutine &&
      other.rulesetId == rulesetId &&
      listEqual(other.elements, elements) &&
      listEqual(other.elementOptions, elementOptions) &&
      listEqual(other.elementTimes, elementTimes) &&
      listEqual(other.risks, risks) &&
      listEqual(other.riskTimes, riskTimes);

  @override
  int get hashCode => Object.hash(
    rulesetId,
    Object.hashAll(elements),
    Object.hashAll(elementOptions),
    Object.hashAll(elementTimes),
    Object.hashAll(risks),
    Object.hashAll(riskTimes),
  );
}
