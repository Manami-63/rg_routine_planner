// Store screenshots: loads a demo routine into the real app on a simulator
// or emulator and opens each screen shown in the store listings.
//
// Run with tool/screenshots/take_screenshots.sh, which reads the
// "SCREENSHOT <name>" lines this test prints and captures the device
// screen while the test waits. The demo music is passed in with
// --dart-define=SCREENSHOT_MUSIC=<path on the device>; use a made-up
// track (never a real song).
//
// Use a fresh simulator or emulator: the routine is saved in the app's
// real database.

// The marker lines go to the console on purpose.
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rg_routine_planner/app/app.dart';
import 'package:rg_routine_planner/app/router.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/fig_ruleset.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/da_calculator_providers.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/da_tab.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/widgets/da_builder_sheet.dart';
import 'package:rg_routine_planner/features/music/presentation/music_providers.dart';
import 'package:rg_routine_planner/features/music/presentation/music_tab.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/play_mode_screen.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routines/domain/routine_file.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_controller.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';
import 'package:rg_routine_planner/features/welcome/presentation/welcome_providers.dart';

const _musicPath = String.fromEnvironment('SCREENSHOT_MUSIC');

/// How long the test waits while the screen is captured.
const _captureTime = Duration(seconds: 4);

Map<String, Object?> _timing(double seconds, int cell) => {
  'timeMs': (seconds * 1000).round(),
  'cell': cell,
};

Map<String, Object?> _db(
  String code,
  double seconds,
  int cell, {
  int extraRotations = 0,
  String? cycles,
}) => {
  'id': 'fig-$code',
  'flatFoot': false,
  'slowTurn': false,
  'extraRotations': extraRotations,
  'seriesCount': 1,
  'rotationCycles': ?cycles,
  'manualValue': null,
  ..._timing(seconds, cell),
};

Map<String, Object?> _risk(
  int rotations,
  List<String> criteria,
  double seconds,
  int cell,
) => {
  'rotation': 'fig-r-rotations-$rotations',
  'criteria': [for (final c in criteria) 'fig-r-$c'],
  ..._timing(seconds, cell),
};

Map<String, Object?> _da(
  String base,
  String criteria,
  double seconds,
  int cell,
) => {
  'base': 'fig-da-hoop-$base',
  'secondBase': null,
  'customName': null,
  'criteria': criteria,
  'preAcrobatic': false,
  'manualValue': null,
  ..._timing(seconds, cell),
};

