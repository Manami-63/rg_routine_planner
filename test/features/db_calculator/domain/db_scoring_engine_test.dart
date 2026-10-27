import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/ruleset.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_counting.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_scoring_engine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';

import '../test_data.dart';

void main() {
  const engine = ProvisionalDbScoringEngine(ruleset: testRuleset);

  DbRoutine routineOf(List<DbElement> elements) =>
      DbRoutine(rulesetId: 'test-v1', elements: elements);

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

    test('only counted elements and risks add to the subtotal', () {
      final routine = DbRoutine(
        rulesetId: 'test-v1',
        elements: const [testRotation, testJump, testBalance],
        risks: [
          RiskElement(rotation: testTwoRotations),
          RiskElement(rotation: testThreeRotations),
        ],
      );

      final result = engine.calculate(
        routine,
        limits: const DbCountLimits(maxElements: 2, maxRisks: 1),
      );

      // Highest two DB: 0.30 + 0.20. First risk: 0.20.
      expect(result.bodySubtotal, const Score.hundredths(50));
      expect(result.riskSubtotal, const Score.hundredths(20));
      expect(result.elementCount, 3);
      expect(result.countedElementCount, 2);
      expect(result.riskCount, 2);
      expect(result.countedRiskCount, 1);
      expect(result.countLimitsApplied, isTrue);
    });

    test('without limits nothing is left out', () {
      final result = engine.calculate(routineOf([testJump, testBalance]));

      expect(result.countedElementCount, 2);
      expect(result.countLimitsApplied, isFalse);
    });

    test('rejects an uncounted risk from another ruleset', () {
      const otherRotation = RiskRotationOption(
        id: 'rot-x',
        label: 'Other',
        rotations: 2,
        value: Score.hundredths(10),
        rulesetId: 'other',
      );
      final routine = DbRoutine(
        rulesetId: 'test-v1',
        risks: [RiskElement(rotation: otherRotation)],
      );

      expect(
        () =>
            engine.calculate(routine, limits: const DbCountLimits(maxRisks: 0)),
        throwsArgumentError,
      );
    });

    group('element options', () {
      Score valueOf(DbElement element, DbElementOptions options) =>
          engine.elementValue(element, options);

      test('flat foot reduces a balance by 0.10', () {
        expect(
          valueOf(testBalance, const DbElementOptions(flatFoot: true)),
          const Score.hundredths(10),
        );
      });

      test('slow turn adds 0.20 on relevé and 0.10 on flat foot', () {
        expect(
          valueOf(testBalance, const DbElementOptions(slowTurn: true)),
          const Score.hundredths(40),
        );
        expect(
          valueOf(
            testBalance,
            const DbElementOptions(flatFoot: true, slowTurn: true),
          ),
          const Score.hundredths(20),
        );
      });

      test('additional rotations add the element value each', () {
        expect(
          valueOf(testRotation, const DbElementOptions(extraRotations: 2)),
          const Score.hundredths(30),
        );
      });

      test('options the element does not allow are ignored', () {
        expect(
          valueOf(
            testJump,
            const DbElementOptions(
              flatFoot: true,
              slowTurn: true,
              extraRotations: 3,
            ),
          ),
          testJump.value,
        );
      });

      test('a manual value replaces everything', () {
        expect(
          valueOf(
            testBalance,
            const DbElementOptions(
              flatFoot: true,
              manualValue: Score.hundredths(70),
            ),
          ),
          const Score.hundredths(70),
        );
      });

      test('counting uses the adjusted values', () {
        // Balance 0.20 + slow turn = 0.40 beats the jump (0.30).
        final routine = DbRoutine(
          rulesetId: 'test-v1',
          elements: const [testJump, testBalance],
          elementOptions: const [
            DbElementOptions.none,
            DbElementOptions(slowTurn: true),
          ],
        );

        final result = engine.calculate(
          routine,
          limits: const DbCountLimits(maxElements: 1),
        );

        expect(result.elementValues, const [
          Score.hundredths(30),
          Score.hundredths(40),
        ]);
        expect(result.counting.countedElements, {1});
        expect(result.bodySubtotal, const Score.hundredths(40));
      });
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
      final routine = DbRoutine(rulesetId: 'other');

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

  group('ProvisionalDbScoringEngine risks', () {
    test('risk value is rotation value plus criteria values', () {
      final risk = RiskElement(
        rotation: testTwoRotations,
        criteria: const [testCriterionA, testCriterionB],
      );

      // 0.20 + 0.10 + 0.20
      expect(engine.riskValue(risk), const Score.hundredths(50));
    });

    test('risk without criteria is worth its rotation value', () {
      expect(
        engine.riskValue(RiskElement(rotation: testThreeRotations)),
        const Score.hundredths(30),
      );
    });

    test('reports body and risk subtotals separately', () {
      final routine = DbRoutine(
        rulesetId: 'test-v1',
        elements: const [testJump, testBalance],
        risks: [
          RiskElement(rotation: testTwoRotations),
          RiskElement(rotation: testThreeRotations, criteria: [testCriterionA]),
        ],
      );

      final result = engine.calculate(routine);

      expect(result.bodySubtotal, const Score.hundredths(50));
      expect(result.riskSubtotal, const Score.hundredths(60));
      expect(result.subtotal, const Score.hundredths(110));
      expect(result.riskCount, 2);
      expect(result.elementCount, 2);
    });

    test('rejects a risk rotation from another ruleset', () {
      const foreign = RiskRotationOption(
        id: 'foreign',
        label: 'Foreign',
        rotations: 2,
        value: Score.hundredths(20),
        rulesetId: 'other',
      );

      expect(
        () => engine.riskValue(RiskElement(rotation: foreign)),
        throwsArgumentError,
      );
    });

    test('rejects a risk criterion from another ruleset', () {
      const foreign = RiskCriterion(
        id: 'foreign',
        name: 'Foreign',
        value: Score.hundredths(10),
        rulesetId: 'other',
        phase: RiskPhase.throwing,
      );
      final risk = RiskElement(rotation: testTwoRotations, criteria: [foreign]);

      expect(() => engine.riskValue(risk), throwsArgumentError);
    });
  });
}
