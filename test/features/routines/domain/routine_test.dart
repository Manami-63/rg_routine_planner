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
        .withNotes('Music: Bolero')
        .withDb(routine.db.withElementAdded(testJump));

    expect(changed.name, 'Hoop');
    expect(changed.notes, 'Music: Bolero');
    expect(changed.level, figSenior);
    expect(changed.db.elements, [testJump]);
    expect(changed.id, 'r1');
    expect(routine.name, isEmpty);
    expect(routine.notes, isEmpty);
  });

  test('notes are kept by other changes', () {
    final withNotes = routine.withNotes('Slow start');

    expect(withNotes.withApparatus(Apparatus.ball).notes, 'Slow start');
    expect(withNotes.withLevel(figSenior).notes, 'Slow start');
    expect(withNotes.rename('Ball').notes, 'Slow start');
    expect(withNotes, isNot(routine));
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

  test('duplicate copies the content under a new id, name and time', () {
    final original = routine
        .rename('Hoop')
        .withApparatus(Apparatus.hoop)
        .withLevel(figSenior)
        .withNotes('Music: Bolero')
        .withDb(routine.db.withElementAdded(testJump));
    final later = now.add(const Duration(days: 1));

    final copy = original.duplicate(id: 'r2', name: 'Hoop (copy)', now: later);

    expect(copy.id, 'r2');
    expect(copy.name, 'Hoop (copy)');
    expect(copy.apparatus, Apparatus.hoop);
    expect(copy.level, figSenior);
    expect(copy.notes, 'Music: Bolero');
    expect(copy.db, original.db);
    expect(copy.da, original.da);
    expect(copy.createdAt, later);
    expect(copy.updatedAt, later);
  });
}
