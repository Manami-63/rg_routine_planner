import '../../../core/utils/list_equality.dart';
import 'db_element.dart';
import 'risk.dart';

/// The DB part of a routine: body difficulty elements and risks.
///
/// Name, level and identity belong to the enclosing `Routine`, so a future
/// DA part can sit alongside this one. Every change returns a new instance.
class DbRoutine {
  DbRoutine({
    required this.rulesetId,
    List<DbElement> elements = const [],
    List<RiskElement> risks = const [],
  }) : elements = List.unmodifiable(elements),
       risks = List.unmodifiable(risks);

  /// The [RulesetVersion.id] this content is planned against.
  final String rulesetId;

  /// Body difficulty elements in performance order. The same element may
  /// appear twice.
  final List<DbElement> elements;

  /// Risks in performance order.
  final List<RiskElement> risks;

  bool get isEmpty => elements.isEmpty && risks.isEmpty;

  DbRoutine _copyWith({List<DbElement>? elements, List<RiskElement>? risks}) =>
      DbRoutine(
        rulesetId: rulesetId,
        elements: elements ?? this.elements,
        risks: risks ?? this.risks,
      );

  DbRoutine withElementAdded(DbElement element) =>
      _copyWith(elements: [...elements, element]);

  /// Removes by position rather than by id, because a routine can contain
  /// the same element more than once.
  DbRoutine withElementRemovedAt(int index) =>
      _copyWith(elements: [...elements]..removeAt(index));

  DbRoutine withRiskAdded(RiskElement risk) =>
      _copyWith(risks: [...risks, risk]);

  DbRoutine withRiskRemovedAt(int index) =>
      _copyWith(risks: [...risks]..removeAt(index));

  /// Removes all elements and risks but keeps the ruleset.
  DbRoutine cleared() => DbRoutine(rulesetId: rulesetId);

  @override
  bool operator ==(Object other) =>
      other is DbRoutine &&
      other.rulesetId == rulesetId &&
      listEqual(other.elements, elements) &&
      listEqual(other.risks, risks);

  @override
  int get hashCode =>
      Object.hash(rulesetId, Object.hashAll(elements), Object.hashAll(risks));
}
