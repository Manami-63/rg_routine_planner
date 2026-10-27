import '../../../core/scoring/ruleset.dart';
import '../../../core/scoring/score.dart';
import 'db_counting.dart';
import 'db_element.dart';
import 'db_element_options.dart';
import 'db_routine.dart';
import 'risk.dart';

/// Caveats attached to a result. The UI decides how to word them.
enum DbScoreNotice {
  /// Values come from a ruleset that is not verified against official rules.
  unofficialRuleset,

  /// Only some rules (count limits, repetitions) were applied; others
  /// (e.g. apparatus technical elements, risk repetitions) were not.
  rulesNotValidated,
}

class DbScoreResult {
  const DbScoreResult({
    required this.bodySubtotal,
    required this.riskSubtotal,
    required this.elementCount,
    required this.repeatedElements,
    required this.dbPerElement,
    required this.riskCount,
    required this.elementValues,
    required this.counting,
    required this.countLimitsApplied,
    required this.ruleset,
    required this.notices,
  });

  /// Total from the counted body difficulty elements.
  final Score bodySubtotal;

  /// Total from the counted risks.
  final Score riskSubtotal;

  /// The valid DB in the routine, counted or not: each element of a series
  /// is 1 DB, and repetitions are left out.
  final int elementCount;

  /// All risks in the routine, counted or not.
  final int riskCount;

  /// Positions of elements that repeat an earlier one and are therefore
  /// not valid (#2.4.2), unless the user set a manual value.
  final Set<int> repeatedElements;

  /// How many DB each element stands for: its series length, or 0 for a
  /// repetition.
  final List<int> dbPerElement;

  /// The value of each element in the routine (same positions), including
  /// its options. For a series, the value of each of its DB.
  final List<Score> elementValues;

  /// Which elements and risks count towards the subtotals.
  final DbCounting counting;

  /// Whether a level limited what counts.
  final bool countLimitsApplied;

  int get countedElementCount => counting.countedDbCount;
  int get countedRiskCount => counting.countedRisks.length;
  final RulesetVersion ruleset;
  final Set<DbScoreNotice> notices;

  Score get subtotal => bodySubtotal + riskSubtotal;
}

/// How many identical DB an element of a routine stands for: its series
/// length when the element can be performed in series, otherwise 1.
int seriesLengthOf(DbElement element, DbElementOptions options) =>
    element.canBeInSeries ? options.seriesCount : 1;

/// Calculates a DB score for a routine under one specific ruleset.
///
/// The UI only depends on this interface. A verified implementation of
/// official rules can be added later as another class and swapped in via
/// `dbScoringEngineProvider` without touching any widget. Which components
/// count towards DB, and how each is valued, is the engine's decision.
abstract interface class DbScoringEngine {
  RulesetVersion get ruleset;

  /// The value of one DB performed with [options], e.g. on flat foot.
  Score elementValue(DbElement element, DbElementOptions options);

  /// The value of a single risk, e.g. for previewing it before adding.
  Score riskValue(RiskElement risk);

  /// Calculates the subtotal of what counts under [limits] (the level's
  /// maximums). Elements beyond them, and repetitions, stay in the routine
  /// but add nothing.
  DbScoreResult calculate(
    DbRoutine routine, {
    DbCountLimits limits = DbCountLimits.none,
  });
}

/// Adds up the values of what counts.
///
/// Applies the level's count limits (see [DbCounting]) and the repetition
/// and series rules of the FIG Code of Points; no other validity rules.
/// Results are always marked provisional.
class ProvisionalDbScoringEngine implements DbScoringEngine {
  const ProvisionalDbScoringEngine({required this.ruleset});

  @override
  final RulesetVersion ruleset;

  // FIG Code of Points 2025-2028.
  /// #10.3: a balance on flat foot is worth 0.10 less than on relevé.
  static const flatFootReduction = Score.hundredths(10);

  /// #10.9.2: "slow turn" adds 0.20 on relevé, 0.10 on flat foot.
  static const slowTurnOnReleve = Score.hundredths(20);
  static const slowTurnOnFlatFoot = Score.hundredths(10);

