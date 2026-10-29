import '../../../core/utils/list_equality.dart';
import 'db_element.dart';
import 'db_element_options.dart';
import 'risk.dart';

/// The DB part of a routine: body difficulty elements and risks.
///
/// Name, level and identity belong to the enclosing `Routine`, so a future
/// DA part can sit alongside this one. Every change returns a new instance.
class DbRoutine {
  /// [elementOptions] matches [elements] by position; when omitted, every
  /// element has the default options.
  DbRoutine({
    required this.rulesetId,
    List<DbElement> elements = const [],
    List<DbElementOptions>? elementOptions,
    List<RiskElement> risks = const [],
  }) : elements = List.unmodifiable(elements),
       elementOptions = List.unmodifiable(
         elementOptions ?? List.filled(elements.length, DbElementOptions.none),
       ),
       risks = List.unmodifiable(risks) {
    if (this.elementOptions.length != this.elements.length) {
      throw ArgumentError('elementOptions must match elements');
    }
  }

  /// The [RulesetVersion.id] this content is planned against.
  final String rulesetId;

  /// Body difficulty elements in performance order. The same element may
  /// appear twice.
  final List<DbElement> elements;

  /// How each element in [elements] is performed (same positions).
  final List<DbElementOptions> elementOptions;

  /// Risks in performance order.
  final List<RiskElement> risks;

  bool get isEmpty => elements.isEmpty && risks.isEmpty;

  DbRoutine _copyWith({
    List<DbElement>? elements,
    List<DbElementOptions>? elementOptions,
    List<RiskElement>? risks,
  }) => DbRoutine(
    rulesetId: rulesetId,
    elements: elements ?? this.elements,
    elementOptions: elementOptions ?? this.elementOptions,
    risks: risks ?? this.risks,
  );

  DbRoutine withElementAdded(
    DbElement element, [
    DbElementOptions options = DbElementOptions.none,
  ]) => _copyWith(
    elements: [...elements, element],
    elementOptions: [...elementOptions, options],
  );

  /// Removes by position rather than by id, because a routine can contain
  /// the same element more than once.
  DbRoutine withElementRemovedAt(int index) => _copyWith(
    elements: [...elements]..removeAt(index),
    elementOptions: [...elementOptions]..removeAt(index),
  );

  /// Moves the element at [from] (with its options) so it ends up at
  /// position [to].
  DbRoutine withElementMoved(int from, int to) => _copyWith(
    elements: _moved(elements, from, to),
    elementOptions: _moved(elementOptions, from, to),
  );

  DbRoutine withElementOptionsAt(int index, DbElementOptions options) =>
      _copyWith(elementOptions: [...elementOptions]..[index] = options);

  DbRoutine withRiskAdded(RiskElement risk) =>
      _copyWith(risks: [...risks, risk]);

  DbRoutine withRiskRemovedAt(int index) =>
      _copyWith(risks: [...risks]..removeAt(index));

  /// Moves the risk at [from] so it ends up at position [to].
  DbRoutine withRiskMoved(int from, int to) =>
      _copyWith(risks: _moved(risks, from, to));

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
      listEqual(other.risks, risks);

  @override
  int get hashCode => Object.hash(
    rulesetId,
    Object.hashAll(elements),
    Object.hashAll(elementOptions),
    Object.hashAll(risks),
  );
}
