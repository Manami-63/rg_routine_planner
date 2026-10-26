import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_screen.dart';

import '../test_data.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    FakeDbElementRepository? repository,
  }) async {
    // A tall surface so the whole scroll view is built without scrolling.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbElementRepositoryProvider.overrideWithValue(
            repository ?? FakeDbElementRepository(),
          ),
        ],
        child: const MaterialApp(home: DbCalculatorScreen()),
      ),
    );
    await tester.pump();
  }

  String subtotalText(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('db-subtotal'))).data!;

  testWidgets('shows sample-data warning and empty routine initially', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.textContaining('not official rules'), findsOneWidget);
    expect(find.text('No elements yet'), findsOneWidget);
    expect(subtotalText(tester), '0.00');
    expect(find.text('Provisional DB subtotal'), findsOneWidget);
  });

  testWidgets('adding elements updates the list and subtotal', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Add Test Jump'));
    await tester.tap(find.byTooltip('Add Test Balance'));
    await tester.pump();

    expect(find.text('No elements yet'), findsNothing);
    expect(find.byTooltip('Remove Test Jump'), findsOneWidget);
    expect(find.byTooltip('Remove Test Balance'), findsOneWidget);
    expect(find.text('2 selected'), findsOneWidget);
    expect(subtotalText(tester), '0.50');
  });

  testWidgets('removing an element updates the subtotal', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Add Test Jump'));
    await tester.tap(find.byTooltip('Add Test Rotation'));
    await tester.pump();
    await tester.tap(find.byTooltip('Remove Test Jump'));
    await tester.pump();

    expect(find.byTooltip('Remove Test Jump'), findsNothing);
    expect(subtotalText(tester), '0.10');
  });

  testWidgets('clear all asks for confirmation and empties the routine', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Add Test Jump'));
    await tester.pump();

    // Cancelling keeps the elements.
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(subtotalText(tester), '0.30');

    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('No elements yet'), findsOneWidget);
    expect(subtotalText(tester), '0.00');
  });

  testWidgets('clear all is disabled for an empty routine', (tester) async {
    await pumpScreen(tester);

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.delete_sweep_outlined),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('routine name is editable and survives clear all', (
    tester,
  ) async {
    await pumpScreen(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(DbCalculatorScreen)),
    );

    await tester.enterText(find.byType(TextField), 'Hoop routine');
    expect(container.read(dbRoutineControllerProvider).name, 'Hoop routine');

    await tester.tap(find.byTooltip('Add Test Jump'));
    await tester.pump();
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(container.read(dbRoutineControllerProvider).name, 'Hoop routine');
    expect(find.text('Hoop routine'), findsOneWidget);
  });

  testWidgets('shows a loading indicator while the catalogue loads', (
    tester,
  ) async {
    final pending = Completer<List<DbElement>>();
    await pumpScreen(
      tester,
      repository: FakeDbElementRepository(future: pending.future),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.complete([testJump]);
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byTooltip('Add Test Jump'), findsOneWidget);
  });

  testWidgets('shows an error with retry when the catalogue fails', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      repository: FakeDbElementRepository(error: StateError('boom')),
    );
    await tester.pump();

    expect(find.text('Could not load the catalogue'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('retry reloads the catalogue after an error', (tester) async {
    final repository = FakeDbElementRepository(error: StateError('boom'));
    await pumpScreen(tester, repository: repository);
    await tester.pump();

    repository.error = null;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Could not load the catalogue'), findsNothing);
    expect(find.byTooltip('Add Test Jump'), findsOneWidget);
  });

  testWidgets('shows an empty state for an empty catalogue', (tester) async {
    await pumpScreen(
      tester,
      repository: FakeDbElementRepository(elements: const []),
    );
    await tester.pump();

    expect(find.text('Catalogue is empty'), findsOneWidget);
  });
}
