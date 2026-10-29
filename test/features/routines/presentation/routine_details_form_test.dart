import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_details_form.dart';

import '../../da_calculator/test_data.dart';

void main() {
  final hoopRoutine = Routine.create(
    id: 'r1',
    rulesetId: 'test-v1',
    now: DateTime.utc(2026, 10, 29),
  ).rename('Hoop').withApparatus(Apparatus.hoop).withLevel(figSenior);

  /// Pumps a button that opens the form with [open] and returns a getter
  /// for its result.
  Future<RoutineDetails? Function()> pumpForm(
    WidgetTester tester,
    Future<RoutineDetails?> Function(BuildContext context) open,
  ) async {
    RoutineDetails? result;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await open(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return () => result;
  }

  TextButton button(WidgetTester tester, String label) =>
      tester.widget<TextButton>(find.widgetWithText(TextButton, label));

  testWidgets('a new routine needs an apparatus', (tester) async {
    final result = await pumpForm(tester, RoutineDetailsForm.create);

    expect(find.text('New routine'), findsOneWidget);
    expect(button(tester, 'Create').onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  Ribbon final ');
    await tester.tap(find.text('Ribbon'));
    await tester.pump();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(result()?.name, 'Ribbon final');
    expect(result()?.apparatus, Apparatus.ribbon);
    expect(result()?.level, isNull);
  });

  testWidgets('closing the form returns nothing', (tester) async {
    final result = await pumpForm(
      tester,
      (context) => RoutineDetailsForm.edit(context, hoopRoutine),
    );

    await tester.enterText(find.byType(TextField), 'Changed');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(result(), isNull);
  });

  testWidgets('editing starts from the routine and returns the changes', (
    tester,
  ) async {
    final result = await pumpForm(
      tester,
      (context) => RoutineDetailsForm.edit(context, hoopRoutine),
    );

    expect(find.text('Edit routine'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Hoop'), findsOneWidget);
    expect(find.text('FIG Senior'), findsOneWidget);

    await tester.tap(find.text('Ball'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final details = result()!;
    expect(details.name, 'Hoop');
    expect(details.apparatus, Apparatus.ball);
    expect(details.level, figSenior);
    final updated = details.applyTo(hoopRoutine);
    expect(updated.apparatus, Apparatus.ball);
    expect(updated.id, hoopRoutine.id);
  });

  testWidgets('warns when the apparatus changes on a routine with DA', (
    tester,
  ) async {
    final withDa = hoopRoutine.withDa(
      hoopRoutine.da.withElementAdded(DaElement(base: testRoll)),
    );
    await pumpForm(
      tester,
      (context) => RoutineDetailsForm.edit(context, withDa),
    );
    final note = find.byKey(const ValueKey('apparatus-change-note'));

    expect(note, findsNothing);
    await tester.tap(find.text('Ball'));
    await tester.pump();
    expect(
      find.text(
        'DA and risk criteria for Hoop may not count for Ball. They are '
        'kept, not deleted.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Freehand'));
    await tester.pump();
    expect(find.textContaining('Freehand routines have no risks'), findsOne);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Hoop'));
    await tester.pump();
    expect(note, findsNothing);
  });

  testWidgets('no warning for a routine without risks or DA', (tester) async {
    await pumpForm(
      tester,
      (context) => RoutineDetailsForm.edit(context, hoopRoutine),
    );

    await tester.tap(find.text('Ball'));
    await tester.pump();

    expect(find.byKey(const ValueKey('apparatus-change-note')), findsNothing);
  });

  test('display name and details line', () {
    expect(routineDisplayName(' '), 'Untitled routine');
    expect(routineDisplayName('Hoop'), 'Hoop');
    expect(describeRoutineDetails(null, null), 'No apparatus · No level');
    expect(
      describeRoutineDetails(Apparatus.hoop, figSenior),
      'Hoop · FIG Senior',
    );
  });
}
