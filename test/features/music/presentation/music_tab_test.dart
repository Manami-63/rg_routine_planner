import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/music/domain/routine_music.dart';
import 'package:rg_routine_planner/features/music/presentation/music_tab.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';

import '../../db_calculator/pump_db_calculator.dart';
import '../fake_music.dart';

void main() {
  const bolero = RoutineMusic(fileName: 'bolero.mp3', title: 'Bolero');

  Future<void> openMusicTab(WidgetTester tester) async {
    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(ValueKey(key))).data!;

  testWidgets('adding music saves the app\'s copy and loads it', (
    tester,
  ) async {
    final music = FakeMusic()
      ..picker.next = (path: '/picked/Bolero.mp3', name: 'Bolero.mp3');
    final routines = await pumpDbCalculator(tester, music: music);
    await openMusicTab(tester);
    expect(find.text('No music yet'), findsOneWidget);

    await tester.tap(find.text('Add music'));
    await tester.pumpAndSettle();

    final saved = routines.routines[testRoutineId]!.music!;
    expect(saved.title, 'Bolero');
    expect(music.library.files[saved.fileName], '/picked/Bolero.mp3');
    expect(text(tester, 'music-title'), 'Bolero');
    expect(music.player.loadedPath, '/music/${saved.fileName}');
    expect(text(tester, 'music-duration'), '1:30');
  });

  testWidgets('cancelling the picker changes nothing', (tester) async {
    final routines = await pumpDbCalculator(tester);
    await openMusicTab(tester);

    await tester.tap(find.text('Add music'));
    await tester.pumpAndSettle();

    expect(routines.routines[testRoutineId]!.music, isNull);
    expect(find.text('No music yet'), findsOneWidget);
  });

  testWidgets('plays, pauses and seeks', (tester) async {
    final music = FakeMusic();
    music.library.files[bolero.fileName] = '/picked/Bolero.mp3';
    await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withMusic(bolero),
      music: music,
    );
    await openMusicTab(tester);

    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(music.player.playing, isTrue);
    expect(find.byTooltip('Pause'), findsOneWidget);

    await tester.tap(find.byTooltip('Forward 5 seconds'));
    await tester.pump();
    expect(text(tester, 'music-position'), '0:05');

    await tester.tap(find.byTooltip('Back 5 seconds'));
    await tester.tap(find.byTooltip('Back 5 seconds'));
    await tester.pump();
    expect(music.player.position, Duration.zero);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(music.player.playing, isFalse);
  });

  testWidgets('replacing deletes the previous copy', (tester) async {
    final music = FakeMusic()
      ..picker.next = (path: '/picked/Swan.m4a', name: 'Swan.m4a');
    music.library.files[bolero.fileName] = '/picked/Bolero.mp3';
    final routines = await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withMusic(bolero),
      music: music,
    );
    await openMusicTab(tester);

    await tester.tap(find.byTooltip('Music options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace music'));
    await tester.pumpAndSettle();

    expect(routines.routines[testRoutineId]!.music!.title, 'Swan');
    expect(music.library.files.keys, isNot(contains(bolero.fileName)));
    expect(text(tester, 'music-title'), 'Swan');
  });

  testWidgets('removing asks first, then deletes the copy', (tester) async {
    final music = FakeMusic();
    music.library.files[bolero.fileName] = '/picked/Bolero.mp3';
    final routines = await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withMusic(bolero),
      music: music,
    );
    await openMusicTab(tester);

    await tester.tap(find.byTooltip('Music options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove music'));
    await tester.pumpAndSettle();
    expect(find.text('Remove the music?'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(routines.routines[testRoutineId]!.music, isNull);
    expect(music.library.files, isEmpty);
    expect(find.text('No music yet'), findsOneWidget);
  });

  testWidgets('a missing file asks to choose the music again', (tester) async {
    await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withMusic(bolero),
    );
    await openMusicTab(tester);

    expect(find.text('The music file is missing'), findsOneWidget);
    expect(find.text('Choose music'), findsOneWidget);
  });

  testWidgets('plays slower for learning', (tester) async {
    final music = FakeMusic();
    music.library.files[bolero.fileName] = '/picked/Bolero.mp3';
    await pumpDbCalculator(
      tester,
      routine: emptyTestRoutine().withMusic(bolero),
      music: music,
    );
    await openMusicTab(tester);
    expect(find.text('1×'), findsOneWidget);

    await tester.tap(find.byTooltip('Playback speed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0.75×'));
    await tester.pumpAndSettle();
    expect(music.player.speed, 0.75);
    expect(find.text('0.75×'), findsOneWidget);

    await tester.tap(find.byTooltip('Playback speed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Normal (1×)'));
    await tester.pumpAndSettle();
    expect(music.player.speed, 1);
  });

  testWidgets('the music tab opens from the route', (tester) async {
    await pumpDbCalculator(tester, initialTab: RoutineTab.music);

    expect(find.byType(MusicTab), findsOneWidget);
  });

  test('speeds show without trailing zeros', () {
    expect(MusicPlayerControls.speeds.map(formatSpeed), [
      '0.5×',
      '0.75×',
      '0.9×',
      '1×',
    ]);
  });

  test('times show minutes and seconds', () {
    expect(formatMusicTime(Duration.zero), '0:00');
    expect(
      formatMusicTime(const Duration(seconds: 65, milliseconds: 900)),
      '1:05',
    );
  });
}
