import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/db_element_group.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_routine_providers.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_controller.dart';

import '../../db_calculator/test_data.dart';

import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';

import '../../db_calculator/pump_db_calculator.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpScreen(WidgetTester tester) async {
    await pumpDbCalculator(tester);
    container = containerOf(tester);
  }

  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle();
  }

  Future<void> apply(WidgetTester tester) async {
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
  }

  /// Adds [times] Test Jumps. Repeating an element is not valid, so they
  /// are performed as one series (each element of a series is 1 DB).
  Future<void> addJumps(WidgetTester tester, int times) async {
    final db = container.read(routineProvider(testRoutineId)).db;
    final index = db.elements.indexOf(testJump);
    final controller = container.read(
      routineControllerProvider(testRoutineId).notifier,
    );
    if (index == -1) {
      await tester.tap(find.byTooltip('Add Test Jump'));
      await tester.pump();
      if (times > 1) {
        controller.setElementOptionsAt(
          db.elements.length,
          DbElementOptions(seriesCount: times),
        );
      }
    } else {
      controller.setElementOptionsAt(
        index,
        DbElementOptions(
          seriesCount: db.elementOptions[index].seriesCount + times,
        ),
      );
    }
    await tester.pump();
  }

  // Pump after each tap so the next tap sees the rebuilt stepper.
  Future<void> tapStepper(WidgetTester tester, String tooltip) async {
    await tester.tap(find.byTooltip(tooltip));
    await tester.pump();
  }

  Future<void> addBalance(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Add Test Balance'));
    await tester.pump();
  }

  Future<void> selectCustomLevel(
    WidgetTester tester,
    LevelRequirements requirements,
  ) async {
    container
        .read(routineControllerProvider(testRoutineId).notifier)
        .selectLevel(CompetitionLevel.custom(requirements));
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

  testWidgets('FIG level checks DB against its maximum', (tester) async {
    await pumpScreen(tester);
    await openPicker(tester);

    await tester.tap(find.text('FIG Junior'));
    await tester.pump();
    await apply(tester);

    expect(
      container.read(routineProvider(testRoutineId)).level?.id,
      'fig-junior',
    );
    expect(
      find.text(
        'DB up to 6 · R up to 3 · DA up to 12 · needs leap, balance, rotation',
      ),
      findsOneWidget,
    );
    await addJumps(tester, 7);
    expect(
      noticeText('7 DB · 1 not counted (highest 6 count)'),
      findsOneWidget,
    );
  });

  testWidgets('FIG level has no freehand requirements', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Freehand'));
    await tester.pump();
    await openPicker(tester);
    await tester.tap(find.text('FIG Senior'));
    await tester.pump();
    await apply(tester);

    expect(find.text('No freehand requirements'), findsOneWidget);
    expect(
      noticeText(
        'FIG Senior has no freehand requirements in the app, '
        'so the number of DB is not checked.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('non-FIG level sets maximums for DB, risks and DA', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openPicker(tester);

    await tester.tap(find.text('Non-FIG level'));
    await tester.pumpAndSettle();
    expect(find.text('Minimum'), findsNothing);
    await tapStepper(tester, 'Increase DB maximum');
    await tapStepper(tester, 'Increase DB maximum');
    await tapStepper(tester, 'Increase risks maximum');
    await tapStepper(tester, 'Increase DA maximum');
    await apply(tester);

    expect(
      container.read(routineProvider(testRoutineId)).level?.requirements,
      const LevelRequirements(
        db: CountLimit(max: 2),
        risk: CountLimit(max: 1),
        da: CountLimit(max: 1),
      ),
    );
    expect(find.text('DB up to 2 · R up to 1 · DA up to 1'), findsOneWidget);

    await addJumps(tester, 2);
    expect(noticeText('2 DB · meets the level (up to 2)'), findsOneWidget);

    await addJumps(tester, 1);
    expect(
      noticeText('3 DB · 1 not counted (highest 2 count)'),
      findsOneWidget,
    );
  });

  testWidgets('minimums are optional and checked when added', (tester) async {
    await pumpScreen(tester);
    await openPicker(tester);

    await tester.tap(find.text('Non-FIG level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add minimums'));
    await tester.pump();
    await tapStepper(tester, 'Increase DB minimum');
    await apply(tester);

    expect(noticeText('0 DB · 1 more needed (at least 1)'), findsOneWidget);
  });

  testWidgets('removing minimums clears them', (tester) async {
    await pumpScreen(tester);
    await selectCustomLevel(
      tester,
      const LevelRequirements(db: CountLimit(min: 1, max: 4)),
    );
    await openPicker(tester);

    // Shown because a minimum is already set.
    expect(find.text('Remove minimums'), findsOneWidget);
    await tester.tap(find.text('Remove minimums'));
    await tester.pump();
    await apply(tester);

    expect(
      container.read(routineProvider(testRoutineId)).level?.requirements,
      const LevelRequirements(db: CountLimit(max: 4)),
    );
  });

  testWidgets('minimum above maximum disables Apply', (tester) async {
    await pumpScreen(tester);
    await openPicker(tester);

    await tester.tap(find.text('Non-FIG level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add minimums'));
    await tester.pump();
    await tapStepper(tester, 'Increase DB minimum');
    await tapStepper(tester, 'Increase DB minimum');
    await tapStepper(tester, 'Increase DB maximum');

    expect(find.text('Minimum cannot be more than maximum'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Apply'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('required body groups are chosen with chips', (tester) async {
    await pumpScreen(tester);
    await openPicker(tester);

    await tester.tap(find.text('Non-FIG level'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Balances'));
    await tester.pump();
    expect(find.textContaining("Check your level's rules"), findsOneWidget);
    await apply(tester);

    expect(
      container
          .read(routineProvider(testRoutineId))
          .level
          ?.requirements
          ?.requiredBodyGroups,
      {DbElementGroup.balance},
    );
  });

  testWidgets('freehand hides risk and DA limits in the picker', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Freehand'));
    await tester.pump();
    await openPicker(tester);
    await tester.tap(find.text('Non-FIG level'));
    await tester.pumpAndSettle();

    expect(find.text('Body difficulties (DB)'), findsOneWidget);
    expect(find.text('Risks (R)'), findsNothing);
    expect(find.text('Apparatus difficulties (DA)'), findsNothing);
  });

  Finder groupAlert(String text) => find.descendant(
    of: find.byKey(const ValueKey('body-groups-notice')),
    matching: find.text(text),
  );

  testWidgets('missing required group shows a penalty alert', (tester) async {
    await pumpScreen(tester);
    await selectCustomLevel(
      tester,
      const LevelRequirements(
        db: CountLimit(max: 1),
        requiredBodyGroups: {DbElementGroup.jump, DbElementGroup.balance},
      ),
    );

    expect(
      groupAlert(
        'No leap or balance in the routine. Your level requires one of '
        'each: you may get a penalty.',
      ),
      findsOneWidget,
    );

    await addJumps(tester, 1);
    expect(
      groupAlert(
        'No balance in the routine. Your level requires one: '
        'you may get a penalty.',
      ),
      findsOneWidget,
    );

    // The balance (0.20) is lower than the jump (0.30), so with a maximum
    // of 1 it is not counted; performing it still meets the requirement.
    await addBalance(tester);
    expect(find.byKey(const ValueKey('body-groups-notice')), findsNothing);
  });

  testWidgets('FIG alert names the penalty for each missing group', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openPicker(tester);
    await tester.tap(find.text('FIG Senior'));
    await tester.pump();
    await apply(tester);
    await addJumps(tester, 1);

    expect(
      groupAlert(
        'No balance or rotation in the routine. Your level requires one of '
        'each: you may get a 0.30 penalty for each.',
      ),
      findsOneWidget,
    );

    await addBalance(tester);
    expect(
      groupAlert(
        'No rotation in the routine. Your level requires one: '
        'you may get a 0.30 penalty.',
      ),
      findsOneWidget,
    );
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

    expect(
      container.read(routineProvider(testRoutineId)).level?.id,
      'fig-junior',
    );
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

    expect(container.read(routineProvider(testRoutineId)).level, isNull);
    expect(find.text('Select a level'), findsOneWidget);
  });

  testWidgets('reopening a non-FIG level keeps its numbers', (tester) async {
    await pumpScreen(tester);
    container
        .read(routineControllerProvider(testRoutineId).notifier)
        .selectLevel(
          const CompetitionLevel.custom(
            LevelRequirements(da: CountLimit(max: 3)),
          ),
        );
    await tester.pump();

    await openPicker(tester);

    // The DA maximum stepper shows the saved value.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Apparatus difficulties (DA)'), findsOneWidget);
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

    expect(
      container.read(routineProvider(testRoutineId)).level?.id,
      'fig-senior',
    );
  });
}
