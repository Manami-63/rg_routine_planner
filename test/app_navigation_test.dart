import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/app/app.dart';

void main() {
  testWidgets('home opens the DB calculator and back returns home', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: RgRoutinePlannerApp()));
    await tester.pumpAndSettle();

    expect(find.text('RG Routine Planner'), findsOneWidget);
    expect(find.text('Coming soon'), findsNWidgets(2));

    await tester.tap(find.text('DB Calculator'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'DB Calculator'), findsOneWidget);
    expect(find.text('Body difficulties'), findsOneWidget);
    expect(find.text('Risks'), findsOneWidget);
    // Runs against the real sample catalogue.
    await tester.scrollUntilVisible(
      find.text('Sample Jump A'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Sample Jump A'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('RG Routine Planner'), findsOneWidget);
  });
}
