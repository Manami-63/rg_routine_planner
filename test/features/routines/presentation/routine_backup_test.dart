import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/music/domain/routine_music.dart';
import 'package:rg_routine_planner/features/music/presentation/music_providers.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/domain/routine_file.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';
import 'package:rg_routine_planner/features/routines/presentation/routines_screen.dart';

import '../../music/fake_music.dart';
import '../fake_routine_file_transfer.dart';
import '../fake_routine_repository.dart';

void main() {
  final base = DateTime.utc(2026, 11, 9, 9);
  const bolero = RoutineMusic(fileName: 'a.mp3', title: 'Bolero');

  Routine routine(String id, String name, {Duration age = Duration.zero}) =>
      Routine(
        id: id,
        name: name,
        db: DbRoutine(rulesetId: 'test-v1'),
        createdAt: base.subtract(const Duration(days: 30)),
        updatedAt: base.subtract(age),
      );

  Future<FakeRoutineRepository> pumpScreen(
    WidgetTester tester,
    List<Routine> routines, {
    required FakeRoutineFileTransfer transfer,
    FakeMusicLibrary? musicLibrary,
  }) async {
    final repository = FakeRoutineRepository(routines);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routineRepositoryProvider.overrideWithValue(repository),
          musicLibraryProvider.overrideWithValue(
            musicLibrary ?? FakeMusicLibrary(),
          ),
          routineFileTransferProvider.overrideWithValue(transfer),
        ],
        child: const MaterialApp(home: RoutinesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  Future<void> chooseMenu(WidgetTester tester, String item) async {
    await tester.tap(find.byTooltip('Backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  /// The routines in a shared backup, after its header.
  List<({Routine routine, SharedMusic? music})> backedUp(
    FakeRoutineFileTransfer transfer,
  ) => [
    for (final line in transfer.sharedLines.skip(1))
      RoutineFile.decodeBackupLine(line),
  ];

  group('back up', () {
    testWidgets('shares every routine in one file, keeping ids and dates', (
      tester,
    ) async {
      final transfer = FakeRoutineFileTransfer();
      final hoop = routine('r1', 'Hoop', age: const Duration(days: 2));
      await pumpScreen(tester, [
        hoop,
        routine('r2', 'Ball'),
      ], transfer: transfer);

      await chooseMenu(tester, 'Back up all routines');

      expect(transfer.sharedFileName, startsWith('RG Routine Lab backup '));
      expect(transfer.sharedFileName, endsWith('.rgroutine'));
      expect(RoutineFile.backupCount(transfer.sharedLines.first), 2);
      final routines = {
        for (final entry in backedUp(transfer)) entry.routine.id: entry,
      };
      expect(routines.keys, {'r1', 'r2'});
      expect(routines['r1']!.routine.name, 'Hoop');
      expect(routines['r1']!.routine.createdAt, hoop.createdAt);
      expect(routines['r1']!.routine.updatedAt, hoop.updatedAt);
      // No music, so no question.
      expect(find.text('Include the music?'), findsNothing);
    });

    testWidgets('asks about the music, with its size', (tester) async {
      final transfer = FakeRoutineFileTransfer();
      await pumpScreen(
        tester,
        [routine('r1', 'Hoop').withMusic(bolero)],
        transfer: transfer,
        musicLibrary: FakeMusicLibrary({'a.mp3': 'tune'}),
      );

      await chooseMenu(tester, 'Back up all routines');
      expect(find.textContaining('1 track, under 1 MB'), findsOneWidget);
      await tester.tap(find.text('Include music'));
      await tester.pumpAndSettle();

      final music = backedUp(transfer).single.music!;
      expect(music.title, 'Bolero');
      expect(utf8.decode(music.bytes), 'tune');
    });

    testWidgets('can leave the music out', (tester) async {
      final transfer = FakeRoutineFileTransfer();
      await pumpScreen(
        tester,
        [routine('r1', 'Hoop').withMusic(bolero)],
        transfer: transfer,
        musicLibrary: FakeMusicLibrary({'a.mp3': 'tune'}),
      );

      await chooseMenu(tester, 'Back up all routines');
      await tester.tap(find.text('Without music'));
      await tester.pumpAndSettle();

      expect(backedUp(transfer).single.music, isNull);
    });

    testWidgets('dismissing the question shares nothing', (tester) async {
      final transfer = FakeRoutineFileTransfer();
      await pumpScreen(
        tester,
        [routine('r1', 'Hoop').withMusic(bolero)],
        transfer: transfer,
        musicLibrary: FakeMusicLibrary({'a.mp3': 'tune'}),
      );

      await chooseMenu(tester, 'Back up all routines');
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(transfer.sharedContents, isNull);
    });

    testWidgets('says when there is nothing to back up', (tester) async {
      final transfer = FakeRoutineFileTransfer();
      await pumpScreen(tester, [], transfer: transfer);

      await chooseMenu(tester, 'Back up all routines');

      expect(transfer.sharedContents, isNull);
      expect(find.text('There are no routines to back up.'), findsOneWidget);
    });

    testWidgets('reports a failure', (tester) async {
      final transfer = FakeRoutineFileTransfer()
        ..shareError = Exception('no space');
      await pumpScreen(tester, [routine('r1', 'Hoop')], transfer: transfer);

      await chooseMenu(tester, 'Back up all routines');

      expect(find.text('Could not back up the routines.'), findsOneWidget);
    });
  });

  group('restore', () {
    String backup(List<Routine> routines, {Map<String, String>? music}) => [
      RoutineFile.backupHeader(count: routines.length, now: base),
      for (final routine in routines)
        RoutineFile.backupLine(
          routine,
          music: switch (music?[routine.id]) {
            final contents? => SharedMusic(
              title: 'From backup',
              extension: 'mp3',
              bytes: utf8.encode(contents),
            ),
            null => null,
          },
        ),
    ].join('\n');

    testWidgets('adds missing routines and keeps the newer version', (
      tester,
    ) async {
      final onPhone = [
        routine('older-here', 'Old here', age: const Duration(days: 3)),
        routine('newer-here', 'New here'),
      ];
      final transfer = FakeRoutineFileTransfer()
        ..next = backup([
          routine('older-here', 'Edited later', age: const Duration(days: 1)),
          routine('newer-here', 'Edited before', age: const Duration(days: 5)),
          routine('missing', 'Lost routine', age: const Duration(days: 9)),
        ]);
      final repository = await pumpScreen(tester, onPhone, transfer: transfer);

      await chooseMenu(tester, 'Restore a backup');

      final routines = repository.routines;
      expect(routines.keys, {'older-here', 'newer-here', 'missing'});
      expect(routines['older-here']!.name, 'Edited later');
      expect(routines['newer-here']!.name, 'New here');
      expect(
        routines['missing']!.updatedAt,
        base.subtract(const Duration(days: 9)),
      );
      expect(
        find.text(
          'Restored the backup: 1 added, 1 updated, 1 already up to date',
        ),
        findsOneWidget,
      );
    });

    testWidgets('says when everything is up to date', (tester) async {
      final hoop = routine('r1', 'Hoop');
      final transfer = FakeRoutineFileTransfer()..next = backup([hoop]);
      await pumpScreen(tester, [hoop], transfer: transfer);

      await chooseMenu(tester, 'Restore a backup');

      expect(
        find.text('Nothing to restore: the routines here are up to date.'),
        findsOneWidget,
      );
    });

    testWidgets('stores the music, replacing the old copy', (tester) async {
      final library = FakeMusicLibrary({'a.mp3': 'old tune'});
      final transfer = FakeRoutineFileTransfer()
        ..next = backup(
          [routine('r1', 'Hoop'), routine('r2', 'Ball')],
          music: {'r1': 'new tune', 'r2': 'ball tune'},
        );
      final repository = await pumpScreen(
        tester,
        [routine('r1', 'Hoop', age: const Duration(days: 1)).withMusic(bolero)],
        transfer: transfer,
        musicLibrary: library,
      );

      await chooseMenu(tester, 'Restore a backup');

      final hoop = repository.routines['r1']!.music!;
      final ball = repository.routines['r2']!.music!;
      expect(library.files[hoop.fileName], 'new tune');
      expect(library.files[ball.fileName], 'ball tune');
      expect(library.files.containsKey('a.mp3'), isFalse);
    });

    testWidgets('a backup without music keeps the music here', (tester) async {
      final transfer = FakeRoutineFileTransfer()
        ..next = backup([routine('r1', 'Hoop')]);
      final repository = await pumpScreen(
        tester,
        [routine('r1', 'Hoop', age: const Duration(days: 1)).withMusic(bolero)],
        transfer: transfer,
        musicLibrary: FakeMusicLibrary({'a.mp3': 'tune'}),
      );

      await chooseMenu(tester, 'Restore a backup');

      expect(repository.routines['r1']!.music, bolero);
    });

    testWidgets('a damaged line stops part way and says so', (tester) async {
      final transfer = FakeRoutineFileTransfer()
        ..next = '${backup([routine('r1', 'Hoop')])}\nnot a routine';
      final repository = await pumpScreen(tester, [], transfer: transfer);

      await chooseMenu(tester, 'Restore a backup');

      expect(repository.routines.keys, {'r1'});
      expect(
        find.text(
          'Restoring stopped part way (1 added). The file may be damaged.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a single routine file still imports as a new routine', (
      tester,
    ) async {
      final transfer = FakeRoutineFileTransfer()
        ..next = RoutineFile.encode(routine('r1', 'From my coach'));
      final repository = await pumpScreen(tester, [], transfer: transfer);

      await chooseMenu(tester, 'Restore a backup');

      expect(repository.routines.values.single.id, isNot('r1'));
      expect(find.text('Imported "From my coach".'), findsOneWidget);
    });
  });
}
