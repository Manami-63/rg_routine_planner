import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/dance_steps/domain/dance_step_checks.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/test_data.dart';

void main() {
  Duration s(num seconds) => Duration(milliseconds: (seconds * 1000).round());

  /// A routine with an S at 10 s, and a jump (0.30), a balance (0.20), a
  /// rotation (0.10), a risk and a DA marked at the given times.
  Routine routineWith({
    Duration? jump,
    Duration? balance,
    Duration? rotation,
    Duration? risk,
    Duration? da,
    Apparatus apparatus = Apparatus.hoop,
  }) => Routine(
    id: 'r1',
    name: '',
    apparatus: apparatus,
    createdAt: DateTime.utc(2026, 10, 30),
    updatedAt: DateTime.utc(2026, 10, 30),
    danceStepTimes: [s(10)],
    db: DbRoutine(
      rulesetId: testRuleset.id,
      elements: const [testJump, testBalance, testRotation],
      elementTimes: [jump, balance, rotation],
      risks: [RiskElement(rotation: testTwoRotations)],
      riskTimes: [risk],
    ),
    da: DaRoutine(
      rulesetId: testRuleset.id,
      elements: [DaElement(base: testRoll)],
      times: [da],
    ),
  );

  const values = [
    Score.hundredths(30),
    Score.hundredths(20),
    Score.hundredths(10),
  ];

  test('nothing marked during the S: no conflicts', () {
    final routine = routineWith(jump: s(5), risk: s(18), da: s(30));

    expect(danceStepConflicts(routine, dbValues: values), isEmpty);
  });

  test('risks, DA and DB worth 0.20 or more during the S conflict', () {
    final routine = routineWith(
      jump: s(10),
      balance: s(12),
      rotation: s(13),
      risk: s(14),
      da: s(17.9),
    );

    expect(danceStepConflicts(routine, dbValues: values), [
      const DanceStepConflict(
        danceStepIndex: 0,
        kind: DanceStepConflictKind.risk,
        index: 0,
      ),
      const DanceStepConflict(
        danceStepIndex: 0,
        kind: DanceStepConflictKind.da,
        index: 0,
      ),
      const DanceStepConflict(
        danceStepIndex: 0,
        kind: DanceStepConflictKind.db,
        index: 0,
        value: Score.hundredths(30),
      ),
      // The balance is worth exactly 0.20; the 0.10 rotation is allowed.
      const DanceStepConflict(
        danceStepIndex: 0,
        kind: DanceStepConflictKind.db,
        index: 1,
        value: Score.hundredths(20),
      ),
    ]);
  });

  test('the S lasts 8 s from its time', () {
    final atEnd = routineWith(da: s(18));
    expect(danceStepConflicts(atEnd, dbValues: values), isEmpty);
  });

  test('the DB value used is the one given (e.g. with options)', () {
    final routine = routineWith(rotation: s(11));
    expect(
      danceStepConflicts(
        routine,
        dbValues: const [
          Score.hundredths(30),
          Score.hundredths(20),
          Score.hundredths(20),
        ],
      ).single.itemLabel,
      'DB 3 (0.20)',
    );
  });

  test('freehand checks DB and DA, not risks', () {
    final routine = routineWith(
      jump: s(11),
      risk: s(11),
      da: s(11),
      apparatus: Apparatus.freehand,
    );

    expect(
      danceStepConflicts(routine, dbValues: values).map((c) => c.kind),
      unorderedEquals([DanceStepConflictKind.da, DanceStepConflictKind.db]),
    );
  });
}
