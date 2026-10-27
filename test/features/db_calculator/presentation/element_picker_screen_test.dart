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

  testWidgets('search looks in every group', (tester) async {
    await pumpDbCalculator(tester);
    await openElementPicker(tester);

    await search(tester, 'rotation');
    expect(find.text('Test Rotation'), findsOneWidget);
    // The group choice is hidden while searching.
    expect(find.text('Balances'), findsNothing);

    await search(tester, 'nothing like this');
    expect(find.text('No matching elements'), findsOneWidget);

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
