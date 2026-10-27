import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../../db_calculator/test_data.dart';

void main() {
  final now = DateTime.utc(2026, 10, 26, 9);
  final routine = Routine.create(id: 'r1', rulesetId: 'test-v1', now: now);

  test('create starts empty with matching timestamps', () {
    expect(routine.name, isEmpty);
    expect(routine.level, isNull);
    expect(routine.apparatus, isNull);
    expect(routine.db.isEmpty, isTrue);
    expect(routine.rulesetId, 'test-v1');
    expect(routine.createdAt, now);
    expect(routine.updatedAt, now);
  });

  test('changes return new routines and keep other fields', () {
    final changed = routine
        .rename('Hoop')
        .withLevel(figSenior)
        .withDb(routine.db.withElementAdded(testJump));

    expect(changed.name, 'Hoop');
    expect(changed.level, figSenior);
    expect(changed.db.elements, [testJump]);
    expect(changed.id, 'r1');
    expect(routine.name, isEmpty);
  });

  test('withLevel(null) removes the level', () {
    expect(routine.withLevel(figJunior).withLevel(null).level, isNull);
  });

  test('apparatus is kept by other changes and can be removed', () {
    final hoop = routine.withApparatus(Apparatus.hoop);

    expect(hoop.rename('A').withLevel(figJunior).apparatus, Apparatus.hoop);
    expect(hoop.withApparatus(null).apparatus, isNull);
    expect(
      hoop.withLevel(figSenior).withApparatus(Apparatus.ball).level,
      figSenior,
    );
  });

  test('withUpdatedAt changes only updatedAt', () {
    final later = now.add(const Duration(minutes: 5));
    final touched = routine.withUpdatedAt(later);

    expect(touched.updatedAt, later);
    expect(touched.createdAt, now);
  });
}
