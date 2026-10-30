import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';

import '../../db_calculator/pump_db_calculator.dart';

void main() {
  String countText(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('dance-step-count'))).data!;

  Finder notice(String text) => find.descendant(
    of: find.byKey(const ValueKey('dance-steps-notice')),
    matching: find.text(text),
  );

  testWidgets('the stepper changes and saves the count', (tester) async {
    final routines = await pumpDbCalculator(tester);

    expect(countText(tester), '0');
    final decrease = find.byTooltip('Remove a dance steps combination');
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(of: decrease, matching: find.byType(IconButton)),
          )
          .onPressed,
      isNull,
    );

    // Pump after each tap so the next tap sees the new count.
    await tester.tap(find.byTooltip('Add a dance steps combination'));
    await tester.pump();
    await tester.tap(find.byTooltip('Add a dance steps combination'));
    await tester.pump();
    await tester.tap(decrease);
    await tester.pump();

    expect(countText(tester), '1');
    expect((await routines.fetchRoutine(testRoutineId))!.danceStepCount, 1);
  });

  testWidgets('no level shows no notice', (tester) async {
    await pumpDbCalculator(tester);

    expect(find.byKey(const ValueKey('dance-steps-notice')), findsNothing);
  });

  testWidgets('FIG levels need at least 2 S', (tester) async {
    await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withLevel(figSenior).withDanceStepCount(1),
    );

    expect(
      notice('1 S · 1 more needed (at least 2): you may get a penalty.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Add a dance steps combination'));
    await tester.pump();

    expect(notice('2 S · meets the level (at least 2)'), findsOneWidget);
  });

  testWidgets('a non-FIG level without an S minimum shows no notice', (
    tester,
  ) async {
    await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withLevel(
        const CompetitionLevel.custom(
          LevelRequirements(db: CountLimit(max: 6)),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('dance-steps-notice')), findsNothing);
  });
}
