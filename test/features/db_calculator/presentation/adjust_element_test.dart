import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/widgets/adjust_element_sheet.dart';

import '../../routines/fake_routine_repository.dart';
import '../pump_db_calculator.dart';
import '../test_data.dart';

void main() {
  String subtotal(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('db-subtotal'))).data!;

  String preview(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('adjust-preview-value')),
          matching: find.byType(Text),
        ),
      )
      .data!;

  Future<void> add(WidgetTester tester, String name) async {
    await addFromCatalogue(tester, name);
  }

  Future<void> openAdjust(WidgetTester tester, int index) async {
    await tester.tap(find.byKey(ValueKey('selected-$index')));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('a balance can be set to flat foot with slow turn', (
    tester,
  ) async {
    final routines = await pumpDbCalculator(tester);
    await add(tester, 'Test Balance');
    await openAdjust(tester, 0);

    expect(find.text('Catalogue value 0.20'), findsOneWidget);
    await tester.tap(find.text('Flat foot (-0.10)'));
    await tester.pump();
    expect(preview(tester), '0.10');
    expect(find.text('+0.10 on flat foot'), findsOneWidget);

    await tester.tap(find.text('Slow turn'));
    await tester.pump();
    expect(preview(tester), '0.20');
    await save(tester);

    expect(find.text('Balances · Flat foot · Slow turn'), findsOneWidget);
    expect(subtotal(tester), '0.20');
    expect(
      routines.routines[testRoutineId]!.db.elementOptions.single,
      const DbElementOptions(flatFoot: true, slowTurn: true),
    );
  });

  testWidgets('a rotation is set by its total rotation', (tester) async {
    await pumpDbCalculator(tester);
    await add(tester, 'Test Rotation');
    await openAdjust(tester, 0);

    String total() =>
        tester.widget<Text>(find.byKey(const ValueKey('total-rotation'))).data!;
    expect(total(), '1');
    expect(find.text('360° · +0.10 for each after the first'), findsOneWidget);
    expect(find.text('Slow turn'), findsNothing);
    await tester.tap(find.byTooltip('More rotations'));
    await tester.tap(find.byTooltip('More rotations'));
    await tester.pump();
    expect(total(), '3');
    expect(find.text('1080° · +0.10 for each after the first'), findsOneWidget);
    expect(preview(tester), '0.30');
    await save(tester);

    expect(find.text('Rotations · 3 rotations'), findsOneWidget);
    expect(subtotal(tester), '0.30');
  });

  testWidgets('a manual value replaces the calculated one', (tester) async {
    await pumpDbCalculator(tester);
    await add(tester, 'Test Jump');
    await openAdjust(tester, 0);

    await tester.tap(find.text('Set value manually'));
    await tester.pump();
    // Save waits for a valid value.
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField).last, '0.4.');
    await tester.pump();
    expect(find.text('Enter a value like 0.40'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '0.45');
    await tester.pump();
    expect(preview(tester), '0.45');
    await save(tester);

    expect(find.text('Jumps / Leaps · Manual value'), findsOneWidget);
    expect(subtotal(tester), '0.45');
  });

  testWidgets('dismissing the adjust sheet changes nothing', (tester) async {
    await pumpDbCalculator(tester);
    await add(tester, 'Test Balance');
    await openAdjust(tester, 0);
    await tester.tap(find.text('Flat foot (-0.10)'));
    await tester.tapAt(const Offset(10, 10)); // Tap the barrier.
    await tester.pumpAndSettle();

    expect(subtotal(tester), '0.20');
  });

  testWidgets('an element not in the list can be added', (tester) async {
    final routines = await pumpDbCalculator(tester);

    await openElementPicker(tester);
    await tester.tap(find.text('Add an element not in the list'));
    await tester.pumpAndSettle();
    final addButton = find.widgetWithText(FilledButton, 'Add element');
    expect(tester.widget<FilledButton>(addButton).onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'New pivot');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Rotations'));
    await tester.enterText(find.widgetWithText(TextField, 'Value'), '0.6');
    await tester.pump();
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    // The picker stays open for more elements.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('New pivot'), findsOneWidget);
    expect(find.text('Rotations · Custom element'), findsOneWidget);
    expect(subtotal(tester), '0.60');
    final db = routines.routines[testRoutineId]!.db;
    expect(db.elements.single.isCustom, isTrue);
    expect(db.elements.single.group, DbElementGroup.rotation);
    expect(db.elementOptions.single.manualValue, const Score.hundredths(60));
  });

  testWidgets('a jump can be performed in a series', (tester) async {
    final routines = await pumpDbCalculator(tester);
    await add(tester, 'Test Jump');
    await openAdjust(tester, 0);

    expect(find.text('Performed in a series of'), findsOneWidget);
    await tester.tap(find.byTooltip('Longer series'));
    await tester.tap(find.byTooltip('Longer series'));
    await tester.pump();
    expect(find.text('Value (3 × 0.30)'), findsOneWidget);
    expect(preview(tester), '0.90');
    await save(tester);

    expect(find.text('Jumps / Leaps · Series of 3'), findsOneWidget);
    expect(subtotal(tester), '0.90');
    expect(
      routines.routines[testRoutineId]!.db.elementOptions.single.seriesCount,
      3,
    );
  });

  testWidgets('a balance has no series option', (tester) async {
    await pumpDbCalculator(tester);
    await add(tester, 'Test Balance');
    await openAdjust(tester, 0);

    expect(find.text('Performed in a series of'), findsNothing);
  });

  testWidgets('a repeated element is marked not valid', (tester) async {
    await pumpDbCalculator(tester);
    await add(tester, 'Test Jump');
    await add(tester, 'Test Jump');

    expect(find.text('Jumps / Leaps · Not valid: repetition'), findsOneWidget);
    expect(subtotal(tester), '0.30');

    // A manual value makes it count, for levels that allow repetitions.
    await openAdjust(tester, 1);
    expect(find.byKey(const ValueKey('repetition-note')), findsOneWidget);
    await tester.tap(find.text('Set value manually'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '0.30');
    await tester.pump();
    await save(tester);

    expect(find.textContaining('repetition'), findsNothing);
    expect(subtotal(tester), '0.60');
  });

  test('rotation summary: count for 360° bases, degrees for 180° bases', () {
    const halfTurn = DbElement(
      id: 'half',
      name: 'Half turn base',
      group: DbElementGroup.rotation,
      value: Score.hundredths(50),
      rulesetId: 'test-v1',
      extraRotationValue: Score.hundredths(20),
      baseRotationDegrees: 180,
    );

    expect(describeRotation(testRotation, 0), '1 rotation');
    expect(describeRotation(testRotation, 9), '10 rotations');
    expect(describeRotation(halfTurn, 1), '540°');
    expect(
      describeOptions(halfTurn, const DbElementOptions(extraRotations: 2)),
      '900°',
    );
  });

  group('Fouetté cycles', () {
    const fouette = DbElement(
      id: 'fouette',
      name: 'Test Fouetté',
      group: DbElementGroup.rotation,
      value: Score.hundredths(10),
      rulesetId: 'test-v1',
      extraRotationValue: Score.hundredths(10),
      canHaveCycles: true,
      symbolPath: 'M10 10L90 90',
    );

    Future<FakeRoutineRepository> openFouette(WidgetTester tester) async {
      final empty = emptyTestRoutine();
      final routines = await pumpDbCalculator(
        tester,
        routine: empty.withDb(empty.db.withElementAdded(fouette)),
      );
      await tester.tap(find.byKey(const ValueKey('selected-0')));
      await tester.pumpAndSettle();
      return routines;
    }

    testWidgets('cycles set the rotations and are saved', (tester) async {
      final routines = await openFouette(tester);

      await tester.enterText(
        find.byKey(const ValueKey('rotation-cycles')),
        '2121',
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('rotation-cycles')), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final options =
          routines.routines[testRoutineId]!.db.elementOptions.single;
      expect(options.rotationCycles, '2121');
      expect(options.extraRotations, 5);
      expect(find.text('2121'), findsOneWidget);
    });

    testWidgets('warns beyond 10 cycles', (tester) async {
      await openFouette(tester);

      await tester.enterText(
        find.byKey(const ValueKey('rotation-cycles')),
        '11111111111',
      );
      await tester.pump();

      expect(find.text('Only the first 10 cycles count'), findsOneWidget);
    });

    testWidgets('other rotations have no cycles', (tester) async {
      final empty = emptyTestRoutine();
      await pumpDbCalculator(
        tester,
        routine: empty.withDb(empty.db.withElementAdded(testRotation)),
      );
      await tester.tap(find.byKey(const ValueKey('selected-0')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('rotation-cycles')), findsNothing);
    });
  });
}
