import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/app/router.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_controller.dart';

import '../../da_calculator/pump_da_calculator.dart';
import '../../db_calculator/pump_db_calculator.dart';

void main() {
  testWidgets('the header shows the name, apparatus and level', (tester) async {
    await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine()
          .rename('Hoop final')
          .withApparatus(Apparatus.hoop)
          .withLevel(figJunior),
    );

    expect(find.widgetWithText(AppBar, 'Hoop final'), findsOneWidget);
    expect(find.text('Hoop · FIG Junior'), findsOneWidget);
    // The DB tab is open, with its add button.
    expect(find.text('Add element'), findsOneWidget);
  });

  testWidgets('each tab has its own add button and subtotal', (tester) async {
    await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withApparatus(Apparatus.hoop),
    );

    await tester.tap(find.text('R'));
    await tester.pumpAndSettle();
    expect(find.text('Build a risk'), findsOneWidget);
    expect(find.byKey(const ValueKey('db-subtotal')), findsOneWidget);

    await tester.tap(find.text('DA'));
    await tester.pumpAndSettle();
    expect(find.text('Build a DA'), findsOneWidget);
    expect(find.byKey(const ValueKey('da-subtotal')), findsOneWidget);
    expect(find.byKey(const ValueKey('db-subtotal')), findsNothing);
  });

  testWidgets('opens on the requested tab', (tester) async {
    await pumpDaCalculator(tester);

    expect(find.text('Build a DA'), findsOneWidget);
  });

  testWidgets('editing the details updates the header and saves', (
    tester,
  ) async {
    final routines = await pumpDbCalculator(tester);

    await tester.tap(find.byTooltip('Edit details'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Clubs');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Clubs'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Clubs'), findsOneWidget);
    expect(find.text('Clubs · No level'), findsOneWidget);
    final saved = routines.routines[testRoutineId]!;
    expect(saved.name, 'Clubs');
    expect(saved.apparatus, Apparatus.clubs);
  });

  testWidgets('duplicate saves a copy of the open routine', (tester) async {
    final routines = await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().rename('Ribbon'),
    );
    await addFromCatalogue(tester, 'Test Jump');

    await chooseMenuItem(tester, 'Duplicate');

    expect(routines.routines, hasLength(2));
    final copy = routines.routines.values.firstWhere(
      (r) => r.id != testRoutineId,
    );
    expect(copy.name, 'Ribbon (copy)');
    expect(copy.db.elements, hasLength(1));
    expect(find.text('Saved as "Ribbon (copy)".'), findsOneWidget);
    // The open routine is unchanged.
    expect(
      containerOf(tester).read(routineProvider(testRoutineId)).name,
      'Ribbon',
    );
  });

  test('routes open the routine page on a tab', () {
    expect(AppRoutes.routine('r1'), '/routines/r1');
    expect(AppRoutes.routine('r1', RoutineTab.da), '/routines/r1?tab=da');
    expect(RoutineTab.fromName('risks'), RoutineTab.risks);
    expect(RoutineTab.fromName('other'), RoutineTab.db);
    expect(RoutineTab.fromName(null), RoutineTab.db);
  });
}
