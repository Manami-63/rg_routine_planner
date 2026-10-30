import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/floor/floor_cell.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/floor_checks.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/routine_timeline.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/test_data.dart';

void main() {
  Duration s(int seconds) => Duration(seconds: seconds);
  FloorCell n(int number) => FloorCell.fromNumber(number)!;

  /// A routine with the given DB, DA and risks, each as (time, cell).
  Routine routineWith({
    List<(DbElement, int, int?)> db = const [],
    List<(int, int?)> da = const [],
    List<(int, int?)> risks = const [],
  }) => Routine(
    id: 'r1',
    name: '',
    createdAt: DateTime.utc(2026, 10, 30),
    updatedAt: DateTime.utc(2026, 10, 30),
    db: DbRoutine(
      rulesetId: testRuleset.id,
      elements: [for (final (e, _, _) in db) e],
      elementTimes: [for (final (_, t, _) in db) s(t)],
      elementCells: [for (final (_, _, c) in db) FloorCell.fromNumber(c)],
      risks: [for (final _ in risks) RiskElement(rotation: testTwoRotations)],
      riskTimes: [for (final (t, _) in risks) s(t)],
      riskCells: [for (final (_, c) in risks) FloorCell.fromNumber(c)],
    ),
    da: DaRoutine(
      rulesetId: testRuleset.id,
      elements: [for (final _ in da) DaElement(base: testRoll)],
      times: [for (final (t, _) in da) s(t)],
      cells: [for (final (_, c) in da) FloorCell.fromNumber(c)],
    ),
  );

  group('zones (#9.2)', () {
    test('no cells: nothing to check', () {
      expect(floorZoneReport(routineWith(da: [(1, null)])), isNull);
    });

    test('zones with an item are visited; others are missing', () {
      final report = floorZoneReport(
        routineWith(da: [(1, 1), (5, 3), (9, 2)]),
      )!;

      expect(report.visitedBy.keys, unorderedEquals([n(1), n(3)]));
      expect(report.missing, [n(5), n(7), n(9)]);
    });

    test('the centre crossed between two items is passed through', () {
      final routine = routineWith(da: [(1, 1), (5, 9), (9, 7), (12, 3)]);
      final report = floorZoneReport(routine)!;
      final entries = routine.timelineEntries;

      expect(report.passedBy, {n(5): (entries[0], entries[1])});
      expect(report.missing, isEmpty);
    });

    test('a visited zone is not also listed as passed through', () {
      final report = floorZoneReport(
        routineWith(da: [(1, 5), (5, 1), (9, 9)]),
      )!;
      expect(report.passedBy, isEmpty);
    });
  });

  group('same placement (#9.4.1)', () {
    test('3 Difficulties in a row in one cell', () {
      final routine = routineWith(
        db: [(testBalance, 1, 5), (testRotation, 20, 5)],
        da: [(10, 5)],
      );

      expect(samePlacementRuns(routine).single.map((e) => e.time), [
        s(1),
        s(10),
        s(20),
      ]);
    });

    test('2 in a row is fine', () {
      final routine = routineWith(da: [(1, 5), (10, 5), (20, 4)]);
      expect(samePlacementRuns(routine), isEmpty);
    });

    test('a DB and a DA in the same moment count as 1', () {
      final routine = routineWith(
        db: [(testBalance, 1, 5)],
        da: [(2, 5), (10, 5)],
      );
      expect(samePlacementRuns(routine), isEmpty);
    });

    test('risks and leaps are not counted and do not break a run', () {
      final routine = routineWith(
        db: [(testJump, 5, 5), (testJump, 6, 2)],
        da: [(1, 5), (10, 5), (20, 5)],
        risks: [(15, 8)],
      );
      expect(samePlacementRuns(routine).single.length, 3);
    });

    test('an item without a cell breaks a run', () {
      final routine = routineWith(da: [(1, 5), (5, 5), (10, null), (20, 5)]);
      expect(samePlacementRuns(routine), isEmpty);
    });
  });
}
