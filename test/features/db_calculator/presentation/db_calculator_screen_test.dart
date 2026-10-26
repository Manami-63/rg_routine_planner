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
    FakeDbCatalogueRepository? repository,
  }) async {
    // A tall surface so the whole scroll view is built without scrolling.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbCatalogueRepositoryProvider.overrideWithValue(
            repository ?? FakeDbCatalogueRepository(),
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
      repository: FakeDbCatalogueRepository(future: pending.future),
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
      repository: FakeDbCatalogueRepository(error: StateError('boom')),
    );
    await tester.pump();

    expect(find.text('Could not load the catalogue'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('retry reloads the catalogue after an error', (tester) async {
    final repository = FakeDbCatalogueRepository(error: StateError('boom'));
    await pumpScreen(tester, repository: repository);
    await tester.pump();

    repository.error = null;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Could not load the catalogue'), findsNothing);
    expect(find.byTooltip('Add Test Jump'), findsOneWidget);
  });

  group('risks tab', () {
    Future<void> openRisksTab(WidgetTester tester) async {
      await tester.tap(find.text('Risks'));
      await tester.pumpAndSettle();
    }

    String breakdownText(WidgetTester tester) =>
        tester.widget<Text>(find.byKey(const ValueKey('db-breakdown'))).data!;

    testWidgets('starts with an empty state', (tester) async {
      await pumpScreen(tester);
      await openRisksTab(tester);

      expect(find.text('No risks yet'), findsOneWidget);
      expect(find.text('0 added'), findsOneWidget);
      expect(breakdownText(tester), 'Body 0.00 · Risks 0.00');
    });

    testWidgets('building a risk previews its value and adds it', (
      tester,
    ) async {
      await pumpScreen(tester);
      await openRisksTab(tester);

      await tester.tap(find.text('Build a risk'));
      await tester.pumpAndSettle();

      // First rotation option is preselected.
      String previewText() => tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const ValueKey('risk-preview-value')),
              matching: find.byType(Text),
            ),
          )
          .data!;
      expect(previewText(), '0.20');

      await tester.tap(find.text('3 rotations'));
      await tester.tap(find.text('Criterion A'));
      await tester.pump();
      expect(previewText(), '0.40');

      await tester.tap(find.text('Add risk'));
      await tester.pumpAndSettle();

      expect(find.text('Build a risk'), findsOneWidget); // Sheet closed.
      expect(find.text('3 rotations + Criterion A'), findsOneWidget);
      expect(find.text('1 added'), findsOneWidget);
      expect(subtotalText(tester), '0.40');
      expect(breakdownText(tester), 'Body 0.00 · Risks 0.40');
    });

    testWidgets('dismissing the builder adds nothing', (tester) async {
      await pumpScreen(tester);
      await openRisksTab(tester);

      await tester.tap(find.text('Build a risk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Criterion B'));
      await tester.tapAt(const Offset(10, 10)); // Tap the barrier.
      await tester.pumpAndSettle();

      expect(find.text('No risks yet'), findsOneWidget);
      expect(subtotalText(tester), '0.00');
    });

    testWidgets('removing a risk updates the subtotal', (tester) async {
      await pumpScreen(tester);
      await openRisksTab(tester);

      await tester.tap(find.text('Build a risk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add risk'));
      await tester.pumpAndSettle();
      expect(subtotalText(tester), '0.20');

      await tester.tap(find.byTooltip('Remove risk 1'));
      await tester.pump();

      expect(find.text('No risks yet'), findsOneWidget);
      expect(subtotalText(tester), '0.00');
    });

    testWidgets('subtotal combines body difficulties and risks', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('Add Test Jump'));
      await tester.pump();
      await openRisksTab(tester);
      await tester.tap(find.text('Build a risk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add risk'));
      await tester.pumpAndSettle();

      expect(breakdownText(tester), 'Body 0.30 · Risks 0.20');
      expect(subtotalText(tester), '0.50');
    });

    testWidgets('clear all removes risks too', (tester) async {
      await pumpScreen(tester);
      await openRisksTab(tester);

      await tester.tap(find.text('Build a risk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add risk'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Clear all'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('No risks yet'), findsOneWidget);
      expect(subtotalText(tester), '0.00');
    });

    testWidgets('shows an error with retry for risk options', (tester) async {
      final repository = FakeDbCatalogueRepository(
        riskError: StateError('boom'),
      );
      await pumpScreen(tester, repository: repository);
      await openRisksTab(tester);

      expect(find.text('Could not load risk options'), findsOneWidget);

      repository.riskError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Build a risk'), findsOneWidget);
    });
  });

  testWidgets('shows an empty state for an empty catalogue', (tester) async {
    await pumpScreen(
      tester,
      repository: FakeDbCatalogueRepository(elements: const []),
    );
    await tester.pump();

    expect(find.text('Catalogue is empty'), findsOneWidget);
  });
}
