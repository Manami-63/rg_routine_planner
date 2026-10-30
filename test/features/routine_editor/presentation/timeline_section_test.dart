import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/music/domain/routine_music.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/timeline_section.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/pump_db_calculator.dart';
import '../../db_calculator/test_data.dart';
import '../../music/fake_music.dart';
import '../../routines/fake_routine_repository.dart';

void main() {
  const bolero = RoutineMusic(fileName: 'bolero.mp3', title: 'Bolero');

  Routine routineWithContent() {
    final empty = emptyTestRoutine().withMusic(bolero);
    return empty
        .withDb(
          empty.db.withElementAdded(testJump).withElementAdded(testBalance),
        )
        .withDa(empty.da.withElementAdded(DaElement(base: testRoll)))
        .withDanceStepCount(1);
  }

  Future<(FakeRoutineRepository, FakeMusic)> pumpMusicTab(
    WidgetTester tester, {
    Routine? routine,
  }) async {
    final music = FakeMusic();
    music.library.files[bolero.fileName] = '/picked/Bolero.mp3';
    final routines = await pumpDbCalculator(
      tester,
      routine: routine ?? routineWithContent(),
      music: music,
      initialTab: RoutineTab.music,
    );
    await tester.pumpAndSettle();
    return (routines, music);
  }

  Finder rowOf(String key) => find.byKey(ValueKey(key));

  testWidgets('Next DB marks the first unmarked DB at the position', (
    tester,
  ) async {
    final (routines, music) = await pumpMusicTab(tester);
    expect(find.text('Nothing marked yet.'), findsOneWidget);
    expect(find.text('0 of 2'), findsOneWidget);

    await music.player.seek(const Duration(milliseconds: 12340));
    await tester.tap(find.byKey(const ValueKey('mark-db')));
    await tester.pump();

    final saved = routines.routines[testRoutineId]!;
    expect(saved.db.elementTimes, [const Duration(milliseconds: 12340), null]);
    expect(
      find.descendant(
        of: rowOf('timeline-db-0'),
        matching: find.text('0:12.3'),
      ),
      findsOneWidget,
    );
    expect(find.text('1 of 2'), findsOneWidget);
  });

  testWidgets('a button is disabled once all are marked', (tester) async {
    final (_, music) = await pumpMusicTab(tester);

    await music.player.seek(const Duration(seconds: 5));
    await tester.tap(find.byKey(const ValueKey('mark-danceStep')));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('mark-danceStep')),
    );
    expect(button.onPressed, isNull);
    expect(rowOf('timeline-danceStep-0'), findsOneWidget);
  });

  testWidgets('nudges move a time and clear removes it', (tester) async {
    final (routines, music) = await pumpMusicTab(tester);
    await music.player.seek(const Duration(seconds: 10));
    await tester.tap(find.byKey(const ValueKey('mark-da')));
    await tester.pump();

    await tester.tap(find.byTooltip('Move DA 1 later'));
    await tester.pump();
    await tester.tap(find.byTooltip('Move DA 1 later'));
    await tester.pump();
    await tester.tap(find.byTooltip('Move DA 1 earlier'));
    await tester.pump();
    expect(routines.routines[testRoutineId]!.da.times, [
      const Duration(milliseconds: 10100),
    ]);

    await tester.tap(find.byTooltip('Clear the time of DA 1'));
    await tester.pump();
    expect(routines.routines[testRoutineId]!.da.times, [null]);
    expect(find.text('Nothing marked yet.'), findsOneWidget);
  });

  testWidgets('tapping an entry seeks the music there', (tester) async {
    final (_, music) = await pumpMusicTab(
      tester,
      routine: routineWithContent().withDanceStepTimeAt(
        0,
        const Duration(seconds: 42),
      ),
    );

    await tester.tap(find.text('S 1'));
    await tester.pump();

    expect(music.player.position, const Duration(seconds: 42));
  });

  testWidgets('a later time on the first DB reorders the DB list', (
    tester,
  ) async {
    final (routines, music) = await pumpMusicTab(
      tester,
      routine: routineWithContent().withDb(
        routineWithContent().db.withElementTimeAt(
          0,
          const Duration(seconds: 20),
        ),
      ),
    );

    // The balance (unmarked) is marked before the jump.
    await music.player.seek(const Duration(seconds: 8));
    await tester.tap(find.byKey(const ValueKey('mark-db')));
    await tester.pump();

    expect(routines.routines[testRoutineId]!.db.elements, [
      testBalance,
      testJump,
    ]);
  });

  testWidgets('clear all asks first, then removes every time', (tester) async {
    final (routines, _) = await pumpMusicTab(
      tester,
      routine: routineWithContent().withDanceStepTimeAt(
        0,
        const Duration(seconds: 1),
      ),
    );

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
    await tester.pumpAndSettle();

    expect(routines.routines[testRoutineId]!.danceStepTimes, [null]);
  });

  testWidgets('freehand has no R or DA buttons', (tester) async {
    await pumpMusicTab(
      tester,
      routine: routineWithContent().withApparatus(Apparatus.freehand),
    );

    expect(find.byKey(const ValueKey('mark-db')), findsOneWidget);
    expect(find.byKey(const ValueKey('mark-risk')), findsNothing);
    expect(find.byKey(const ValueKey('mark-da')), findsNothing);
  });

  test('formatTimelineTime shows tenths', () {
    expect(formatTimelineTime(Duration.zero), '0:00.0');
    expect(formatTimelineTime(const Duration(milliseconds: 65390)), '1:05.3');
  });
}
