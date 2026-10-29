import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/element_picker_screen.dart';

import '../pump_db_calculator.dart';
import '../test_data.dart';

void main() {
  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(ElementPickerScreen),
        matching: find.byType(TextField),
      ),
      text,
    );
    await tester.pump();
  }

  test('search matches every word in the name or family', () {
    expect(matchesQuery(testJump, 'test'), isTrue);
    expect(matchesQuery(testJump, 'JUMP test'), isTrue);
    expect(matchesQuery(testJump, 'jumps'), isTrue); // Family.
    expect(matchesQuery(testJump, 'jump balance'), isFalse);
    expect(matchesQuery(testJump, '   '), isTrue);
  });

  testWidgets('shows one body group at a time, by catalogue row', (
    tester,
  ) async {
    await pumpDbCalculator(tester);
    await openElementPicker(tester);

    // Jumps first.
    expect(find.text('1 · Test jumps'), findsOneWidget);
    expect(find.text('Test Jump'), findsOneWidget);
    expect(find.text('Test Balance'), findsNothing);

    await tester.tap(find.text('Balances'));
    await tester.pumpAndSettle();
    expect(find.text('1 · Test balances'), findsOneWidget);
    expect(find.text('Test Balance'), findsOneWidget);
    expect(find.text('Test Jump'), findsNothing);
  });

  testWidgets('reopens on the body group shown last', (tester) async {
    await pumpDbCalculator(tester);
    await openElementPicker(tester);
    await tester.tap(find.text('Balances'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await openElementPicker(tester);
    expect(find.text('Test Balance'), findsOneWidget);
    expect(find.text('Test Jump'), findsNothing);
  });

  testWidgets('search narrows the selected group', (tester) async {
    await pumpDbCalculator(tester);
    await openElementPicker(tester);

    // "t" matches every test element, but only jumps are shown.
    await search(tester, 't');
    expect(find.text('Test Jump'), findsOneWidget);
    expect(find.text('Test Rotation'), findsNothing);

    await tester.tap(find.text('Rotations'));
    await tester.pumpAndSettle();
    expect(find.text('Test Rotation'), findsOneWidget);
    expect(find.text('Test Jump'), findsNothing);
  });

  testWidgets('no match in the group points to other groups', (tester) async {
    await pumpDbCalculator(tester);
    await openElementPicker(tester);

    await search(tester, 'balance');
    expect(find.text('No matches in Jumps / Leaps'), findsOneWidget);
    expect(find.text('Found in: Balances (1)'), findsOneWidget);

    await search(tester, 'nothing like this');
    expect(
      find.text('Try another word or code, or add it yourself below.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('Test Jump'), findsOneWidget);
  });

  testWidgets('adds several elements and marks those in the routine', (
    tester,
  ) async {
    final routines = await pumpDbCalculator(tester);
    await openElementPicker(tester);

    await tester.tap(find.byTooltip('Add Test Jump'));
    await tester.pump();
    expect(find.text('Added Test Jump'), findsOneWidget);
    expect(find.text('In your routine'), findsOneWidget);

    await tester.tap(find.text('Rotations'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add Test Rotation'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(routines.routines[testRoutineId]!.db.elements, [
      testJump,
      testRotation,
    ]);
    expect(find.text('Added Test Rotation'), findsNothing);
  });
}
