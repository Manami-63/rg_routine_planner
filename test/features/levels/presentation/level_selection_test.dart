import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_screen.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_controller.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';

import '../../db_calculator/test_data.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbCatalogueRepositoryProvider.overrideWithValue(
            FakeDbCatalogueRepository(),
          ),
        ],
        child: const MaterialApp(home: DbCalculatorScreen()),
      ),
    );
    await tester.pump();
    container = ProviderScope.containerOf(
      tester.element(find.byType(DbCalculatorScreen)),
    );
  }

  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle();
  }

  Future<void> apply(WidgetTester tester) async {
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
  }

  Future<void> addJumps(WidgetTester tester, int times) async {
    for (var i = 0; i < times; i++) {
      await tester.tap(find.byTooltip('Add Test Jump'));
      await tester.pump();
    }
  }

  // Pump after each tap so the next tap sees the rebuilt stepper.
  Future<void> tapStepper(WidgetTester tester, String tooltip) async {
    await tester.tap(find.byTooltip(tooltip));
    await tester.pump();
  }

  Finder noticeText(String text) => find.descendant(
    of: find.byKey(const ValueKey('count-limit-notice')),
    matching: find.text(text),
  );

  testWidgets('no level selected shows no count notice', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Select a level'), findsOneWidget);
    expect(find.byKey(const ValueKey('count-limit-notice')), findsNothing);
  });

  testWidgets('FIG level without data says requirements are not added', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openPicker(tester);

    await tester.tap(find.text('FIG Senior'));
    await tester.pump();
    await apply(tester);

    expect(container.read(routineControllerProvider).level?.id, 'fig-senior');
    expect(find.text('FIG Senior'), findsOneWidget);
    expect(
      noticeText(
        'Official FIG Senior requirements are not in the app yet, '
        'so the number of DB is not checked.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('non-FIG level checks the number of DB', (tester) async {
    await pumpScreen(tester);
    await openPicker(tester);

    await tester.tap(find.text('Non-FIG level'));
    await tester.pumpAndSettle();
    await tapStepper(tester, 'Increase DB minimum');
    await tapStepper(tester, 'Increase DB maximum');
    await tapStepper(tester, 'Increase DB maximum');
    await tester.pump();
    await apply(tester);

    expect(
      container.read(routineControllerProvider).level?.requirements,
      const LevelRequirements(db: CountLimit(min: 1, max: 2)),
    );
    expect(find.text('DB 1–2'), findsOneWidget);
    expect(noticeText('0 DB · 1 more needed (1–2)'), findsOneWidget);

    await addJumps(tester, 2);
    expect(noticeText('2 DB · meets the level (1–2)'), findsOneWidget);

    await addJumps(tester, 1);
    expect(noticeText('3 DB · 1 over the limit (1–2)'), findsOneWidget);
  });

  testWidgets('minimum above maximum disables Apply', (tester) async {
    await pumpScreen(tester);
    await openPicker(tester);

    await tester.tap(find.text('Non-FIG level'));
    await tester.pumpAndSettle();
    await tapStepper(tester, 'Increase DB minimum');
    await tapStepper(tester, 'Increase DB minimum');
    await tapStepper(tester, 'Increase DB maximum');
    await tester.pump();

    expect(find.text('Minimum cannot be more than maximum'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Apply'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('dismissing the picker keeps the previous level', (tester) async {
    await pumpScreen(tester);
    await openPicker(tester);
    await tester.tap(find.text('FIG Junior'));
    await tester.pump();
    await apply(tester);

    await openPicker(tester);
    await tester.tap(find.text('FIG Senior'));
    await tester.pump();
    await tester.tapAt(const Offset(10, 10)); // Tap the barrier.
    await tester.pumpAndSettle();

    expect(container.read(routineControllerProvider).level?.id, 'fig-junior');
  });

  testWidgets('remove level clears the selection', (tester) async {
    await pumpScreen(tester);
    await openPicker(tester);
    await tester.tap(find.text('FIG Junior'));
    await tester.pump();
    await apply(tester);

    await openPicker(tester);
    await tester.tap(find.text('Remove level'));
    await tester.pumpAndSettle();

    expect(container.read(routineControllerProvider).level, isNull);
    expect(find.text('Select a level'), findsOneWidget);
  });

  testWidgets('reopening a non-FIG level keeps its numbers', (tester) async {
    await pumpScreen(tester);
    container
        .read(routineControllerProvider.notifier)
        .selectLevel(
          const CompetitionLevel.custom(
            LevelRequirements(da: CountLimit(max: 3)),
          ),
        );
    await tester.pump();

    await openPicker(tester);

    // The DA maximum stepper shows the saved value.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Number of DA'), findsOneWidget);
  });

  testWidgets('clear all keeps the level', (tester) async {
    await pumpScreen(tester);
    await openPicker(tester);
    await tester.tap(find.text('FIG Senior'));
    await tester.pump();
    await apply(tester);
    await addJumps(tester, 1);

    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(container.read(routineControllerProvider).level?.id, 'fig-senior');
  });
}
