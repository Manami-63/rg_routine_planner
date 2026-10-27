import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_screen.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/element_picker_screen.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';

import '../routines/fake_routine_repository.dart';
import 'test_data.dart';

const testRoutineId = 'r1';

Routine emptyTestRoutine() => Routine.create(
  id: testRoutineId,
  rulesetId: testRuleset.id,
  now: DateTime.utc(2026, 10, 26),
);

/// Pumps the DB calculator for [routine] (default: an empty routine) with
/// fake catalogue and routine repositories. Returns the routine repository.
Future<FakeRoutineRepository> pumpDbCalculator(
  WidgetTester tester, {
  FakeDbCatalogueRepository? catalogue,
  Routine? routine,
}) async {
  // A tall surface so the whole scroll view is built without scrolling.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final routines = FakeRoutineRepository([routine ?? emptyTestRoutine()]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dbCatalogueRepositoryProvider.overrideWithValue(
          catalogue ?? FakeDbCatalogueRepository(),
        ),
        routineRepositoryProvider.overrideWithValue(routines),
      ],
      child: const MaterialApp(
        home: DbCalculatorScreen(routineId: testRoutineId),
      ),
    ),
  );
  // Let the routine and catalogue futures complete.
  await tester.pump();
  await tester.pump();
  return routines;
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(DbCalculatorScreen)));

/// Opens the "Add element" picker from the body difficulties tab.
Future<void> openElementPicker(WidgetTester tester) async {
  await tester.tap(find.text('Add element'));
  await tester.pumpAndSettle();
}

/// Adds the element named [name] through the picker (found by searching)
/// and closes the picker again.
Future<void> addFromCatalogue(WidgetTester tester, String name) async {
  await openElementPicker(tester);
  await tester.enterText(
    find.descendant(
      of: find.byType(ElementPickerScreen),
      matching: find.byType(TextField),
    ),
    name,
  );
  await tester.pump();
  await tester.tap(find.byTooltip('Add $name'));
  await tester.pump();
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
}
