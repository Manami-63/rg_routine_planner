import '../../../core/scoring/score.dart';
import '../../../core/utils/list_equality.dart';

/// One choice of rotations performed under a throw, e.g. "2 rotations".
///
/// The [label] and [value] come from the ruleset data, so the domain makes
/// no assumption about how many rotations are allowed or what they are
/// worth.
class RiskRotationOption {
  const RiskRotationOption({
    required this.id,
    required this.label,
    required this.rotations,
    required this.value,
    required this.rulesetId,
  });

  final String id;
  final String label;
  final int rotations;
  final Score value;
  final String rulesetId;

  @override
  bool operator ==(Object other) =>
      other is RiskRotationOption &&
      other.id == id &&
      other.label == label &&
      other.rotations == rotations &&
      other.value == value &&
      other.rulesetId == rulesetId;

  @override
  int get hashCode => Object.hash(id, label, rotations, value, rulesetId);
}

/// An additional criterion that can be added to a risk.
class RiskCriterion {
  const RiskCriterion({
    required this.id,
    required this.name,
    required this.value,
    required this.rulesetId,
  });

  final String id;
  final String name;
  final Score value;
  final String rulesetId;

  @override
  bool operator ==(Object other) =>
      other is RiskCriterion &&
      other.id == id &&
      other.name == name &&
      other.value == value &&
      other.rulesetId == rulesetId;

  @override
  int get hashCode => Object.hash(id, name, value, rulesetId);
}

/// A risk the gymnast plans to perform: a rotation option plus any criteria.
///
/// The model only records what was chosen. How it is valued is decided by
/// the scoring engine, because that is a rule, not data.
class RiskElement {
  RiskElement({required this.rotation, List<RiskCriterion> criteria = const []})
    : criteria = List.unmodifiable(criteria);

  final RiskRotationOption rotation;
  final List<RiskCriterion> criteria;

  /// Short human-readable summary, e.g. "2 rotations + Criterion A".
  String get description =>
      [rotation.label, ...criteria.map((c) => c.name)].join(' + ');

  @override
  bool operator ==(Object other) =>
      other is RiskElement &&
      other.rotation == rotation &&
      listEqual(other.criteria, criteria);

  @override
  int get hashCode => Object.hash(rotation, Object.hashAll(criteria));
}

/// The building blocks available for risks under one ruleset.
class RiskCatalogue {
  RiskCatalogue({
    required List<RiskRotationOption> rotationOptions,
    required List<RiskCriterion> criteria,
  }) : rotationOptions = List.unmodifiable(rotationOptions),
       criteria = List.unmodifiable(criteria);

  final List<RiskRotationOption> rotationOptions;
  final List<RiskCriterion> criteria;

  bool get isEmpty => rotationOptions.isEmpty;
}
