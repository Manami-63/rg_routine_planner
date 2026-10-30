import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/music/domain/routine_music.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/routine_timeline.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/play_mode_screen.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

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
  }) async {
    final music = FakeMusic();
    music.library.files[bolero.fileName] = '/picked/Bolero.mp3';
    await pumpDbCalculator(
      tester,
      routine: routine ?? timedRoutine(),
      music: music,
      initialTab: RoutineTab.music,
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

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(ValueKey(key))).data!;

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

    // A DA during the S: the countdown moves to a chip.
    await seek(tester, music, 13.5);
    expect(text(tester, 'current-item'), 'DA 1');
    expect(find.text('S · 5 s left'), findsOneWidget);
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

  testWidgets('close returns to the routine page', (tester) async {
    await openPlayMode(tester);

    await tester.tap(find.byTooltip('Close Play mode'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayModeScreen), findsNothing);
    expect(find.text('Timeline'), findsOneWidget);
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
}
