import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/core/floor/floor_cell.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/routine_timeline.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/test_data.dart';

void main() {
  Duration s(int seconds) => Duration(seconds: seconds);

  final empty = Routine.create(
    id: 'r1',
    rulesetId: testRuleset.id,
    now: DateTime.utc(2026, 10, 30),
  );
  final risk = RiskElement(rotation: testTwoRotations);
  final routine = empty
      .withDb(
        empty.db
            .withElementAdded(testJump)
            .withElementAdded(testBalance)
            .withRiskAdded(risk),
      )
      .withDa(empty.da.withElementAdded(DaElement(base: testRoll)))
      .withDanceStepCount(2);

  test('nothing is marked at first', () {
    expect(routine.timelineEntries, isEmpty);
    expect(routine.hasTimes, isFalse);
    for (final kind in TimelineKind.values) {
      expect(routine.nextUnmarked(kind), 0, reason: kind.name);
    }
    expect(empty.nextUnmarked(TimelineKind.db), isNull);
  });

  test('a DB entry carries its Fouetté cycles', () {
    final marked = routine
        .withDb(
          routine.db.withElementOptionsAt(
            0,
            const DbElementOptions(rotationCycles: '2121'),
          ),
        )
        .withTime(TimelineKind.db, 0, s(12));

    expect(marked.timelineEntries.single.dbCycles, '2121');
  });

  test('entries list every marked item by time', () {
    final marked = routine
        .withTime(TimelineKind.db, 0, s(12))
        .withTime(TimelineKind.danceStep, 0, s(3))
        .withTime(TimelineKind.da, 0, s(12))
        .withTime(TimelineKind.risk, 0, s(20));

    expect(marked.timelineEntries, [
      const TimelineEntry(
        kind: TimelineKind.danceStep,
        index: 0,
        name: 'Dance steps combination',
        time: Duration(seconds: 3),
      ),
      TimelineEntry(
        kind: TimelineKind.db,
        index: 0,
        name: testJump.name,
        time: s(12),
        db: testJump,
      ),
      TimelineEntry(
        kind: TimelineKind.da,
        index: 0,
        name: testRoll.name,
        time: s(12),
        da: marked.da.elements.single,
      ),
      TimelineEntry(
        kind: TimelineKind.risk,
        index: 0,
        name: risk.description,
        time: s(20),
        risk: risk,
      ),
    ]);
    expect(marked.nextUnmarked(TimelineKind.db), 1);
    expect(marked.nextUnmarked(TimelineKind.risk), isNull);
    expect(marked.hasTimes, isTrue);
  });

  test('a time set on a later item reorders the list', () {
    final marked = routine
        .withTime(TimelineKind.db, 1, s(4))
        .withTime(TimelineKind.db, 0, s(9));

    expect(marked.db.elements, [testBalance, testJump]);
    expect(marked.timesOf(TimelineKind.db), [s(4), s(9)]);
  });

  test('times below zero become zero, and null clears', () {
    final marked = routine.withTime(TimelineKind.da, 0, -s(1));
    expect(marked.timesOf(TimelineKind.da), [Duration.zero]);
    expect(marked.withTime(TimelineKind.da, 0, null).timesOf(TimelineKind.da), [
      null,
    ]);
  });

  test('clearing removes every time but keeps the items', () {
    final marked = routine
        .withTime(TimelineKind.db, 0, s(1))
        .withTime(TimelineKind.risk, 0, s(2))
        .withTime(TimelineKind.da, 0, s(3))
        .withTime(TimelineKind.danceStep, 1, s(4));

    final cleared = marked.withTimesCleared();

    expect(cleared, routine);
  });

  test('cells go with their items and are cleared with the time', () {
    final marked = routine
        .withCell(TimelineKind.db, 1, FloorCell.centre)
        .withTime(TimelineKind.db, 1, s(4))
        .withTime(TimelineKind.db, 0, s(9));

    // The balance (index 1) moved first, with its cell.
    expect(marked.cellsOf(TimelineKind.db), [FloorCell.centre, null]);
    expect(marked.timelineEntries.first.cell, FloorCell.centre);
    expect(marked.withTime(TimelineKind.db, 0, null).cellsOf(TimelineKind.db), [
      null,
      null,
    ]);
    final cleared = marked.withTimesCleared();
    expect(cleared.cellsOf(TimelineKind.db), [null, null]);
    expect(cleared.hasTimes, isFalse);
  });

  test('S cells follow their S', () {
    final marked = routine
        .withDanceStepCellAt(1, FloorCell.front)
        .withDanceStepTimeAt(1, s(2))
        .withDanceStepTimeAt(0, s(7));

    expect(marked.danceStepCells, [FloorCell.front, null]);
    expect(marked.withDanceStepCount(1).danceStepCells, [FloorCell.front]);
  });

  group('DB and DA together', () {
    test('the same time pairs a DB with a DA', () {
      final marked = routine
          .withTime(TimelineKind.db, 1, s(12))
          .withTime(TimelineKind.da, 0, s(12))
          .withTime(TimelineKind.risk, 0, s(12));

      expect(marked.partnerOf(TimelineKind.db, 1), 0);
      expect(marked.partnerOf(TimelineKind.da, 0), 1);
      expect(marked.partnerOf(TimelineKind.risk, 0), isNull);
    });

    test('a different time, or no time, is not together', () {
      final marked = routine
          .withTime(TimelineKind.db, 0, s(12))
          .withTime(TimelineKind.da, 0, s(13));

      expect(marked.partnerOf(TimelineKind.db, 0), isNull);
      expect(marked.partnerOf(TimelineKind.db, 1), isNull);
    });

    test('moving one time moves its partner too', () {
      final marked = routine
          .withTime(TimelineKind.db, 0, s(12))
          .withTime(TimelineKind.da, 0, s(12))
          .withTimeMoved(TimelineKind.da, 0, -s(13));

      expect(marked.db.elementTimes.first, Duration.zero);
      expect(marked.da.times, [Duration.zero]);
    });

    test('moving an unpaired time moves only it', () {
      final marked = routine
          .withTime(TimelineKind.db, 0, s(12))
          .withTime(TimelineKind.da, 0, s(14))
          .withTimeMoved(TimelineKind.db, 0, s(1));

      expect(marked.db.elementTimes.first, s(13));
      expect(marked.da.times, [s(14)]);
    });
  });
}
