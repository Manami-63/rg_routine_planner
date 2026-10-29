import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_routine.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_scoring_engine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_scoring_engine.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/routine_score.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/test_data.dart';

void main() {
  const dbEngine = ProvisionalDbScoringEngine(ruleset: testRuleset);
  const daEngine = ProvisionalDaScoringEngine(ruleset: testRuleset);
  const twoCriteria = {DaCriterion.outsideVisualField, DaCriterion.db};

  Routine routine({Apparatus? apparatus, CompetitionLevel? level}) => Routine(
    id: 'r1',
    name: 'Hoop',
    apparatus: apparatus,
    level: level,
    // 0.30 + 0.20 DB.
    db: DbRoutine(
      rulesetId: testRuleset.id,
      elements: const [testJump, testBalance],
    ),
    // 0.30 + 0.20 DA.
    da: DaRoutine(
      rulesetId: testRuleset.id,
      elements: [
        DaElement(base: testRoll, criteria: twoCriteria),
        DaElement(base: testThrow, criteria: twoCriteria),
      ],
    ),
    createdAt: DateTime.utc(2026, 10, 29),
    updatedAt: DateTime.utc(2026, 10, 29),
  );

  RoutineScore score(Routine routine) =>
      RoutineScore.of(routine, dbEngine: dbEngine, daEngine: daEngine);

  test('the total is DB plus DA', () {
    final result = score(routine(apparatus: Apparatus.hoop));

    expect(result.db.subtotal, const Score.hundredths(50));
    expect(result.da.subtotal, const Score.hundredths(50));
    expect(result.total, const Score.hundredths(100));
    expect(result.isProvisional, isTrue);
  });

  test('applies the level maximums for the apparatus', () {
    const level = CompetitionLevel.custom(
      LevelRequirements(db: CountLimit(max: 1), da: CountLimit(max: 1)),
    );

    final result = score(routine(apparatus: Apparatus.hoop, level: level));

    // The highest DB (0.30) and the first DA (0.30) count.
    expect(result.total, const Score.hundredths(60));
  });

  test('freehand counts no DA', () {
    final result = score(routine(apparatus: Apparatus.freehand));

    expect(result.da.subtotal, Score.zero);
    expect(result.total, const Score.hundredths(50));
  });
}
