import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_routine.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_controller.dart';

import '../../db_calculator/pump_db_calculator.dart';
import '../pump_da_calculator.dart';
import '../test_data.dart';

void main() {
  String subtotal(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('da-subtotal'))).data!;

  String breakdown(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('da-breakdown'))).data!;

  String preview(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('da-preview-value')),
          matching: find.byType(Text),
        ),
      )
      .data!;

  Future<void> openBuilder(WidgetTester tester) async {
    await tester.tap(find.text('Build a DA'));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// A Hoop routine with [elements] as its DA.
  Future<void> pumpWith(
    WidgetTester tester,
    List<DaElement> elements, {
    Apparatus apparatus = Apparatus.hoop,
    CompetitionLevel? level,
  }) async {
    final routine = emptyTestRoutine()
        .withApparatus(apparatus)
        .withLevel(level);
    await pumpDaCalculator(
      tester,
      routine: routine.withDa(
        DaRoutine(rulesetId: routine.rulesetId, elements: elements),
      ),
    );
  }

  const twoCriteria = {DaCriterion.outsideVisualField, DaCriterion.db};

  testWidgets('needs an apparatus before building DA', (tester) async {
    await pumpDaCalculator(tester, routine: emptyTestRoutine());

    expect(find.text('Choose an apparatus'), findsOneWidget);
    expect(find.text('Build a DA'), findsNothing);

    await tester.tap(find.byTooltip('Edit details'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Hoop');
    await tapText(tester, 'Save');
    expect(find.text('Build a DA'), findsOneWidget);
    expect(find.text('No DA yet'), findsOneWidget);
  });

  testWidgets('builds a DA from a base and 2 criteria', (tester) async {
    final routines = await pumpDaCalculator(tester);
    await openBuilder(tester);

    // Only the routine's apparatus is offered.
    expect(find.text('Test Bounce'), findsNothing);
    await tapText(tester, 'Test Roll');

    // "Under the leg" is N/A for the roll.
    expect(find.text('N/A for this base'), findsOneWidget);
    expect(find.text('Choose 2 more to make it a DA.'), findsOneWidget);
    await tapText(tester, 'Outside the visual field');
    await tapText(tester, 'During a DB');
    expect(find.byKey(const ValueKey('da-criteria-hint')), findsNothing);
    expect(preview(tester), '0.30');

    await tapText(tester, 'Add DA');

    expect(find.text('Test Roll'), findsOneWidget);
    expect(find.text('Outside visual field, DB'), findsOneWidget);
    expect(subtotal(tester), '0.30');
    expect(breakdown(tester), '1 DA');
    expect(
      routines.routines[testRoutineId]!.da.elements.single,
      DaElement(base: testRoll, criteria: twoCriteria),
    );
  });

  testWidgets('a catch can take a 2nd base for + 0.10', (tester) async {
    await pumpDaCalculator(tester);
    await openBuilder(tester);
    await tapText(tester, 'Test Catch');

    await tapText(tester, 'Add a 2nd base');
    // A catch cannot be the 2nd base.
    expect(find.byKey(const ValueKey('da-base-hoop-catch')), findsNothing);
    await tapText(tester, 'Test Roll');
    expect(find.text('Criteria (min. 1, during both bases)'), findsOneWidget);
    expect(find.text('N/A for one of the bases'), findsOneWidget);
    await tapText(tester, 'Rotation (min. 360°)');
    expect(
      find.text('The rotation is a pre-acrobatic element'),
      findsOneWidget,
    );
    expect(preview(tester), '0.40');

    await tapText(tester, 'Add DA');
    expect(find.text('Test Catch + Test Roll'), findsOneWidget);
    expect(subtotal(tester), '0.40');
  });

  testWidgets('shows what is not a DA, not valid or not counted', (
    tester,
  ) async {
    await pumpWith(
      tester,
      [
        DaElement(base: testRoll, criteria: twoCriteria),
        DaElement(base: testRoll, criteria: twoCriteria),
        DaElement(base: testThrow, criteria: const {DaCriterion.db}),
        DaElement(base: testThrow, criteria: twoCriteria),
        DaElement(base: testBallBounce, criteria: twoCriteria),
      ],
      level: const CompetitionLevel.custom(
        LevelRequirements(da: CountLimit(max: 2)),
      ),
    );

    expect(
      find.textContaining('Not valid: identical repetition'),
      findsOneWidget,
    );
    expect(find.textContaining('Not a DA: needs 2 criteria'), findsOneWidget);
    expect(find.textContaining('Not a DA: base for Ball'), findsOneWidget);
    // The repetition uses the 2nd counted DA, so the throw does not count.
    expect(find.textContaining('Not counted'), findsOneWidget);
    expect(find.text('3 DA · 1 not counted (first 2 count)'), findsOneWidget);
    expect(subtotal(tester), '0.30');
    expect(breakdown(tester), '2 of 3 DA counted');
  });

  testWidgets('warns about more than 3 DA in a row on the floor', (
    tester,
  ) async {
    final onFloor = DaElement(
      base: testRoll,
      criteria: const {DaCriterion.positionOnFloor, DaCriterion.db},
    );
    final onFloorThrow = DaElement(
      base: testThrow,
      criteria: const {DaCriterion.positionOnFloor, DaCriterion.db},
    );
    await pumpWith(tester, [
      onFloor,
      onFloorThrow,
      DaElement(
        base: testCatch,
        criteria: const {DaCriterion.positionOnFloor, DaCriterion.db},
      ),
    ]);
    expect(find.byKey(const ValueKey('da-floor-notice')), findsNothing);

    daContainerOf(tester)
        .read(routineControllerProvider(testRoutineId).notifier)
        .updateDa(
          (da) => da.withElementAdded(
            DaElement(
              base: testThrow,
              criteria: const {
                DaCriterion.positionOnFloor,
                DaCriterion.rotation,
              },
            ),
          ),
        );
    await tester.pump();

    expect(find.byKey(const ValueKey('da-floor-notice')), findsOneWidget);
    expect(find.textContaining('4th+ in a row on the floor'), findsOneWidget);
  });

  testWidgets('editing a DA replaces it', (tester) async {
    await pumpWith(tester, [DaElement(base: testRoll, criteria: twoCriteria)]);

    await tapText(tester, 'Test Roll');
    expect(find.text('Edit DA'), findsOneWidget);
    await tapText(tester, 'During a DB');
    await tapText(tester, 'Save');

    expect(find.textContaining('Not a DA: needs 2 criteria'), findsOneWidget);
    expect(subtotal(tester), '0.00');
  });

  testWidgets('adds a DA that is not in the list', (tester) async {
    await pumpDaCalculator(tester);
    await openBuilder(tester);
    await tapText(tester, 'A DA not in the list');

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(fields.evaluate().length - 2), 'My DA');
    await tester.enterText(fields.last, '0.5');
    await tester.pump();
    expect(preview(tester), '0.50');
    await tapText(tester, 'Add DA');

    expect(find.text('My DA'), findsOneWidget);
    expect(subtotal(tester), '0.50');
  });

  testWidgets('freehand counts no FIG DA but keeps them', (tester) async {
    await pumpWith(tester, [
      DaElement(base: testRoll, criteria: twoCriteria),
      DaElement(base: testThrow, manualValue: const Score.hundredths(20)),
    ], apparatus: Apparatus.freehand);

    expect(find.byKey(const ValueKey('da-freehand-notice')), findsOneWidget);
    expect(find.text('Build a DA'), findsNothing);
    expect(find.text('Test Roll'), findsOneWidget);
    expect(subtotal(tester), '0.00');
  });

  testWidgets('freehand DA are added with a name and value', (tester) async {
    await pumpWith(
      tester,
      const [],
      apparatus: Apparatus.freehand,
      level: const CompetitionLevel.custom(
        LevelRequirements(da: CountLimit(max: 1)),
      ),
    );

    for (final (name, value) in [
      ('Illusion', '0.3'),
      ('Pre-acro series', '0.3'),
    ]) {
      await tester.tap(find.text('Add a DA'));
      await tester.pumpAndSettle();
      expect(find.text('A DA not in the list'), findsNothing);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(fields.evaluate().length - 2), name);
      await tester.enterText(fields.last, value);
      await tester.pump();
      expect(preview(tester), '0.30');
      await tapText(tester, 'Add DA');
    }

    expect(find.text('Illusion'), findsOneWidget);
    // The level's freehand maximum applies: only the first counts.
    expect(subtotal(tester), '0.30');
  });

  testWidgets('removing and clearing DA', (tester) async {
    final routines = await pumpDaCalculator(tester);
    final controller = daContainerOf(tester)
        .read(routineControllerProvider(testRoutineId).notifier);
    controller.updateDa(
      (da) => da
          .withElementAdded(DaElement(base: testRoll, criteria: twoCriteria))
          .withElementAdded(
            DaElement(base: testThrow, manualValue: const Score.hundredths(20)),
          ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Remove DA 1'));
    await tester.pumpAndSettle();
    expect(find.text('Test Roll'), findsNothing);
    expect(find.textContaining('Manual value'), findsOneWidget);

    await chooseMenuItem(tester, 'Clear DA');
    await tapText(tester, 'Clear');
    expect(find.text('No DA yet'), findsOneWidget);
    expect(routines.routines[testRoutineId]!.da.elements, isEmpty);
  });

  testWidgets('a DA maximum set in the level picker is checked', (
    tester,
  ) async {
    await pumpDaCalculator(tester);
    await tester.tap(find.byTooltip('Edit details'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Select a level');
    await tapText(tester, 'Non-FIG level');
    await tester.tap(find.byTooltip('Increase DA maximum'));
    await tester.pump();
    await tapText(tester, 'Apply');
    expect(find.text('DA up to 1'), findsOneWidget);
    await tapText(tester, 'Save');

    expect(
      daContainerOf(tester)
          .read(routineProvider(testRoutineId))
          .level
          ?.requirements
          ?.da,
      const CountLimit(max: 1),
    );
    expect(find.text('0 DA · meets the level (up to 1)'), findsOneWidget);
  });
}
