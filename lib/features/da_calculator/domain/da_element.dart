import '../../../core/scoring/score.dart';
import '../../../core/utils/list_equality.dart';
import 'da_base.dart';
import 'da_criterion.dart';

/// One DA the gymnast plans to perform: a base, an optional 2nd base, and
/// the criteria performed.
///
/// The model only records what was chosen. Whether it is a valid DA and
/// what it is worth is decided by the scoring engine.
class DaElement {
  DaElement({
    required this.base,
    this.secondBase,
    Set<DaCriterion> criteria = const {},
    this.preAcrobatic = false,
    this.manualValue,
  }) : criteria = Set.unmodifiable(criteria);

  final DaBase base;

  /// A base performed right after a "catch from a high throw" [base], as
  /// one DA (#5.1.3.2). `null` for a DA with 1 base.
  final DaBase? secondBase;

  final Set<DaCriterion> criteria;

  /// The "rotation" criterion is a pre-acrobatic element (#5.4.7).
  final bool preAcrobatic;

  /// A value entered by the user, replacing the calculated value and the
  /// validity checks (e.g. a level with other DA rules). `null` when not
  /// set.
  final Score? manualValue;

  bool get isCustom => base.isCustom;

  bool get isPending => base.isPending;

  bool get usesPreAcrobatic =>
      preAcrobatic && criteria.contains(DaCriterion.rotation);

  /// Short summary, e.g. "High throw + Large roll".
  String get name => [base.name, ?secondBase?.name].join(' + ');

  /// The criteria in a few words, e.g. "Outside visual field, Rotation".
  String get criteriaSummary => [
    for (final criterion in DaCriterion.values)
      if (criteria.contains(criterion))
        criterion == DaCriterion.rotation && preAcrobatic
            ? 'Rotation (pre-acrobatic)'
            : criterion.shortLabel,
  ].join(', ');

  /// Whether [other] is the same combination of base(s) and criteria, i.e.
  /// an identical repetition (#5.6.2). Custom DA are never identical.
  bool isIdenticalTo(DaElement other) =>
      !isCustom &&
      base.id == other.base.id &&
      secondBase?.id == other.secondBase?.id &&
      setEqual(criteria, other.criteria);

  @override
  bool operator ==(Object other) =>
      other is DaElement &&
      other.base == base &&
      other.secondBase == secondBase &&
      setEqual(other.criteria, criteria) &&
      other.preAcrobatic == preAcrobatic &&
      other.manualValue == manualValue;

  @override
  int get hashCode => Object.hash(
    base,
    secondBase,
    Object.hashAllUnordered(criteria),
    preAcrobatic,
    manualValue,
  );

  @override
  String toString() => 'DaElement($name: $criteriaSummary)';
}
