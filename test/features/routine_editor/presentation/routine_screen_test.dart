import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/app/router.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_controller.dart';

import '../../da_calculator/pump_da_calculator.dart';
import '../../da_calculator/test_data.dart';
import '../../db_calculator/test_data.dart';
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

  testWidgets('each tab has its own add button and breakdown', (tester) async {
    await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withApparatus(Apparatus.hoop),
    );

    await tester.tap(find.text('R'));
    await tester.pumpAndSettle();
    expect(find.text('Build a risk'), findsOneWidget);
    expect(find.byKey(const ValueKey('db-breakdown')), findsOneWidget);

    await tester.tap(find.text('DA'));
    await tester.pumpAndSettle();
    expect(find.text('Build a DA'), findsOneWidget);
    expect(find.byKey(const ValueKey('da-breakdown')), findsOneWidget);
    expect(find.byKey(const ValueKey('db-breakdown')), findsNothing);
  });

  testWidgets('the bottom bar shows DB + DA = total on every tab', (
    tester,
  ) async {
    final base = emptyTestRoutine().withApparatus(Apparatus.hoop);
    await pumpDbCalculator(
      tester,
      routine: base
          .withDb(base.db.withElementAdded(testJump))
          .withDa(
            base.da.withElementAdded(
              DaElement(
                base: testRoll,
                criteria: const {
                  DaCriterion.outsideVisualField,
                  DaCriterion.db,
                },
              ),
            ),
          ),
    );
    String text(String key) =>
        tester.widget<Text>(find.byKey(ValueKey(key))).data!;

    expect(text('db-subtotal'), '0.30');
    expect(text('da-subtotal'), '0.30');
    expect(text('routine-total'), '0.60');
    expect(find.text('Provisional difficulty total'), findsOneWidget);

    await tester.tap(find.text('DA'));
    await tester.pumpAndSettle();
    expect(text('routine-total'), '0.60');
    expect(text('da-breakdown'), '1 DA');

    await tester.tap(find.byTooltip('About this total'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
        'DB 0.30 (body difficulties and risks) + '
        'DA 0.30 = 0.60.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Penalties are never deducted.'), findsOne);
  });

  testWidgets('notes are edited on their own tab and saved', (tester) async {
    final routines = await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withNotes('Music: Bolero'),
    );

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    // No add button on the notes tab; the total stays visible.
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byKey(const ValueKey('routine-total')), findsOneWidget);
    expect(find.text('Music: Bolero'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('routine-notes')),
      'Music: Bolero\nStart facing the judges',
    );
    await tester.pump(
      RoutineController.nameSaveDelay + const Duration(milliseconds: 50),
    );

    expect(
      routines.routines[testRoutineId]!.notes,
      'Music: Bolero\nStart facing the judges',
    );

    // Notes are kept when switching tabs and back.
    await tester.tap(find.text('DB'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    expect(find.text('Music: Bolero\nStart facing the judges'), findsOneWidget);
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
    expect(RoutineTab.fromName('notes'), RoutineTab.notes);
    expect(RoutineTab.fromName('other'), RoutineTab.db);
    expect(RoutineTab.fromName(null), RoutineTab.db);
  });
}
