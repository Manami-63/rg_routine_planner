import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/floor/floor_cell.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/music/domain/routine_music.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/routine_timeline.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/routine_screen.dart';
import 'package:rg_routine_planner/features/routine_editor/presentation/timeline_colours.dart';
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
        .withDb(empty.db.withElementAdded(testBalance))
        .withDa(
          empty.da
              .withElementAdded(DaElement(base: testRoll))
              .withElementAdded(DaElement(base: testThrow))
              .withElementAdded(DaElement(base: testCatch)),
        );
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

  Routine saved(FakeRoutineRepository routines) =>
      routines.routines[testRoutineId]!;

  Finder cellOf(int number) => find.byKey(ValueKey('floor-cell-$number'));

  /// Drags the "Next" button of [kind] to [to], with the music at [at].
  Future<void> dragMark(
    WidgetTester tester,
    FakeMusic music,
    TimelineKind kind, {
    required Duration at,
    required Offset to,
  }) async {
    await music.player.seek(at);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(ValueKey('mark-${kind.name}'))),
    );
    // The music moves on while dragging; the time from the touch is kept.
    await music.player.seek(at + const Duration(seconds: 1));
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();
    await gesture.moveTo(to);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('dragging Next DA onto a cell marks the time and the cell', (
    tester,
  ) async {
    final (routines, music) = await pumpMusicTab(tester);

    await dragMark(
      tester,
      music,
      TimelineKind.da,
      at: const Duration(seconds: 7),
      to: tester.getCenter(cellOf(9)),
    );

    expect(saved(routines).da.times.first, const Duration(seconds: 7));
    expect(saved(routines).da.cells.first, FloorCell.frontRight);
    expect(
      find.descendant(of: cellOf(9), matching: find.text('DA1')),
      findsOneWidget,
    );
  });

  testWidgets('dropping outside the mat marks only the time', (tester) async {
    final (routines, music) = await pumpMusicTab(tester);

    await dragMark(
      tester,
      music,
      TimelineKind.db,
      at: const Duration(seconds: 3),
      to: tester.getTopLeft(find.text('Mark times')),
    );

    expect(saved(routines).db.elementTimes, [const Duration(seconds: 3)]);
    expect(saved(routines).db.elementCells, [null]);
  });

  testWidgets('a tap takes the time of the touch', (tester) async {
    final (routines, music) = await pumpMusicTab(tester);
    await music.player.seek(const Duration(seconds: 4));

    await tester.tap(find.byKey(const ValueKey('mark-db')));
    await tester.pump();

    expect(saved(routines).db.elementTimes, [const Duration(seconds: 4)]);
  });

  testWidgets('a timeline row sets and removes the cell', (tester) async {
    final (routines, _) = await pumpMusicTab(
      tester,
      routine: routineWithContent().withTime(
        TimelineKind.db,
        0,
        const Duration(seconds: 2),
      ),
    );

    await tester.tap(find.byTooltip('Set where DB 1 starts'));
    await tester.pumpAndSettle();
    await tester.tap(cellOf(3).last);
    await tester.pumpAndSettle();
    expect(saved(routines).db.elementCells, [FloorCell.backRight]);
    expect(find.byKey(const ValueKey('cell-db-0')), findsOneWidget);

    await tester.tap(find.byTooltip('Set where DB 1 starts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No location'));
    await tester.pumpAndSettle();
    expect(saved(routines).db.elementCells, [null]);
  });

  testWidgets('notices for missing zones and the same placement', (
    tester,
  ) async {
    var routine = routineWithContent();
    for (final (i, cell) in [
      FloorCell.back,
      FloorCell.back,
      FloorCell.back,
    ].indexed) {
      routine = routine
          .withCell(TimelineKind.da, i, cell)
          .withTime(TimelineKind.da, i, Duration(seconds: 10 * (i + 1)));
    }
    await pumpMusicTab(tester, routine: routine);

    expect(
      find.text(
        'No marked item in the back left corner, back right corner, centre, '
        'front left corner and front right corner. All 5 zones of the floor '
        'should be visited (CoP #9.2): you may get a 0.30 penalty (#9.2.1).',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'DA 1, DA 2 and DA 3 are all in cell 2: the same placement for 3 or '
        'more Difficulties in a row (CoP #9.4.1) may get a 0.30 penalty.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('no notices until something has a cell', (tester) async {
    await pumpMusicTab(
      tester,
      routine: routineWithContent().withTime(
        TimelineKind.da,
        0,
        const Duration(seconds: 1),
      ),
    );

    expect(find.byKey(const ValueKey('floor-zones-notice')), findsNothing);
  });

  testWidgets('Play mode shows where the item starts', (tester) async {
    final (_, music) = await pumpMusicTab(
      tester,
      routine: routineWithContent()
          .withCell(TimelineKind.da, 0, FloorCell.centre)
          .withTime(TimelineKind.da, 0, const Duration(seconds: 5)),
    );
    await tester.tap(find.text('Play mode'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(390, 844);

    await music.player.seek(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final cellFinder = find.byKey(const ValueKey('play-cell-5'));
    final cell = tester.widget<Container>(cellFinder);
    expect(
      (cell.decoration! as BoxDecoration).color,
      ItemColours.of(
        TimelineKind.da,
        Theme.of(tester.element(cellFinder)).colorScheme,
      ).colour,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Music tab fits a phone screen', (tester) async {
    await pumpMusicTab(
      tester,
      routine: routineWithContent()
          .withCell(TimelineKind.db, 0, FloorCell.centre)
          .withTime(TimelineKind.db, 0, const Duration(seconds: 65))
          .withTime(TimelineKind.da, 0, const Duration(seconds: 65)),
    );
    tester.view.physicalSize = const Size(375, 2400);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  group('DB and DA together', () {
    /// Drags the "Next" button of [kind] onto cell [cell] without moving
    /// the music.
    Future<void> dropOn(
      WidgetTester tester,
      TimelineKind kind,
      int cell,
    ) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(ValueKey('mark-${kind.name}'))),
      );
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      await gesture.moveTo(tester.getCenter(cellOf(cell)));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
    }

    Routine paired() => routineWithContent()
        .withTime(TimelineKind.db, 0, const Duration(seconds: 5))
        .withTime(TimelineKind.da, 0, const Duration(seconds: 5));

    testWidgets('a drop pauses the music', (tester) async {
      final (_, music) = await pumpMusicTab(tester);
      await music.player.play();

      await dragMark(
        tester,
        music,
        TimelineKind.da,
        at: const Duration(seconds: 7),
        to: tester.getCenter(cellOf(5)),
      );

      expect(music.player.playing, isFalse);
    });

    testWidgets('a DB dropped while paused after a DA is done with it', (
      tester,
    ) async {
      final (routines, music) = await pumpMusicTab(tester);
      await music.player.play();
      await dragMark(
        tester,
        music,
        TimelineKind.da,
        at: const Duration(seconds: 7),
        to: tester.getCenter(cellOf(5)),
      );

      await dropOn(tester, TimelineKind.db, 4);

      expect(saved(routines).db.elementTimes, [const Duration(seconds: 7)]);
      expect(saved(routines).db.elementCells, [FloorCell.left]);
      expect(find.text('Together with DA 1'), findsOneWidget);
      expect(find.text('Together with DB 1'), findsOneWidget);
    });

    testWidgets('a tap while paused after a drop is also together', (
      tester,
    ) async {
      final (routines, music) = await pumpMusicTab(tester);
      await dragMark(
        tester,
        music,
        TimelineKind.db,
        at: const Duration(seconds: 7),
        to: tester.getCenter(cellOf(5)),
      );

      await tester.tap(find.byKey(const ValueKey('mark-da')));
      await tester.pump();

      expect(saved(routines).da.times.first, const Duration(seconds: 7));
    });

    testWidgets('after playing on, the next item is separate', (tester) async {
      final (routines, music) = await pumpMusicTab(tester);
      await dragMark(
        tester,
        music,
        TimelineKind.da,
        at: const Duration(seconds: 7),
        to: tester.getCenter(cellOf(5)),
      );
      await music.player.play();
      await music.player.seek(const Duration(seconds: 10));

      await dropOn(tester, TimelineKind.db, 5);

      expect(saved(routines).db.elementTimes, [const Duration(seconds: 10)]);
      expect(find.textContaining('Together with'), findsNothing);
    });

    testWidgets('a second DA while paused is not paired', (tester) async {
      final (routines, music) = await pumpMusicTab(tester);
      await dragMark(
        tester,
        music,
        TimelineKind.da,
        at: const Duration(seconds: 7),
        to: tester.getCenter(cellOf(5)),
      );

      await dropOn(tester, TimelineKind.da, 5);

      expect(saved(routines).da.times.take(2), [
        const Duration(seconds: 7),
        const Duration(seconds: 8),
      ]);
    });

    testWidgets('nudging one moves both', (tester) async {
      final (routines, _) = await pumpMusicTab(tester, routine: paired());

      await tester.tap(find.byTooltip('Move DA 1 later'));
      await tester.pump();

      const later = Duration(milliseconds: 5100);
      expect(saved(routines).db.elementTimes, [later]);
      expect(saved(routines).da.times.first, later);
    });

    testWidgets('split and pair again from the timeline', (tester) async {
      final (routines, _) = await pumpMusicTab(tester, routine: paired());

      await tester.tap(find.byTooltip('Split DB 1 from DA 1'));
      await tester.pump();
      expect(saved(routines).db.elementTimes, [
        const Duration(milliseconds: 5100),
      ]);
      expect(find.textContaining('Together with'), findsNothing);

      await tester.tap(find.byTooltip('Pair DB 1 with a DA'));
      await tester.pumpAndSettle();
      expect(find.text('DB 1 is done together with…'), findsOneWidget);
      await tester.tap(find.text('DA 1').last);
      await tester.pumpAndSettle();

      expect(saved(routines).db.elementTimes, [const Duration(seconds: 5)]);
      expect(find.text('Together with DA 1'), findsOneWidget);
    });

    testWidgets('Play mode shows the pair as one', (tester) async {
      final (_, music) = await pumpMusicTab(tester, routine: paired());
      await tester.tap(find.text('Play mode'));
      await tester.pumpAndSettle();

      expect(find.text('DB 1 + DA 1'), findsOneWidget);
      await music.player.seek(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('current-item')),
          matching: find.text('DB 1 + DA 1'),
        ),
        findsOneWidget,
      );
    });
  });
}
