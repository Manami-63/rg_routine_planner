import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';

import '../test_data.dart';

void main() {
  group('DbRoutine', () {
    final empty = DbRoutine(rulesetId: 'test-v1');

    test('adding returns a new routine and leaves the original unchanged', () {
      final updated = empty.withElementAdded(testJump);

      expect(updated.elements, [testJump]);
      expect(empty.elements, isEmpty);
    });

    test('allows the same element more than once', () {
      final routine = empty
          .withElementAdded(testJump)
          .withElementAdded(testJump);

      expect(routine.elements, [testJump, testJump]);
    });

    test('removes only the element at the given position', () {
      final routine = empty
          .withElementAdded(testJump)
          .withElementAdded(testBalance)
          .withElementAdded(testJump)
          .withElementRemovedAt(0);

      expect(routine.elements, [testBalance, testJump]);
    });

    test('keeps options with their element when removing', () {
      const flat = DbElementOptions(flatFoot: true);
      final routine = empty
          .withElementAdded(testJump)
          .withElementAdded(testBalance, flat)
          .withElementRemovedAt(0);

      expect(routine.elements, [testBalance]);
      expect(routine.elementOptions, [flat]);
    });

    test('new elements get default options; options can be changed', () {
      const manual = DbElementOptions(manualValue: Score.hundredths(50));
      final routine = empty
          .withElementAdded(testJump)
          .withElementAdded(testBalance)
          .withElementOptionsAt(1, manual);

      expect(routine.elementOptions, [DbElementOptions.none, manual]);
    });

    test('options must match the elements', () {
      expect(
        () => DbRoutine(
          rulesetId: 'test-v1',
          elements: const [testJump],
          elementOptions: const [],
        ),
        throwsArgumentError,
      );
    });

    test('adds and removes risks by position', () {
      final twoRot = RiskElement(rotation: testTwoRotations);
      final threeRot = RiskElement(rotation: testThreeRotations);
      final routine = empty
          .withRiskAdded(twoRot)
          .withRiskAdded(threeRot)
          .withRiskRemovedAt(0);

      expect(routine.risks, [threeRot]);
      expect(routine.isEmpty, isFalse);
    });

    test('adding a risk keeps elements and vice versa', () {
      final risk = RiskElement(rotation: testTwoRotations);
      final routine = empty.withElementAdded(testJump).withRiskAdded(risk);

      expect(routine.elements, [testJump]);
      expect(routine.risks, [risk]);
    });

    test('clearing removes elements and risks but keeps the ruleset', () {
      final routine = empty
          .withElementAdded(testJump)
          .withRiskAdded(RiskElement(rotation: testTwoRotations))
          .cleared();

      expect(routine.isEmpty, isTrue);
      expect(routine.rulesetId, 'test-v1');
    });

    test('element list cannot be mutated from outside', () {
      expect(() => empty.elements.add(testJump), throwsUnsupportedError);
    });

    test('has value equality', () {
      expect(
        empty.withElementAdded(testJump),
        DbRoutine(rulesetId: 'test-v1', elements: [testJump]),
      );
    });
  });
}
