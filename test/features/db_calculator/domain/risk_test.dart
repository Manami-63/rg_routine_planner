import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';

import '../test_data.dart';

void main() {
  group('RiskElement', () {
    test('describes rotation and criteria', () {
      final risk = RiskElement(
        rotation: testTwoRotations,
        criteria: const [testCriterionA, testCriterionB],
      );

      expect(
        risk.description,
        '2 rotations + Throw: Criterion A + Catch: Criterion B',
      );
    });

    test('describes a risk without criteria', () {
      expect(
        RiskElement(rotation: testThreeRotations).description,
        '3 rotations',
      );
    });

    test('has value equality', () {
      expect(
        RiskElement(rotation: testTwoRotations, criteria: [testCriterionA]),
        RiskElement(rotation: testTwoRotations, criteria: [testCriterionA]),
      );
      expect(
        RiskElement(rotation: testTwoRotations),
        isNot(RiskElement(rotation: testThreeRotations)),
      );
    });

    test('criteria list cannot be mutated from outside', () {
      final risk = RiskElement(rotation: testTwoRotations);

      expect(() => risk.criteria.add(testCriterionA), throwsUnsupportedError);
    });
  });

  group('RiskCatalogue', () {
    test('filters criteria by phase and apparatus', () {
      expect(
        testRiskCatalogue.criteriaFor(RiskPhase.catching, Apparatus.ball),
        [testCriterionB, testBallCriterion],
      );
      expect(
        testRiskCatalogue.criteriaFor(RiskPhase.catching, Apparatus.hoop),
        [testCriterionB],
      );
      expect(testRiskCatalogue.criteriaFor(RiskPhase.throwing, null), [
        testCriterionA,
      ]);
    });

    test('apparatus-specific criteria need a chosen apparatus', () {
      expect(testBallCriterion.appliesTo(null), isFalse);
      expect(testCriterionA.appliesTo(null), isTrue);
    });
  });
}
