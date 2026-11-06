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
    expect(find.text('RG Routine Lab'), findsOneWidget);
    await tester.tap(find.text('My routines'));
    await tester.pumpAndSettle();
    expect(find.text('No routines yet'), findsOneWidget);

    // New routine asks for the details first; the apparatus is required.
    await tester.tap(find.text('New routine'));
    await tester.pumpAndSettle();
    final create = find.widgetWithText(TextButton, 'Create');
    expect(tester.widget<TextButton>(create).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Ball final');
    await tester.tap(find.text('Ball'));
    await tester.pump();
    await tester.tap(create);
    await tester.pumpAndSettle();

    // The routine page shows the name and details in its header.
    expect(routines.routines, hasLength(1));
    expect(find.widgetWithText(AppBar, 'Ball final'), findsOneWidget);
    expect(find.text('Ball · No level'), findsOneWidget);
    await addFromCatalogue(tester, 'Test Jump');

    // The DA tab edits the same routine.
    await tester.tap(find.text('DA'));
    await tester.pumpAndSettle();
    expect(find.text('Build a DA'), findsOneWidget);

    // Back returns to the list.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Ball final'), findsOneWidget);
    expect(
      find.textContaining(
        'Ball · No\u00A0level · 1\u00A0DB · 0\u00A0risks · 0\u00A0DA',
      ),
      findsOneWidget,
    );

    // The details can be edited from the list.
    await tester.tap(find.byTooltip('Options for Ball final'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit details'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ball semi');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Ball semi'), findsOneWidget);
    expect(routines.routines.values.single.db.elements, hasLength(1));

    // Reopening shows the saved content.
    await tester.tap(find.text('Ball semi'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove Test Jump'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('RG Routine Lab'), findsOneWidget);
  });
}
