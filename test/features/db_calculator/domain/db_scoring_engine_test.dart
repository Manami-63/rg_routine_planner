import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/ruleset.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_scoring_engine.dart';

import '../test_data.dart';

void main() {
  const engine = ProvisionalDbScoringEngine(ruleset: testRuleset);

  DbRoutine routineOf(List<DbElement> elements) =>
      DbRoutine(name: 'Test', rulesetId: 'test-v1', elements: elements);

  group('ProvisionalDbScoringEngine', () {
    test('empty routine has a zero subtotal', () {
      final result = engine.calculate(routineOf([]));

      expect(result.subtotal, Score.zero);
      expect(result.elementCount, 0);
    });

    test('sums element values exactly', () {
      final result = engine.calculate(
        routineOf([testJump, testBalance, testRotation, testJump]),
      );

      // 0.30 + 0.20 + 0.10 + 0.30
      expect(result.subtotal, const Score.hundredths(90));
      expect(result.subtotal.format(), '0.90');
      expect(result.elementCount, 4);
    });

    test('reports the ruleset used', () {
      expect(engine.calculate(routineOf([])).ruleset, testRuleset);
    });

    test('always marks results as not rule-validated', () {
      expect(
        engine.calculate(routineOf([])).notices,
        contains(DbScoreNotice.rulesNotValidated),
      );
    });

    test('flags an unofficial ruleset', () {
      expect(
        engine.calculate(routineOf([])).notices,
        contains(DbScoreNotice.unofficialRuleset),
      );
    });

    test('does not flag an official ruleset as unofficial', () {
      const official = RulesetVersion(
        id: 'test-v1',
        label: 'Official test',
        isOfficial: true,
      );
      const officialEngine = ProvisionalDbScoringEngine(ruleset: official);

      expect(
        officialEngine.calculate(routineOf([])).notices,
        isNot(contains(DbScoreNotice.unofficialRuleset)),
      );
    });

    test('rejects a routine from another ruleset', () {
      final routine = DbRoutine(name: 'Other', rulesetId: 'other');

      expect(() => engine.calculate(routine), throwsArgumentError);
    });

    test('rejects an element from another ruleset', () {
      const foreign = DbElement(
        id: 'foreign',
        name: 'Foreign',
        group: DbElementGroup.jump,
        value: Score.hundredths(10),
        rulesetId: 'other',
      );

      expect(() => engine.calculate(routineOf([foreign])), throwsArgumentError);
    });
  });
}
