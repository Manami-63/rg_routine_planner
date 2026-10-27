import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_controller.dart';

import '../pump_db_calculator.dart';
import '../test_data.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    FakeDbCatalogueRepository? repository,
  }) => pumpDbCalculator(tester, catalogue: repository);

  String subtotalText(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('db-subtotal'))).data!;

  testWidgets('shows unofficial-data warning and empty routine initially', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(
      find.text('Unofficial values · totals are provisional'),
      findsOneWidget,
    );
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.textContaining('not official rules'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('No elements yet'), findsOneWidget);
    expect(subtotalText(tester), '0.00');
    expect(find.text('Provisional DB subtotal'), findsOneWidget);
  });

  testWidgets('adding elements updates the list and subtotal', (tester) async {
    await pumpScreen(tester);

    await addFromCatalogue(tester, 'Test Jump');
    await addFromCatalogue(tester, 'Test Balance');

    expect(find.text('No elements yet'), findsNothing);
    expect(find.byTooltip('Remove Test Jump'), findsOneWidget);
    expect(find.byTooltip('Remove Test Balance'), findsOneWidget);
    expect(find.text('2 selected'), findsOneWidget);
    expect(subtotalText(tester), '0.50');
  });

  testWidgets('removing an element updates the subtotal', (tester) async {
    await pumpScreen(tester);

    await addFromCatalogue(tester, 'Test Jump');
    await addFromCatalogue(tester, 'Test Rotation');
    await tester.tap(find.byTooltip('Remove Test Jump'));
    await tester.pump();

    expect(find.byTooltip('Remove Test Jump'), findsNothing);
    expect(subtotalText(tester), '0.10');
  });

  testWidgets('clear all asks for confirmation and empties the routine', (
    tester,
  ) async {
    await pumpScreen(tester);

    await addFromCatalogue(tester, 'Test Jump');

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
    final container = containerOf(tester);

    await tester.enterText(find.byType(TextField), 'Hoop routine');
    expect(container.read(routineProvider(testRoutineId)).name, 'Hoop routine');

    await addFromCatalogue(tester, 'Test Jump');
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(container.read(routineProvider(testRoutineId)).name, 'Hoop routine');
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

    // The spinner never settles, so pump the route transition explicitly.
    await tester.tap(find.text('Add element'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
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
    await openElementPicker(tester);

    expect(find.text('Could not load the catalogue'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('retry reloads the catalogue after an error', (tester) async {
    final repository = FakeDbCatalogueRepository(error: StateError('boom'));
    await pumpScreen(tester, repository: repository);
    await openElementPicker(tester);

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

      // The fewest rotations are preselected.
      String previewText() => tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const ValueKey('risk-preview-value')),
              matching: find.byType(Text),
            ),
          )
          .data!;
      expect(previewText(), '0.20');

      await tester.tap(find.byTooltip('More rotations'));
      await tester.tap(find.text('Criterion A'));
      await tester.pump();
      expect(previewText(), '0.40');

      await tester.tap(find.text('Add risk'));
      await tester.pumpAndSettle();

      expect(find.text('Build a risk'), findsOneWidget); // Sheet closed.
      expect(find.text('3 rotations + Throw: Criterion A'), findsOneWidget);
      expect(find.text('1 added'), findsOneWidget);
      expect(subtotalText(tester), '0.40');
      expect(breakdownText(tester), 'Body 0.00 · Risks 0.40');
    });

    testWidgets('builder shows criteria for the routine apparatus only', (
      tester,
    ) async {
      await pumpDbCalculator(
        tester,
        routine: emptyTestRoutine().withApparatus(Apparatus.ball),
      );
      await openRisksTab(tester);
      await tester.tap(find.text('Build a risk'));
      await tester.pumpAndSettle();

      expect(find.text('Ball catch'), findsOneWidget);
      expect(find.text('Test note'), findsOneWidget);
      expect(
        find.text('Choose an apparatus to see its specific criteria.'),
        findsNothing,
      );
    });

    testWidgets('builder without an apparatus shows general criteria', (
      tester,
    ) async {
      await pumpScreen(tester);
      await openRisksTab(tester);
      await tester.tap(find.text('Build a risk'));
      await tester.pumpAndSettle();

      expect(find.text('Criterion A'), findsOneWidget);
      expect(find.text('Ball catch'), findsNothing);
      expect(
        find.text('Choose an apparatus to see its specific criteria.'),
        findsOneWidget,
      );
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

      await addFromCatalogue(tester, 'Test Jump');
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
    await openElementPicker(tester);

    expect(find.text('Catalogue is empty'), findsOneWidget);
  });

  group('routine states', () {
    testWidgets('shows not found for a missing routine', (tester) async {
      await pumpDbCalculator(
        tester,
        routine: Routine.create(
          id: 'someone-else',
          rulesetId: testRuleset.id,
          now: DateTime.utc(2026),
        ),
      );

      expect(find.text('Routine not found'), findsOneWidget);
    });

    testWidgets('refuses a routine from another ruleset', (tester) async {
      await pumpDbCalculator(
        tester,
        routine: Routine.create(
          id: testRoutineId,
          rulesetId: 'old-v0',
          now: DateTime.utc(2026),
        ),
      );

      expect(find.text('Different ruleset'), findsOneWidget);
      expect(find.byTooltip('Clear all'), findsNothing);
    });

    testWidgets('explains items missing from the catalogue', (tester) async {
      final routine = emptyTestRoutine();
      await pumpDbCalculator(
        tester,
        routine: routine.withDb(
          routine.db
              .withElementAdded(
                const DbElement.unknown(id: 'gone', rulesetId: 'test-v1'),
              )
              .withElementAdded(testJump),
        ),
      );

      expect(
        find.textContaining('1 item is no longer in the catalogue'),
        findsOneWidget,
      );
      expect(find.text('Unknown element'), findsOneWidget);
      expect(subtotalText(tester), '0.30');
    });

    testWidgets('shows save status and retries after a failure', (
      tester,
    ) async {
      final routines = await pumpDbCalculator(tester);
      expect(find.byTooltip('Saved'), findsOneWidget);

      routines.saveError = StateError('disk full');
      await addFromCatalogue(tester, 'Test Jump');
      await tester.pump();
      expect(find.byTooltip("Couldn't save. Tap to retry"), findsOneWidget);

      routines.saveError = null;
      await tester.tap(find.byTooltip("Couldn't save. Tap to retry"));
      await tester.pump();
      await tester.pump();

      expect(find.byTooltip('Saved'), findsOneWidget);
      expect(routines.routines[testRoutineId]!.db.elements, [testJump]);
    });
  });
}
