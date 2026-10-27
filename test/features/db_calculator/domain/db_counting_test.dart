import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_counting.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';

import '../test_data.dart';

void main() {
  DbRoutine routineOf({List<DbElement> elements = const [], int risks = 0}) =>
      DbRoutine(
        rulesetId: 'test-v1',
        elements: elements,
        risks: [
          for (var i = 0; i < risks; i++)
            RiskElement(rotation: testTwoRotations),
        ],
      );

  test('without limits everything counts', () {
    final counting = DbCounting.select(
      routineOf(elements: const [testJump, testBalance], risks: 2),
      DbCountLimits.none,
    );

    expect(counting.countedElements, {0, 1});
    expect(counting.countedRisks, {0, 1});
  });

  test('the highest-valued elements count', () {
    // Values: rotation 0.10, jump 0.30, balance 0.20, rotation 0.10.
    final counting = DbCounting.select(
      routineOf(
        elements: const [testRotation, testJump, testBalance, testRotation],
      ),
      const DbCountLimits(maxElements: 2),
    );

    expect(counting.countedElements, {1, 2});
    expect(counting.isElementCounted(0), isFalse);
  });

  test('an earlier element wins a tie', () {
    final counting = DbCounting.select(
      routineOf(elements: const [testJump, testJump, testJump]),
      const DbCountLimits(maxElements: 2),
    );

    expect(counting.countedElements, {0, 1});
  });

  test('the first risks count', () {
    final counting = DbCounting.select(
      routineOf(risks: 4),
      const DbCountLimits(maxRisks: 3),
    );

    expect(counting.countedRisks, {0, 1, 2});
    expect(counting.isRiskCounted(3), isFalse);
  });

  test('a maximum of zero counts nothing', () {
    final counting = DbCounting.select(
      routineOf(elements: const [testJump], risks: 1),
      const DbCountLimits(maxElements: 0, maxRisks: 0),
    );

    expect(counting.countedElements, isEmpty);
    expect(counting.countedRisks, isEmpty);
  });

  test('fewer than the maximum all count', () {
    final counting = DbCounting.select(
      routineOf(elements: const [testJump], risks: 1),
      const DbCountLimits(maxElements: 6, maxRisks: 3),
    );

    expect(counting.countedElements, {0});
    expect(counting.countedRisks, {0});
  });
}
