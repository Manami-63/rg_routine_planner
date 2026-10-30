import 'package:flutter_test/flutter_test.dart';
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
      ),
      TimelineEntry(
        kind: TimelineKind.da,
        index: 0,
        name: testRoll.name,
        time: s(12),
      ),
      TimelineEntry(
        kind: TimelineKind.risk,
        index: 0,
        name: risk.description,
        time: s(20),
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
}
