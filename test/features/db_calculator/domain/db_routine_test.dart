import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';

import '../test_data.dart';

void main() {
  group('DbRoutine', () {
    final empty = DbRoutine(name: 'Hoop', rulesetId: 'test-v1');

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

    test('clearing removes elements but keeps name and ruleset', () {
      final routine = empty.withElementAdded(testJump).cleared();

      expect(routine.isEmpty, isTrue);
      expect(routine.name, 'Hoop');
      expect(routine.rulesetId, 'test-v1');
    });

    test('rename keeps elements', () {
      final routine = empty.withElementAdded(testJump).rename('Ball');

      expect(routine.name, 'Ball');
      expect(routine.elements, [testJump]);
    });

    test('element list cannot be mutated from outside', () {
      expect(() => empty.elements.add(testJump), throwsUnsupportedError);
    });

    test('has value equality', () {
      expect(
        empty.withElementAdded(testJump),
        DbRoutine(name: 'Hoop', rulesetId: 'test-v1', elements: [testJump]),
      );
    });
  });
}
