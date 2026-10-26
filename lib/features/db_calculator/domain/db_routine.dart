import '../../../core/utils/list_equality.dart';
import 'db_element.dart';
import 'risk.dart';

/// An immutable DB routine: a name, body difficulty elements and risks.
///
/// Every change returns a new instance. This keeps state updates
/// predictable in Riverpod and makes the class trivial to serialise when
/// local persistence is added.
class DbRoutine {
  DbRoutine({
    required this.name,
    required this.rulesetId,
    List<DbElement> elements = const [],
    List<RiskElement> risks = const [],
  }) : elements = List.unmodifiable(elements),
       risks = List.unmodifiable(risks);

  final String name;

  /// The [RulesetVersion.id] this routine is planned against.
  final String rulesetId;

  /// Body difficulty elements in performance order. The same element may
  /// appear twice.
  final List<DbElement> elements;

  /// Risks in performance order.
  final List<RiskElement> risks;

  bool get isEmpty => elements.isEmpty && risks.isEmpty;

  DbRoutine _copyWith({
    String? name,
    List<DbElement>? elements,
    List<RiskElement>? risks,
  }) => DbRoutine(
    name: name ?? this.name,
    rulesetId: rulesetId,
    elements: elements ?? this.elements,
    risks: risks ?? this.risks,
  );

  DbRoutine rename(String newName) => _copyWith(name: newName);

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

  /// Removes all elements and risks but keeps the name and ruleset.
  DbRoutine cleared() => DbRoutine(name: name, rulesetId: rulesetId);

  @override
  bool operator ==(Object other) =>
      other is DbRoutine &&
      other.name == name &&
      other.rulesetId == rulesetId &&
      listEqual(other.elements, elements) &&
      listEqual(other.risks, risks);

  @override
  int get hashCode => Object.hash(
    name,
    rulesetId,
    Object.hashAll(elements),
    Object.hashAll(risks),
  );
}