/// A FIG Senior Hoop routine on a 90 s track: 8 DB (all body groups), 3 R,
/// 10 DA (some with a DB in the same moment) and 2 dance steps, all timed
/// and placed on the floor (cells 1 back left to 9 front right).
Map<String, Object?> demoRoutine() => {
  'app': 'rg_routine_planner',
  'format': 1,
  'name': 'Senior Hoop 2026',
  'rulesetId': figRulesetId,
  'apparatus': Apparatus.hoop.name,
  'levelId': 'fig-senior',
  'notes': 'Competition routine. Keep the hoop close on the roll at 0:28.',
  'danceSteps': [_timing(32, 5), _timing(65, 8)],
  'elements': [
    _db('1.2305', 4, 1),
    _db('2.1106', 13, 3),
    _db('3.1205', 23, 5, extraRotations: 1),
    _db('1.3606', 41, 7),
    _db('2.806', 51, 9),
    _db('3.1601', 56, 6, extraRotations: 5, cycles: '2121'),
    _db('1.2806', 74, 1),
    _db('3.905', 84, 5),
  ],
  'risks': [
    _risk(3, ['throw-outside-visual-field', 'catch-without-hands'], 18, 4),
    _risk(2, ['change-of-axis-or-level', 'catch-outside-visual-field'], 46, 2),
    _risk(2, ['throw-without-hands', 'catch-passing-through-hoop'], 79, 3),
  ],
  'da': [
    _da('passing-through', 'outsideVisualField,db', 4, 1),
    _da('large-roll', 'outsideVisualField,rotation', 9, 2),
    _da('rotation-body', 'outsideVisualField,db', 13, 3),
    _da('free-rotation-axis', 'withoutHands,db', 23, 5),
    _da('roll-floor', 'outsideVisualField,rotation', 28, 4),
    _da('passing-through', 'underLeg,db', 41, 7),
    _da('sliding', 'withoutHands,db', 51, 9),
    _da('transmission', 'outsideVisualField,rotation', 61, 6),
    _da('small-throw', 'underLeg,db', 74, 1),
    _da('rotation-body', 'db,rotation', 84, 5),
  ],
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester tester, Duration duration) async {
    final end = DateTime.now().add(duration);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Waits until [finder] finds something (slow emulators load slowly).
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    final end = DateTime.now().add(const Duration(seconds: 60));
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) fail('Not found: $finder');
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Opens the routine page tab labelled [label].
  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text(label)),
    );
    await wait(tester, const Duration(seconds: 2));
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await wait(tester, const Duration(seconds: 1));
    print('SCREENSHOT $name');
    await wait(tester, _captureTime);
  }

  testWidgets('store screenshots', (tester) async {
    expect(_musicPath, isNotEmpty, reason: 'Pass SCREENSHOT_MUSIC');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [startWithWelcomeProvider.overrideWithValue(false)],
        child: const RgRoutinePlannerApp(),
      ),
    );
    await wait(tester, const Duration(seconds: 1));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RgRoutinePlannerApp)),
    );

    // The demo routine, saved like an imported routine file.
    final decoded = RoutineFile.decode(
      jsonEncode(demoRoutine()),
      id: 'store-screenshots',
      now: DateTime.now().toUtc(),
    );
    final music = await container
        .read(musicLibraryProvider)
        .addBytes(
          await File(_musicPath).readAsBytes(),
          extension: _musicPath.split('.').last,
          title: 'Demo track',
        );
    final id = decoded.routine.id;
    await container
        .read(routineRepositoryProvider)
        .saveRoutine(decoded.routine.withMusic(music));
    final router = container.read(routerProvider);

    // 1. Music: the timeline and floor mat.
    router.go(AppRoutes.routine(id, RoutineTab.music));
    const chooseLater = ValueKey('choose-later');
    await waitFor(tester, find.byKey(chooseLater));
    await wait(tester, const Duration(seconds: 1));
    await container
        .read(musicPlayerProvider(id))
        .seek(const Duration(seconds: 44));
    // Scroll to the mark buttons, so the mat and timeline show.
    await Scrollable.ensureVisible(tester.element(find.byKey(chooseLater)));
    await capture(tester, '1_music');

    // 2. DB: the list with symbols and the total bar.
    await openTab(tester, 'DB');
    await capture(tester, '2_db');

    // 3. DA builder: editing a DA with its base and criteria.
    await openTab(tester, 'DA');
    await waitFor(tester, find.byType(DaTab));
    final hoopBases = [
      for (final base in container.read(daBasesProvider).requireValue)
        if (base.apparatus == Apparatus.hoop) base,
    ];
    const daIndex = 3;
    unawaited(
      DaBuilderSheet.show(
        tester.element(find.byType(DaTab)),
        routineId: id,
        bases: hoopBases,
        index: daIndex,
        initial: container.read(routineProvider(id)).da.elements[daIndex],
      ),
    );
    await capture(tester, '3_da_builder');
    Navigator.of(tester.element(find.byType(DaBuilderSheet))).pop();
    await wait(tester, const Duration(seconds: 1));

    // 4. Play mode: a DB and a DA together.
    await openTab(tester, 'Music');
    await container
        .read(musicPlayerProvider(id))
        .seek(const Duration(milliseconds: 13600));
    unawaited(
      PlayModeScreen.show(tester.element(find.byType(MusicTab)), routineId: id),
    );
    await capture(tester, '4_play_mode');
  });
}
