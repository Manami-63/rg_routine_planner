import '../../../core/scoring/ruleset.dart';
import '../../../core/scoring/score.dart';
import 'db_routine.dart';

/// Caveats attached to a result. The UI decides how to word them.
enum DbScoreNotice {
  /// Values come from a ruleset that is not verified against official rules.
  unofficialRuleset,

  /// No rule checks (limits, repetitions, requirements) were applied.
  rulesNotValidated,
}

class DbScoreResult {
  const DbScoreResult({
    required this.subtotal,
    required this.elementCount,
    required this.ruleset,
    required this.notices,
  });

  final Score subtotal;
  final int elementCount;
  final RulesetVersion ruleset;
  final Set<DbScoreNotice> notices;
}

/// Calculates a DB score for a routine under one specific ruleset.
///
/// The UI only depends on this interface. A verified implementation of
/// official rules can be added later as another class and swapped in via
/// `dbScoringEngineProvider` without touching any widget.
abstract interface class DbScoringEngine {
  RulesetVersion get ruleset;

  DbScoreResult calculate(DbRoutine routine);
}

/// Adds up the listed value of every element and nothing else.
///
/// It deliberately applies no competition rules (no caps, minimums or
/// repetition checks), because those must come from verified official
/// sources, not from guesses. Results are always marked provisional.
class ProvisionalDbScoringEngine implements DbScoringEngine {
  const ProvisionalDbScoringEngine({required this.ruleset});

  @override
  final RulesetVersion ruleset;

  @override
  DbScoreResult calculate(DbRoutine routine) {
    if (routine.rulesetId != ruleset.id) {
      throw ArgumentError.value(
        routine.rulesetId,
        'routine.rulesetId',
        'Routine does not match engine ruleset ${ruleset.id}',
      );
    }
    for (final element in routine.elements) {
      if (element.rulesetId != ruleset.id) {
        throw ArgumentError.value(
          element.rulesetId,
          'element.rulesetId',
          'Element ${element.id} does not match engine ruleset ${ruleset.id}',
        );
      }
    }

    final subtotal = routine.elements.fold(
      Score.zero,
      (sum, element) => sum + element.value,
    );

    return DbScoreResult(
      subtotal: subtotal,
      elementCount: routine.elements.length,
      ruleset: ruleset,
      notices: {
        if (!ruleset.isOfficial) DbScoreNotice.unofficialRuleset,
        DbScoreNotice.rulesNotValidated,
      },
    );
  }
}
