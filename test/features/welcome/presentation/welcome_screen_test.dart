import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/app/app.dart';
import 'package:rg_routine_planner/features/welcome/data/welcome_store.dart';
import 'package:rg_routine_planner/features/welcome/presentation/welcome_providers.dart';

import '../fake_welcome_store.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester,
    FakeWelcomeStore store, {
    required bool startWithWelcome,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          welcomeStoreProvider.overrideWithValue(store),
          startWithWelcomeProvider.overrideWithValue(startWithWelcome),
          introVideoProvider.overrideWithValue(
            const SizedBox(key: ValueKey('intro-video')),
          ),
        ],
        child: const RgRoutinePlannerApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the first launch opens on the welcome screen', (tester) async {
    final store = FakeWelcomeStore();
    await pumpApp(tester, store, startWithWelcome: true);

    expect(find.byKey(const ValueKey('intro-video')), findsOneWidget);
    expect(find.text('Practise in Play mode'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(store.seen, welcomeVersion);
    expect(find.text('My routines'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);
  });

  testWidgets('Home opens it again with How it works', (tester) async {
    final store = FakeWelcomeStore(welcomeVersion);
    await pumpApp(tester, store, startWithWelcome: false);

    expect(find.text('Get started'), findsNothing);
    await tester.tap(find.text('How it works'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('intro-video')), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('How it works'), findsOneWidget);
  });
}
