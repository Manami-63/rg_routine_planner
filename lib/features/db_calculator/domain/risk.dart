import '../../../core/scoring/apparatus.dart';
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
  }) : isUnknown = false;

  /// A saved reference whose id is not in the current risk catalogue.
  const RiskRotationOption.unknown({required this.id, required this.rulesetId})
    : label = 'Unknown rotation option',
      rotations = 0,
      value = Score.zero,
      isUnknown = true;

  final String id;
  final String label;
  final int rotations;
  final Score value;
  final String rulesetId;
  final bool isUnknown;

  @override
  bool operator ==(Object other) =>
      other is RiskRotationOption &&
      other.id == id &&
      other.label == label &&
      other.rotations == rotations &&
      other.value == value &&
      other.rulesetId == rulesetId &&
      other.isUnknown == isUnknown;

  @override
  int get hashCode =>
      Object.hash(id, label, rotations, value, rulesetId, isUnknown);
}

/// When a risk criterion is performed: during the throw, the rotations
/// under the flight, or the catch.
enum RiskPhase {
  throwing('Throw'),
  rotations('Rotations'),
  catching('Catch');

  const RiskPhase(this.label);

  final String label;
}

/// An additional criterion that can be added to a risk.
class RiskCriterion {
  const RiskCriterion({
    required this.id,
    required this.name,
    required this.value,
    required this.rulesetId,
    required RiskPhase this.phase,
    this.apparatus = const {},
    this.note,
  }) : isUnknown = false;

  /// A saved reference whose id is not in the current risk catalogue.
  const RiskCriterion.unknown({required this.id, required this.rulesetId})
    : name = 'Unknown criterion',
      value = Score.zero,
      phase = null,
      apparatus = const {},
      note = null,
      isUnknown = true;

  final String id;
  final String name;
  final Score value;
  final String rulesetId;

  /// When it is performed; `null` only for unknown criteria.
  final RiskPhase? phase;

  /// The apparatus it applies to; empty means every apparatus.
  final Set<Apparatus> apparatus;

  /// A condition from the rules shown with it, e.g. "Only valid together
  /// with ...". Not enforced.
  final String? note;

  final bool isUnknown;

  bool appliesTo(Apparatus? routineApparatus) =>
      apparatus.isEmpty ||
      (routineApparatus != null && apparatus.contains(routineApparatus));

  @override
  bool operator ==(Object other) =>
      other is RiskCriterion &&
      other.id == id &&
      other.name == name &&
      other.value == value &&
      other.rulesetId == rulesetId &&
      other.phase == phase &&
      setEqual(other.apparatus, apparatus) &&
      other.note == note &&
      other.isUnknown == isUnknown;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    value,
    rulesetId,
    phase,
    Object.hashAllUnordered(apparatus),
    note,
    isUnknown,
  );
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

  /// Short human-readable summary, e.g. "3 rotations + Catch: Without
  /// hands".
  String get description => [
    rotation.label,
    for (final c in criteria)
      switch (c.phase) {
        RiskPhase.throwing ||
        RiskPhase.catching => '${c.phase!.label}: ${c.name}',
        RiskPhase.rotations || null => c.name,
      },
  ].join(' + ');

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

  /// The criteria of [phase] that apply to a routine with [apparatus], in
  /// catalogue order.
  List<RiskCriterion> criteriaFor(RiskPhase phase, Apparatus? apparatus) => [
    for (final criterion in criteria)
      if (criterion.phase == phase && criterion.appliesTo(apparatus)) criterion,
  ];
}