  /// A manual value replaces everything else. Otherwise options only apply
  /// to elements that allow them; additional rotations are worth the
  /// element's `extraRotationValue` each (#12.2.5-12.2.8).
  @override
  Score elementValue(DbElement element, DbElementOptions options) {
    _checkRuleset(element.rulesetId, 'Element ${element.id}');
    if (options.manualValue case final manual?) return manual;

    var value = element.value;
    final flatFoot = options.flatFoot && element.canBeOnFlatFoot;
    if (flatFoot) value -= flatFootReduction;
    if (options.slowTurn && element.canSlowTurn) {
      value += flatFoot ? slowTurnOnFlatFoot : slowTurnOnReleve;
    }
    if (element.extraRotationValue case final perRotation?) {
      value += perRotation * options.extraRotations;
    }
    return value;
  }

  /// The rotation option's value plus each criterion's value. This additive
  /// structure follows the FIG Code of Points 2025-2028 (#4.2, #4.8-4.10:
  /// base 0.20 for 2 rotations, + the value of each criterion). Validity
  /// rules (e.g. repeated rotation groups) are not checked.
  @override
  Score riskValue(RiskElement risk) {
    _checkRuleset(risk.rotation.rulesetId, 'Rotation ${risk.rotation.id}');
    for (final criterion in risk.criteria) {
      _checkRuleset(criterion.rulesetId, 'Criterion ${criterion.id}');
    }
    return risk.criteria.fold(
      risk.rotation.value,
      (sum, criterion) => sum + criterion.value,
    );
  }

  @override
  DbScoreResult calculate(
    DbRoutine routine, {
    DbCountLimits limits = DbCountLimits.none,
  }) {
    _checkRuleset(routine.rulesetId, 'Routine');

    // Valued up front so uncounted items are still checked for the ruleset.
    final elementValues = [
      for (final (i, element) in routine.elements.indexed)
        elementValue(element, routine.elementOptions[i]),
    ];
    final riskValues = [for (final risk in routine.risks) riskValue(risk)];

    final repeated = repetitionsIn(routine);
    final dbPerElement = [
      for (final (i, element) in routine.elements.indexed)
        repeated.contains(i)
            ? 0
            : seriesLengthOf(element, routine.elementOptions[i]),
    ];

    final counting = DbCounting.select(
      elementValues: elementValues,
      dbPerElement: dbPerElement,
      riskCount: routine.risks.length,
      limits: limits,
    );
    var bodySubtotal = Score.zero;
    for (final (i, counted) in counting.countedPerElement.indexed) {
      bodySubtotal += elementValues[i] * counted;
    }
    final riskSubtotal = counting.countedRisks.fold(
      Score.zero,
      (sum, i) => sum + riskValues[i],
    );

    return DbScoreResult(
      bodySubtotal: bodySubtotal,
      riskSubtotal: riskSubtotal,
      elementCount: dbPerElement.fold(0, (sum, n) => sum + n),
      repeatedElements: Set.unmodifiable(repeated),
      dbPerElement: List.unmodifiable(dbPerElement),
      riskCount: routine.risks.length,
      elementValues: List.unmodifiable(elementValues),
      counting: counting,
      countLimitsApplied: limits.isSet,
      ruleset: ruleset,
      notices: {
        if (!ruleset.isOfficial) DbScoreNotice.unofficialRuleset,
        DbScoreNotice.rulesNotValidated,
      },
    );
  }

  /// Elements that repeat an earlier element (same box), which are not
  /// valid (#2.4.2, #8.9, #10.9.6). A series is one element, so it is not
  /// a repetition. Custom elements are all different, and a manual value
  /// makes a repetition count (for levels that allow it).
  static Set<int> repetitionsIn(DbRoutine routine) {
    final seen = <String>{};
    return {
      for (final (i, element) in routine.elements.indexed)
        if (!element.isCustom &&
            !seen.add(element.id) &&
            routine.elementOptions[i].manualValue == null)
          i,
    };
  }

  void _checkRuleset(String rulesetId, String what) {
    if (rulesetId != ruleset.id) {
      throw ArgumentError.value(
        rulesetId,
        'rulesetId',
        '$what does not match engine ruleset ${ruleset.id}',
      );
    }
  }
}
