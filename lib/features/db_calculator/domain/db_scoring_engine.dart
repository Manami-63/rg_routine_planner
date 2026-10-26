import '../../../core/scoring/ruleset.dart';
import '../../../core/scoring/score.dart';
import 'db_routine.dart';
import 'risk.dart';

/// Caveats attached to a result. The UI decides how to word them.
enum DbScoreNotice {
  /// Values come from a ruleset that is not verified against official rules.
  unofficialRuleset,

  /// No rule checks (limits, repetitions, requirements) were applied.
  rulesNotValidated,
}

class DbScoreResult {
  const DbScoreResult({
    required this.bodySubtotal,
    required this.riskSubtotal,
    required this.elementCount,
    required this.riskCount,
    required this.ruleset,
    required this.notices,
  });

  /// Total from body difficulty elements.
  final Score bodySubtotal;

  /// Total from risks.
  final Score riskSubtotal;

  final int elementCount;
  final int riskCount;
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

  DbScoreResult calculate(DbRoutine routine);
}

/// Adds up listed values and nothing else.
///
/// It deliberately applies no competition rules (no caps, minimums or
/// repetition checks), because those must come from verified official
/// sources, not from guesses. Results are always marked provisional.
class ProvisionalDbScoringEngine implements DbScoringEngine {
  const ProvisionalDbScoringEngine({required this.ruleset});

  @override
  final RulesetVersion ruleset;

  /// Placeholder valuation: the rotation option's value plus each
  /// criterion's value. This additive structure is an assumption to be
  /// verified against the official rules before any ruleset is marked
  /// official.
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
  DbScoreResult calculate(DbRoutine routine) {
    _checkRuleset(routine.rulesetId, 'Routine');
    for (final element in routine.elements) {
      _checkRuleset(element.rulesetId, 'Element ${element.id}');
    }

    final bodySubtotal = routine.elements.fold(
      Score.zero,
      (sum, element) => sum + element.value,
    );
    final riskSubtotal = routine.risks.fold(
      Score.zero,
      (sum, risk) => sum + riskValue(risk),
    );

    return DbScoreResult(
      bodySubtotal: bodySubtotal,
      riskSubtotal: riskSubtotal,
      elementCount: routine.elements.length,
      riskCount: routine.risks.length,
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
