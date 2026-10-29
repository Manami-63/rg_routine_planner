import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/app/app.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/da_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';

import 'features/da_calculator/test_data.dart';
import 'features/db_calculator/pump_db_calculator.dart';
import 'features/db_calculator/test_data.dart';
import 'features/routines/fake_routine_repository.dart';

void main() {
  testWidgets('create a routine, edit it, leave, and find it saved', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final routines = FakeRoutineRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbCatalogueRepositoryProvider.overrideWithValue(
            FakeDbCatalogueRepository(),
          ),
          daCatalogueRepositoryProvider.overrideWithValue(
            FakeDaCatalogueRepository(),
          ),
          routineRepositoryProvider.overrideWithValue(routines),
        ],
        child: const RgRoutinePlannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Home -> My routines (empty).
    expect(find.text('RG Routine Planner'), findsOneWidget);
    await tester.tap(find.text('My routines'));
    await tester.pumpAndSettle();
    expect(find.text('No routines yet'), findsOneWidget);

    // New routine opens the calculator.
    await tester.tap(find.text('New routine'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'DB Calculator'), findsOneWidget);
    expect(routines.routines, hasLength(1));

    await tester.enterText(find.byType(TextField), 'Ball final');
    await addFromCatalogue(tester, 'Test Jump');

    // The DA page edits the same routine.
    await tester.tap(find.text('Apparatus (DA)'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'DA Calculator'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Ball final'), findsOneWidget);

    // Leaving straight away still saves the (debounced) name, and Back
    // returns to the list rather than to the DB page.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Ball final'), findsOneWidget);
    expect(
      find.textContaining('No level · 1 DB · 0 risks · 0 DA'),
      findsOneWidget,
    );

    // Reopening shows the saved content.
    await tester.tap(find.text('Ball final'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove Test Jump'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('RG Routine Planner'), findsOneWidget);
  });
}
