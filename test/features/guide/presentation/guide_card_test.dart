import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/guide/domain/guide.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';

import '../../db_calculator/pump_db_calculator.dart';
import '../fake_guide_store.dart';

void main() {
  GuideSettings guiding(GuidePath path) => GuideSettings(
    active: GuideProgress(routineId: testRoutineId, path: path),
  );

  final card = find.byKey(const ValueKey('guide-card'));

  testWidgets('nothing shows when the routine is not guided', (tester) async {
    await pumpDbCalculator(tester);
    expect(card, findsNothing);

    await pumpDbCalculator(
      tester,
      guide: const GuideSettings(
        active: GuideProgress(routineId: 'other', path: GuidePath.music),
      ),
    );
    expect(card, findsNothing);
  });

  testWidgets('the difficulties path follows the routine', (tester) async {
    final store = FakeGuideStore();
    await pumpDbCalculator(
      tester,
      guide: guiding(GuidePath.difficulties),
      guideStore: store,
    );

    expect(find.text('Step 1 of 6 · Add your first DB'), findsOneWidget);
    await addFromCatalogue(tester, 'Test Jump');
    expect(find.text('Step 2 of 6 · Your provisional total'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('Step 3 of 6 · Add a DA'), findsOneWidget);
    expect(find.text('Open the DA tab to continue.'), findsOneWidget);
    expect(store.saved.active!.tapped, {GuideStep.total});

    await tester.tap(find.text('Go to DA'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tap Build a DA, then choose a base and its criteria.'),
      findsOneWidget,
    );
    expect(find.text('Go to DA'), findsNothing);
  });

  testWidgets('folds to one line until the next step', (tester) async {
    await pumpDbCalculator(tester, guide: guiding(GuidePath.difficulties));
    final message = find.textContaining('Tap Add element');

    await tester.tap(find.byTooltip('Fold the guide'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 6 · Add your first DB'), findsOneWidget);
    expect(message, findsNothing);

    await tester.tap(find.byTooltip('Show the step'));
    await tester.pumpAndSettle();
    expect(message, findsOneWidget);

    // Folded again, then the step is done: the next one shows unfolded.
    await tester.tap(find.byTooltip('Fold the guide'));
    await tester.pumpAndSettle();
    await addFromCatalogue(tester, 'Test Jump');
    expect(find.text('Step 2 of 6 · Your provisional total'), findsOneWidget);
    expect(find.textContaining('The bar at the bottom'), findsOneWidget);
  });

  testWidgets('the music path opens the Music tab', (tester) async {
    await pumpDbCalculator(tester, guide: guiding(GuidePath.music));

    expect(find.text('Step 1 of 5 · Add your music'), findsOneWidget);
    await tester.tap(find.text('Go to Music'));
    await tester.pumpAndSettle();

    final tabs = DefaultTabController.of(tester.element(card));
    expect(tabs.index, RoutineTab.music.index);
    expect(find.textContaining('Tap Add music'), findsOneWidget);
  });

  testWidgets('closing ends the guide but keeps it on', (tester) async {
    final store = FakeGuideStore();
    await pumpDbCalculator(
      tester,
      guide: guiding(GuidePath.music),
      guideStore: store,
    );

    await tester.tap(find.byTooltip('Close the guide'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Close'));
    await tester.pumpAndSettle();

    expect(card, findsNothing);
    expect(store.saved, const GuideSettings());
  });

  testWidgets('Turn off ends the guide for new routines too', (tester) async {
    final store = FakeGuideStore();
    await pumpDbCalculator(
      tester,
      guide: guiding(GuidePath.music),
      guideStore: store,
    );

    await tester.tap(find.byTooltip('Close the guide'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn off'));
    await tester.pumpAndSettle();

    expect(card, findsNothing);
    expect(store.saved, GuideSettings.off);
  });
}
