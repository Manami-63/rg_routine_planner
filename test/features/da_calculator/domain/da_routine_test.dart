import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_routine.dart';

import '../test_data.dart';

void main() {
  final roll = DaElement(base: testRoll);
  final throwDa = DaElement(base: testThrow);
  final catchDa = DaElement(base: testCatch);

  DaRoutine routineOf(List<DaElement> elements) =>
      DaRoutine(rulesetId: 'test-v1', elements: elements);

  test('moves an element in the performance order', () {
    final routine = routineOf([roll, throwDa, catchDa]);

    expect(routine.withElementMoved(0, 2).elements, [throwDa, catchDa, roll]);
    expect(routine.withElementMoved(2, 0).elements, [catchDa, roll, throwDa]);
  });

  test('replaces, removes and clears by position', () {
    final routine = routineOf([roll, throwDa]);

    expect(routine.withElementReplacedAt(1, catchDa).elements, [roll, catchDa]);
    expect(routine.withElementRemovedAt(0).elements, [throwDa]);
    expect(routine.cleared(), routineOf(const []));
  });

  test('identical means the same bases and criteria', () {
    final a = DaElement(
      base: testRoll,
      criteria: const {DaCriterion.db, DaCriterion.rotation},
    );

    expect(
      a.isIdenticalTo(
        DaElement(
          base: testRoll,
          criteria: const {DaCriterion.rotation, DaCriterion.db},
          preAcrobatic: true,
        ),
      ),
      isTrue,
    );
    expect(
      a.isIdenticalTo(
        DaElement(base: testRoll, criteria: const {DaCriterion.db}),
      ),
      isFalse,
    );
    expect(
      a.isIdenticalTo(
        DaElement(
          base: testCatch,
          secondBase: testRoll,
          criteria: const {DaCriterion.db, DaCriterion.rotation},
        ),
      ),
      isFalse,
    );
  });

  test('criteria are stored as names and unknown names are skipped', () {
    const criteria = {DaCriterion.rotation, DaCriterion.outsideVisualField};

    expect(DaCriterion.formatAll(criteria), 'outsideVisualField,rotation');
    expect(DaCriterion.parseAll('outsideVisualField,rotation'), criteria);
    expect(DaCriterion.parseAll('rotation,retired'), {DaCriterion.rotation});
    expect(DaCriterion.parseAll(''), isEmpty);
  });
}
