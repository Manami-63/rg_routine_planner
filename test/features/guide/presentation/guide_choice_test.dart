import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/app/app.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/da_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/guide/domain/guide.dart';
import 'package:rg_routine_planner/features/guide/presentation/guide_providers.dart';
import 'package:rg_routine_planner/features/music/presentation/music_providers.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/test_data.dart';
import '../../music/fake_music.dart';
import '../../routines/fake_routine_repository.dart';
import '../fake_guide_store.dart';

void main() {
  Future<FakeRoutineRepository> createRoutine(
    WidgetTester tester,
    FakeGuideStore store, {
    GuideSettings guide = const GuideSettings(),
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final routines = FakeRoutineRepository();
    final music = FakeMusic();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbCatalogueRepositoryProvider.overrideWithValue(
            FakeDbCatalogueRepository(),
          ),
          daCatalogueRepositoryProvider.overrideWithValue(
            FakeDaCatalogueRepository(),
          ),
          routineRepositoryProvider.overrideWithValue(routines),
          musicLibraryProvider.overrideWithValue(music.library),
          musicPickerProvider.overrideWithValue(music.picker),
          musicPlayerProvider.overrideWith((ref, _) => music.player),
          initialGuideSettingsProvider.overrideWithValue(guide),
          guideStoreProvider.overrideWithValue(store),
        ],
        child: const RgRoutinePlannerApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('My routines'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New routine'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Hoop final');
    await tester.tap(find.text('Hoop'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Create'));
    await tester.pumpAndSettle();
    return routines;
  }

  int openTab(WidgetTester tester) =>
      DefaultTabController.of(tester.element(find.byType(TabBar))).index;

  testWidgets('From my music guides the new routine on the Music tab', (
    tester,
  ) async {
    final store = FakeGuideStore();
    final routines = await createRoutine(tester, store);

    expect(find.text('How do you want to start?'), findsOneWidget);
    await tester.tap(find.text('From my music'));
    await tester.pumpAndSettle();

    expect(openTab(tester), RoutineTab.music.index);
    expect(find.text('Step 1 of 5 · Add your music'), findsOneWidget);
    expect(store.saved.active, isNotNull);
    expect(store.saved.active!.routineId, routines.routines.keys.single);
    expect(store.saved.active!.path, GuidePath.music);
  });

  testWidgets('Pick DB and DA first opens the DB tab', (tester) async {
    await createRoutine(tester, FakeGuideStore());

    await tester.tap(find.text('Pick DB and DA first'));
    await tester.pumpAndSettle();

    expect(openTab(tester), RoutineTab.db.index);
    expect(find.text('Step 1 of 6 · Add your first DB'), findsOneWidget);
  });

  testWidgets('exploring alone opens the routine without a guide', (
    tester,
  ) async {
    final store = FakeGuideStore();
    await createRoutine(tester, store);

    await tester.tap(find.text("I'll explore on my own"));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Hoop final'), findsOneWidget);
    expect(find.byKey(const ValueKey('guide-card')), findsNothing);
    expect(store.saved, const GuideSettings());
  });

  testWidgets("Don't show the guide again turns it off", (tester) async {
    final store = FakeGuideStore();
    await createRoutine(tester, store);

    await tester.tap(find.text("Don't show the guide again"));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Hoop final'), findsOneWidget);
    expect(store.saved, GuideSettings.off);
  });

  testWidgets('nothing is asked while the guide is off', (tester) async {
    await createRoutine(tester, FakeGuideStore(), guide: GuideSettings.off);

    expect(find.text('How do you want to start?'), findsNothing);
    expect(find.widgetWithText(AppBar, 'Hoop final'), findsOneWidget);
  });
}
