import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/core/symbols/rg_symbol.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_base.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/widgets/da_symbols.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/music/domain/routine_music.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/routine_timeline.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/play_mode_screen.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../../../core/device/fake_screen_awake.dart';
import '../../da_calculator/test_data.dart';
import '../../db_calculator/pump_db_calculator.dart';
import '../../db_calculator/test_data.dart';
import '../../music/fake_music.dart';

void main() {
  const bolero = RoutineMusic(fileName: 'bolero.mp3', title: 'Bolero');

  Routine timedRoutine() {
    final empty = emptyTestRoutine().withMusic(bolero);
    return empty
        .withDb(empty.db.withElementAdded(testJump))
        .withDa(empty.da.withElementAdded(DaElement(base: testRoll)))
        .withDanceStepCount(1)
        .withTime(TimelineKind.db, 0, const Duration(seconds: 5))
        .withTime(TimelineKind.danceStep, 0, const Duration(seconds: 10))
        .withTime(TimelineKind.da, 0, const Duration(seconds: 13));
  }

  Future<FakeMusic> openPlayMode(
    WidgetTester tester, {
    Routine? routine,
    FakeScreenAwake? screenAwake,
  }) async {
    final music = FakeMusic();
    music.library.files[bolero.fileName] = '/picked/Bolero.mp3';
    await pumpDbCalculator(
      tester,
      routine: routine ?? timedRoutine(),
      music: music,
      initialTab: RoutineTab.music,
      screenAwake: screenAwake,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play mode'));
    await tester.pumpAndSettle();
    return music;
  }

  Future<void> seek(WidgetTester tester, FakeMusic music, num seconds) async {
    await music.player.seek(Duration(milliseconds: (seconds * 1000).round()));
    await tester.pumpAndSettle();
  }

  /// The text shown under [key], also for coloured (rich) labels.
  String text(WidgetTester tester, String key) {
    final text = tester.widget<Text>(
      find
          .descendant(
            of: find.byKey(ValueKey(key)),
            matching: find.byType(Text),
            matchRoot: true,
          )
          .first,
    );
    return text.data ?? text.textSpan!.toPlainText();
  }

  testWidgets('shows what comes next before the first item', (tester) async {
    await openPlayMode(tester);

    expect(find.byType(PlayModeScreen), findsOneWidget);
    expect(text(tester, 'waiting-next'), 'DB 1');
    expect(find.text('in 5 s'), findsOneWidget);
  });

  testWidgets('pops up each item at its time', (tester) async {
    final music = await openPlayMode(tester);

    await seek(tester, music, 5.5);
    expect(text(tester, 'current-item'), 'DB 1');
    expect(find.text(testJump.name), findsOneWidget);
    expect(
      text(tester, 'next-line'),
      'Next: S 1 · Dance steps combination in 5 s',
    );
  });

  testWidgets('an S counts down from 8', (tester) async {
    final music = await openPlayMode(tester);

    await seek(tester, music, 10);
    expect(text(tester, 'current-item'), 'S 1');
    expect(text(tester, 'dance-step-countdown'), '8');

    await seek(tester, music, 12.2);
    expect(text(tester, 'dance-step-countdown'), '6');

    // A DA during the S: it shows under the countdown, which goes on.
    await seek(tester, music, 13.5);
    expect(text(tester, 'current-item'), 'DA 1');
    expect(text(tester, 'dance-step-countdown'), '5');
    // And the DA is flagged as not allowed there.
    expect(find.text('Not allowed during S 1'), findsOneWidget);

    // The countdown is gone after 8 s.
    await seek(tester, music, 18);
    expect(find.byKey(const ValueKey('dance-step-overlay')), findsNothing);
  });

  testWidgets('a DA with symbols shows them instead of its name', (
    tester,
  ) async {
    const roll = DaBase(
      id: 'symbol-roll',
      name: 'Roll with a symbol',
      apparatus: Apparatus.ball,
      value: Score.hundredths(30),
      rulesetId: 'test-v1',
      criteria: {},
      symbol: RgSymbol.largeRoll,
    );
    final empty = emptyTestRoutine().withMusic(bolero);
    final music = await openPlayMode(
      tester,
      routine: empty
          .withDa(empty.da.withElementAdded(DaElement(base: roll)))
          .withTime(TimelineKind.da, 0, const Duration(seconds: 5)),
    );

    await seek(tester, music, 5);

    expect(find.byType(DaSymbols), findsOneWidget);
    expect(find.text('Roll with a symbol'), findsNothing);
  });

  testWidgets('fits a phone screen', (tester) async {
    final music = await openPlayMode(tester);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    for (final seconds in [0, 5, 10, 13]) {
      await seek(tester, music, seconds);
      expect(tester.takeException(), isNull, reason: 'at $seconds s');
    }
  });

  testWidgets('keeps the screen on until closed', (tester) async {
    final screenAwake = FakeScreenAwake();
    await openPlayMode(tester, screenAwake: screenAwake);
    expect(screenAwake.enabled, isTrue);

    await tester.tap(find.byTooltip('Close Play mode'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayModeScreen), findsNothing);
    expect(find.text('Timeline'), findsOneWidget);
    expect(screenAwake.enabled, isFalse);
  });

  testWidgets('no Play mode button until something is marked', (tester) async {
    final music = FakeMusic();
    music.library.files[bolero.fileName] = '/picked/Bolero.mp3';
    await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withMusic(bolero),
      music: music,
      initialTab: RoutineTab.music,
    );
    await tester.pumpAndSettle();

    expect(find.text('Play mode'), findsNothing);
  });

  testWidgets('the layout stays in place between items', (tester) async {
    final music = await openPlayMode(tester);
    final mat = find.byKey(const ValueKey('play-mat'));
    final where = tester.getRect(mat);

    for (final seconds in [5, 10, 13, 30]) {
      await seek(tester, music, seconds);
      expect(tester.getRect(mat), where, reason: 'at $seconds s');
    }
  });

  testWidgets('keeps the speed chosen on the Music tab', (tester) async {
    final music = FakeMusic();
    await music.player.setSpeed(0.75);
    music.library.files[bolero.fileName] = '/picked/Bolero.mp3';
    await pumpDbCalculator(
      tester,
      routine: timedRoutine(),
      music: music,
      initialTab: RoutineTab.music,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play mode'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(PlayModeScreen),
        matching: find.text('0.75×'),
      ),
      findsOneWidget,
    );
  });
}
