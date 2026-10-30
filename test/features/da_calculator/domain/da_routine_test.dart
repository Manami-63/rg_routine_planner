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

  test('times move with their element and set the order', () {
    final routine = routineOf([roll, throwDa, catchDa])
        .withElementTimeAt(2, const Duration(seconds: 4))
        .withElementTimeAt(0, const Duration(seconds: 12));

    expect(routine.elements, [catchDa, throwDa, roll]);
    expect(routine.times, [
      const Duration(seconds: 4),
      null,
      const Duration(seconds: 12),
    ]);
    // Replacing (editing) a DA keeps its time.
    expect(routine.withElementReplacedAt(0, roll).times, routine.times);
    expect(routine.withElementMoved(0, 1).times, [
      null,
      const Duration(seconds: 4),
      const Duration(seconds: 12),
    ]);
    expect(routine.withElementRemovedAt(0).times.first, isNull);
    expect(routine.withTimesCleared().times, [null, null, null]);
    expect(routine.withTimesCleared(), isNot(routine));
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
