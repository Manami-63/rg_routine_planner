import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';

import '../pump_db_calculator.dart';
import '../test_data.dart';

// Dragging DB and risks into performance order.
void main() {
  /// Drags the [index]th drag handle down by [rows] list rows.
  Future<void> dragDown(WidgetTester tester, int index, double rows) async {
    final handle = find.byIcon(Icons.drag_handle).at(index);
    final rowHeight = tester
        .getSize(find.ancestor(of: handle, matching: find.byType(ListTile)))
        .height;
    await tester.timedDrag(
      handle,
      Offset(0, rowHeight * rows),
      const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('elements are reordered with their options and saved', (
    tester,
  ) async {
    const flat = DbElementOptions(flatFoot: true);
    final empty = emptyTestRoutine();
    final routines = await pumpDbCalculator(
      tester,
      routine: empty.withDb(
        DbRoutine(
          rulesetId: testRuleset.id,
          elements: const [testJump, testBalance, testRotation],
          elementOptions: const [
            flat,
            DbElementOptions.none,
            DbElementOptions.none,
          ],
        ),
      ),
    );

    await dragDown(tester, 0, 1);

    final saved = routines.routines[testRoutineId]!.db;
    expect(saved.elements, [testBalance, testJump, testRotation]);
    expect(saved.elementOptions, [
      DbElementOptions.none,
      flat,
      DbElementOptions.none,
    ]);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('selected-0')),
        matching: find.text(testBalance.name),
      ),
      findsOneWidget,
    );
  });

  testWidgets('moving a risk changes which ones count', (tester) async {
    final twoRot = RiskElement(rotation: testTwoRotations);
    final threeRot = RiskElement(rotation: testThreeRotations);
    final empty = emptyTestRoutine();
    final routines = await pumpDbCalculator(
      tester,
      routine: empty
          .withApparatus(Apparatus.hoop)
          .withLevel(
            const CompetitionLevel.custom(
              LevelRequirements(risk: CountLimit(max: 1)),
            ),
          )
          .withDb(
            DbRoutine(rulesetId: testRuleset.id, risks: [twoRot, threeRot]),
          ),
    );
    await tester.tap(find.text('R'));
    await tester.pumpAndSettle();
    String breakdown() =>
        tester.widget<Text>(find.byKey(const ValueKey('db-breakdown'))).data!;
    expect(breakdown(), 'Body 0.00 · Risks 0.20 (1 of 2)');

    await dragDown(tester, 0, 1);

    expect(routines.routines[testRoutineId]!.db.risks, [threeRot, twoRot]);
    expect(breakdown(), 'Body 0.00 · Risks 0.30 (1 of 2)');
  });
}
