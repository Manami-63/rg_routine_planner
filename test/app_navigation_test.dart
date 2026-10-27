import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/app/app.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';

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
          routineRepositoryProvider.overrideWithValue(routines),
        ],
        child: const RgRoutinePlannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Home -> My routines (empty).
    expect(find.text('RG Routine Planner'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
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

    // Leaving straight away still saves the (debounced) name.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Ball final'), findsOneWidget);
    expect(find.textContaining('No level · 1 DB · 0 risks'), findsOneWidget);

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
