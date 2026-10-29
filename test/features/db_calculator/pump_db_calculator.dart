import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/da_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/element_picker_screen.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';

import '../routines/fake_routine_repository.dart';
import '../da_calculator/test_data.dart';
import 'test_data.dart';

const testRoutineId = 'r1';

Routine emptyTestRoutine() => Routine.create(
  id: testRoutineId,
  rulesetId: testRuleset.id,
  now: DateTime.utc(2026, 10, 26),
);

/// Pumps the routine page for [routine] (default: an empty routine) on
/// [initialTab], with fake catalogue and routine repositories. Returns the
/// routine repository.
Future<FakeRoutineRepository> pumpDbCalculator(
  WidgetTester tester, {
  FakeDbCatalogueRepository? catalogue,
  FakeDaCatalogueRepository? daCatalogue,
  Routine? routine,
  RoutineTab initialTab = RoutineTab.db,
  double height = 2400,
}) async {
  // A tall surface so the whole scroll view is built without scrolling.
  tester.view.physicalSize = Size(800, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final routines = FakeRoutineRepository([routine ?? emptyTestRoutine()]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dbCatalogueRepositoryProvider.overrideWithValue(
          catalogue ?? FakeDbCatalogueRepository(),
        ),
        daCatalogueRepositoryProvider.overrideWithValue(
          daCatalogue ?? FakeDaCatalogueRepository(),
        ),
        routineRepositoryProvider.overrideWithValue(routines),
      ],
      child: MaterialApp(
        home: RoutineScreen(routineId: testRoutineId, initialTab: initialTab),
      ),
    ),
  );
  // Let the routine and catalogue futures complete.
  await tester.pump();
  await tester.pump();
  return routines;
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(RoutineScreen)));

/// Opens the "Add element" picker from the body difficulties tab.
Future<void> openElementPicker(WidgetTester tester) async {
  await tester.tap(find.text('Add element'));
  await tester.pumpAndSettle();
}

/// Adds the test element named [name] through the picker (its group, then
/// a search) and closes the picker again.
Future<void> addFromCatalogue(WidgetTester tester, String name) async {
  final element = [
    testJump,
    testBalance,
    testRotation,
  ].singleWhere((e) => e.name == name);
  await openElementPicker(tester);
  await tester.tap(find.text(element.group.label));
  await tester.pumpAndSettle();
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

/// Opens the routine page's menu and chooses [item], e.g. "Clear DA".
Future<void> chooseMenuItem(WidgetTester tester, String item) async {
  await tester.tap(find.byTooltip('More options'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}
