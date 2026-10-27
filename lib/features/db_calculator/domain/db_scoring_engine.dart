import '../../../core/scoring/ruleset.dart';
import '../../../core/scoring/score.dart';
import 'db_counting.dart';
import 'db_routine.dart';
import 'risk.dart';

/// Caveats attached to a result. The UI decides how to word them.
enum DbScoreNotice {
  /// Values come from a ruleset that is not verified against official rules.
  unofficialRuleset,

  /// No rule checks (repetitions, requirements, ...) were applied, other
  /// than the level's count limits.
  rulesNotValidated,
}

class DbScoreResult {
  const DbScoreResult({
    required this.bodySubtotal,
    required this.riskSubtotal,
    required this.elementCount,
    required this.riskCount,
    required this.counting,
    required this.countLimitsApplied,
    required this.ruleset,
    required this.notices,
  });

  /// Total from the counted body difficulty elements.
  final Score bodySubtotal;

  /// Total from the counted risks.
  final Score riskSubtotal;

  /// All elements and risks in the routine, counted or not.
  final int elementCount;
  final int riskCount;

  /// Which elements and risks count towards the subtotals.
  final DbCounting counting;

  /// Whether a level limited what counts.
  final bool countLimitsApplied;

  int get countedElementCount => counting.countedElements.length;
  int get countedRiskCount => counting.countedRisks.length;
  final RulesetVersion ruleset;
  final Set<DbScoreNotice> notices;

  Score get subtotal => bodySubtotal + riskSubtotal;
}

/// Calculates a DB score for a routine under one specific ruleset.
///
/// The UI only depends on this interface. A verified implementation of
/// official rules can be added later as another class and swapped in via
/// `dbScoringEngineProvider` without touching any widget. Which components
/// count towards DB, and how each is valued, is the engine's decision.
abstract interface class DbScoringEngine {
  RulesetVersion get ruleset;

  /// The value of a single risk, e.g. for previewing it before adding.
  Score riskValue(RiskElement risk);

  /// Calculates the subtotal of what counts under [limits] (the level's
  /// maximums). Elements beyond them stay in the routine but add nothing.
  DbScoreResult calculate(
    DbRoutine routine, {
    DbCountLimits limits = DbCountLimits.none,
  });
}

/// Adds up the values of what counts and nothing else.
///
/// Apart from the level's count limits (see [DbCounting]), it deliberately
/// applies no competition rules (no repetition or requirement checks),
/// because those must come from verified official sources, not from
/// guesses. Results are always marked provisional.
class ProvisionalDbScoringEngine implements DbScoringEngine {
  const ProvisionalDbScoringEngine({required this.ruleset});

  @override
  final RulesetVersion ruleset;

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
    for (final element in routine.elements) {
      _checkRuleset(element.rulesetId, 'Element ${element.id}');
    }

    // Valued up front so uncounted risks are still checked for the ruleset.
    final riskValues = [for (final risk in routine.risks) riskValue(risk)];

    final counting = DbCounting.select(routine, limits);
    final bodySubtotal = counting.countedElements.fold(
      Score.zero,
      (sum, i) => sum + routine.elements[i].value,
    );
    final riskSubtotal = counting.countedRisks.fold(
      Score.zero,
      (sum, i) => sum + riskValues[i],
    );

    return DbScoreResult(
      bodySubtotal: bodySubtotal,
      riskSubtotal: riskSubtotal,
      elementCount: routine.elements.length,
      riskCount: routine.risks.length,
      counting: counting,
      countLimitsApplied: limits.isSet,
      ruleset: ruleset,
      notices: {
        if (!ruleset.isOfficial) DbScoreNotice.unofficialRuleset,
        DbScoreNotice.rulesNotValidated,
      },
    );
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
