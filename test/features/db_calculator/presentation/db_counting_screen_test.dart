import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../pump_db_calculator.dart';
import '../test_data.dart';

// Counting under a level's maximums, apparatus choice and freehand.
void main() {
  Routine routineWith({
    Apparatus? apparatus,
    LevelRequirements? requirements,
    List<DbElement> elements = const [],
    int risks = 0,
  }) {
    final empty = emptyTestRoutine();
    return empty
        .withApparatus(apparatus)
        .withLevel(
          requirements == null ? null : CompetitionLevel.custom(requirements),
        )
        .withDb(
          DbRoutine(
            rulesetId: testRuleset.id,
            elements: elements,
            risks: [
              for (var i = 0; i < risks; i++)
                RiskElement(rotation: testTwoRotations),
            ],
          ),
        );
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(ValueKey(key))).data!;

  testWidgets('elements over the maximum are marked not counted', (
    tester,
  ) async {
    await pumpDbCalculator(
      tester,
      routine: routineWith(
        requirements: const LevelRequirements(db: CountLimit(max: 2)),
        // 0.10, 0.30, 0.20: the rotation is the lowest.
        elements: const [testRotation, testJump, testBalance],
      ),
    );

    expect(find.text('Rotations · Not counted'), findsOneWidget);
    expect(find.text('Jumps / Leaps'), findsWidgets);
    expect(text(tester, 'db-subtotal'), '0.50');
    expect(text(tester, 'db-breakdown'), 'Body 0.50 (2 of 3) · Risks 0.00');
    expect(find.textContaining('Only count limits applied'), findsOneWidget);

    // Uncounted elements can still be removed.
    await tester.tap(find.byTooltip('Remove Test Rotation'));
    await tester.pump();
    expect(find.textContaining('Not counted'), findsNothing);
    expect(text(tester, 'db-breakdown'), 'Body 0.50 · Risks 0.00');
  });

  testWidgets('risks over the maximum are allowed but not counted', (
    tester,
  ) async {
    await pumpDbCalculator(
      tester,
      routine: routineWith(
        apparatus: Apparatus.hoop,
        requirements: const LevelRequirements(risk: CountLimit(max: 1)),
        risks: 2,
      ),
    );
    await tester.tap(find.text('Risks'));
    await tester.pumpAndSettle();

    expect(find.text('Build a risk'), findsOneWidget);
    expect(
      find.text('2 risks · 1 not counted (first 1 count)'),
      findsOneWidget,
    );
    expect(find.text('Not counted'), findsOneWidget);
    expect(text(tester, 'db-breakdown'), 'Body 0.00 · Risks 0.20 (1 of 2)');
  });

  testWidgets('choosing an apparatus saves it', (tester) async {
    final routines = await pumpDbCalculator(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Rope'));
    await tester.pump();

    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Rope'),
    );
    expect(chip.selected, isTrue);
    expect(routines.routines[testRoutineId]!.apparatus, Apparatus.rope);
  });

  testWidgets('freehand has no risks: none can be built or counted', (
    tester,
  ) async {
    await pumpDbCalculator(
      tester,
      routine: routineWith(apparatus: Apparatus.freehand, risks: 1),
    );
    await tester.tap(find.text('Risks'));
    await tester.pumpAndSettle();

    expect(find.text('No risks in freehand'), findsOneWidget);
    expect(find.text('Build a risk'), findsNothing);
    // The existing risk is kept, but not counted.
    expect(find.text('Not counted'), findsOneWidget);
    expect(text(tester, 'db-breakdown'), 'Body 0.00 · Risks 0.00 (0 of 1)');
  });

  testWidgets('part of a series can be left out by the maximum', (
    tester,
  ) async {
    final base = routineWith(
      requirements: const LevelRequirements(db: CountLimit(max: 2)),
    );
    await pumpDbCalculator(
      tester,
      routine: base.withDb(
        DbRoutine(
          rulesetId: testRuleset.id,
          elements: const [testJump],
          elementOptions: const [DbElementOptions(seriesCount: 3)],
        ),
      ),
    );

    expect(
      find.text('Jumps / Leaps · Series of 3 · 2 of 3 counted'),
      findsOneWidget,
    );
    expect(text(tester, 'db-breakdown'), 'Body 0.60 (2 of 3) · Risks 0.00');
    expect(find.text('3 DB · 1 not counted (highest 2 count)'), findsOneWidget);
  });
}
