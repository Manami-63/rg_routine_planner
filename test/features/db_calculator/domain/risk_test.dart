import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';

import '../test_data.dart';

void main() {
  group('RiskElement', () {
    test('describes rotation and criteria', () {
      final risk = RiskElement(
        rotation: testTwoRotations,
        criteria: const [testCriterionA, testCriterionB],
      );

      expect(risk.description, '2 rotations + Criterion A + Criterion B');
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
}
