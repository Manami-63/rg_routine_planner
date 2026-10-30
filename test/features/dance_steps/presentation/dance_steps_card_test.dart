import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/pump_db_calculator.dart';
import '../../db_calculator/test_data.dart';

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
      notice(
        '1 S · 1 more needed (at least 2): you may get a 0.30 penalty for each.',
      ),
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

  testWidgets('warns when a DA or a 0.20+ DB is marked during an S', (
    tester,
  ) async {
    final empty = emptyTestRoutine();
    final routine = empty
        .withDb(
          empty.db
              .withElementAdded(testJump)
              .withElementAdded(testRotation)
              .withElementTimeAt(0, const Duration(seconds: 12))
              .withElementTimeAt(1, const Duration(seconds: 13)),
        )
        .withDa(
          empty.da
              .withElementAdded(DaElement(base: testRoll))
              .withElementTimeAt(0, const Duration(seconds: 15)),
        )
        .withDanceStepCount(2)
        .withDanceStepTimeAt(0, const Duration(seconds: 10));
    await pumpDbCalculator(tester, routine: routine);

    // The 0.10 rotation is allowed; the unmarked 2nd S is not checked.
    expect(
      find.text(
        'S 1 may not be valid: DA 1, DB 1 (0.30) are marked during it. '
        'Risks, DA and DB worth 0.20 or more are not allowed in an S '
        '(CoP #5.2.5).',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('dance-step-conflict-1')), findsNothing);
  });
}
