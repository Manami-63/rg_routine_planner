import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/da_calculator/presentation/da_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/music/domain/routine_music.dart';
import 'package:rg_routine_planner/features/music/presentation/music_providers.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';
import 'package:rg_routine_planner/features/routines/presentation/routines_screen.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/test_data.dart';
import '../../music/fake_music.dart';
import '../fake_routine_repository.dart';

void main() {
  final base = DateTime.utc(2026, 10, 26, 9);

  Routine routine(
    String id,
    String name, {
    Duration age = Duration.zero,
    DbRoutine? db,
  }) => Routine(
    id: id,
    name: name,
    level: id == 'senior' ? figSenior : null,
    db: db ?? DbRoutine(rulesetId: 'test-v1'),
    createdAt: base,
    updatedAt: base.subtract(age),
  );

  Future<FakeRoutineRepository> pumpScreen(
    WidgetTester tester,
    List<Routine> routines, {
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
        ],
        child: const MaterialApp(home: RoutinesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('shows an empty state', (tester) async {
    await pumpScreen(tester, []);

    expect(find.text('No routines yet'), findsOneWidget);
    expect(find.text('New routine'), findsOneWidget);
  });

  testWidgets('lists routines newest first with details', (tester) async {
    await pumpScreen(tester, [
      routine('old', 'Old hoop', age: const Duration(days: 2)),
      routine(
        'senior',
        'Ribbon',
        db: DbRoutine(
          rulesetId: 'test-v1',
          elements: const [testJump, testBalance],
          risks: [RiskElement(rotation: testTwoRotations)],
        ),
      ),
      routine('blank', '', age: const Duration(days: 1)),
    ]);

    final titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data);
    expect(titles, ['Ribbon', 'Untitled routine', 'Old hoop']);
    expect(
      find.textContaining('FIG\u00A0Senior · 2\u00A0DB · 1\u00A0risk'),
      findsOneWidget,
    );
    expect(
      find.textContaining('No\u00A0level · 0\u00A0DB · 0\u00A0risks'),
      findsNWidgets(2),
    );
  });

  Future<void> chooseAction(
    WidgetTester tester,
    String name,
    String action,
  ) async {
    await tester.tap(find.byTooltip('Options for $name'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
  }

  group('search and filters', () {
    Routine detailed(
      String id,
      String name, {
      required Apparatus apparatus,
      CompetitionLevel? level,
      String notes = '',
    }) => routine(
      id,
      name,
    ).withApparatus(apparatus).withLevel(level).withNotes(notes);

    final routines = [
      detailed(
        'r1',
        'Hoop final',
        apparatus: Apparatus.hoop,
        level: figSenior,
        notes: 'Music: Bolero',
      ),
      detailed('r2', 'Ball', apparatus: Apparatus.ball, level: figJunior),
      detailed('r3', 'Hoop old', apparatus: Apparatus.hoop),
    ];
    Finder tile(String id) => find.byKey(ValueKey('routine-$id'));

    testWidgets('search matches names and notes', (tester) async {
      await pumpScreen(tester, routines);

      await tester.enterText(find.byType(SearchBar), 'bolero');
      await tester.pump();
      expect(tile('r1'), findsOneWidget);
      expect(tile('r2'), findsNothing);
      expect(tile('r3'), findsNothing);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      expect(tile('r2'), findsOneWidget);
      expect(tile('r3'), findsOneWidget);
    });

    testWidgets('chips filter by apparatus and level', (tester) async {
      await pumpScreen(tester, routines);

      await tester.tap(find.widgetWithText(FilterChip, 'Hoop'));
      await tester.pump();
      expect(tile('r1'), findsOneWidget);
      expect(tile('r2'), findsNothing);
      expect(tile('r3'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'No level'));
      await tester.pump();
      expect(tile('r1'), findsNothing);
      expect(tile('r3'), findsOneWidget);

      // Tapping a selected chip clears it.
      await tester.tap(find.widgetWithText(FilterChip, 'Hoop'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilterChip, 'No level'));
      await tester.pump();
      expect(tile('r2'), findsOneWidget);
    });

    testWidgets('no match offers to clear the filters', (tester) async {
      await pumpScreen(tester, routines);

      await tester.tap(find.widgetWithText(FilterChip, 'Ball'));
      await tester.enterText(find.byType(SearchBar), 'hoop');
      await tester.pump();
      expect(find.text('No matching routines'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pump();
      expect(find.text('No matching routines'), findsNothing);
      expect(tile('r1'), findsOneWidget);
      expect(tile('r2'), findsOneWidget);
      expect(
        tester.widget<SearchBar>(find.byType(SearchBar)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('chips only appear when there is a choice', (tester) async {
      await pumpScreen(tester, [routine('r1', 'Hoop'), routine('r2', 'Ball')]);

      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing);
    });
  });

  group('music', () {
    const bolero = RoutineMusic(fileName: 'bolero.mp3', title: 'Bolero');

    testWidgets('duplicate gives the copy its own music file', (tester) async {
      final library = FakeMusicLibrary({bolero.fileName: '/picked/Bolero.mp3'});
      final repository = await pumpScreen(tester, [
        routine('r1', 'Hoop').withMusic(bolero),
      ], musicLibrary: library);

      await chooseAction(tester, 'Hoop', 'Duplicate');

      final copy = repository.routines.values.firstWhere((r) => r.id != 'r1');
      expect(copy.music!.title, 'Bolero');
      expect(copy.music!.fileName, isNot(bolero.fileName));
      expect(library.files, hasLength(2));
    });

    testWidgets('deleting a routine deletes its music', (tester) async {
      final library = FakeMusicLibrary({bolero.fileName: '/picked/Bolero.mp3'});
      await pumpScreen(tester, [
        routine('r1', 'Hoop').withMusic(bolero),
      ], musicLibrary: library);

      await chooseAction(tester, 'Hoop', 'Delete');
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(library.files, isEmpty);
    });
  });

  testWidgets('delete asks for confirmation', (tester) async {
    final repository = await pumpScreen(tester, [routine('r1', 'Hoop')]);

    await chooseAction(tester, 'Hoop', 'Delete');
    expect(find.text('Delete "Hoop"?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.routines, contains('r1'));

    await chooseAction(tester, 'Hoop', 'Delete');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(repository.routines, isEmpty);
    expect(find.text('No routines yet'), findsOneWidget);
  });

  testWidgets('duplicate saves a copy with the same content', (tester) async {
    final db = DbRoutine(
      rulesetId: 'test-v1',
      elements: const [testJump, testBalance],
    );
    final repository = await pumpScreen(tester, [
      routine('senior', 'Ribbon', db: db, age: const Duration(days: 1)),
    ]);

    await chooseAction(tester, 'Ribbon', 'Duplicate');

    expect(repository.routines, hasLength(2));
    final copy = repository.routines.values.firstWhere((r) => r.id != 'senior');
    expect(copy.name, 'Ribbon (copy)');
    expect(copy.db, db);
    expect(copy.level, figSenior);
    expect(repository.routines['senior']!.name, 'Ribbon');
    expect(find.text('Saved as "Ribbon (copy)".'), findsOneWidget);

    // The copy is the most recently updated, so it is listed first.
    expect(
      tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((tile) => (tile.title! as Text).data),
      ['Ribbon (copy)', 'Ribbon'],
    );
  });

  testWidgets('duplicate names an untitled copy', (tester) async {
    final repository = await pumpScreen(tester, [routine('blank', '')]);

    await chooseAction(tester, 'Untitled routine', 'Duplicate');

    expect(
      repository.routines.values.map((r) => r.name),
      containsAll(['', 'Untitled routine (copy)']),
    );
  });

  testWidgets('duplicate reports a failed save', (tester) async {
    final repository = await pumpScreen(tester, [routine('r1', 'Hoop')]);
    repository.saveError = Exception('disk full');

    await chooseAction(tester, 'Hoop', 'Duplicate');

    expect(repository.routines, hasLength(1));
    expect(find.text('Could not duplicate the routine.'), findsOneWidget);
  });

  testWidgets('shows each routine\'s provisional total', (tester) async {
    final repository = FakeRoutineRepository([
      routine(
        'r1',
        'Hoop',
        db: DbRoutine(
          rulesetId: 'test-v1',
          elements: const [testJump, testBalance],
        ),
      ),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routineRepositoryProvider.overrideWithValue(repository),
          dbCatalogueRepositoryProvider.overrideWithValue(
            FakeDbCatalogueRepository(),
          ),
          daCatalogueRepositoryProvider.overrideWithValue(
            FakeDaCatalogueRepository(),
          ),
        ],
        child: const MaterialApp(home: RoutinesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final total = find.byKey(const ValueKey('routine-total-r1'));

    expect(tester.widget<Text>(total).data, '0.50');

    // Recalculated after a change.
    await repository.saveRoutine(
      repository.routines['r1']!
          .withDb(DbRoutine(rulesetId: 'test-v1', elements: const [testJump]))
          .withUpdatedAt(base.add(const Duration(hours: 1))),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(total).data, '0.30');
  });

  testWidgets('shows a dash when the total cannot be calculated', (
    tester,
  ) async {
    // The test routines use a ruleset the app's catalogue does not have.
    await pumpScreen(tester, [routine('r1', 'Hoop')]);

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('routine-total-r1'))).data,
      '–',
    );
  });

  testWidgets('closing the new routine form creates nothing', (tester) async {
    final repository = await pumpScreen(tester, []);

    await tester.tap(find.text('New routine'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(repository.routines, isEmpty);
  });

  testWidgets('edit details saves without opening the routine', (tester) async {
    final repository = await pumpScreen(tester, [routine('r1', 'Hoop')]);

    await chooseAction(tester, 'Hoop', 'Edit details');
    await tester.enterText(find.byType(TextField), 'Hoop final');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.routines['r1']!.name, 'Hoop final');
    expect(repository.routines['r1']!.updatedAt.isAfter(base), isTrue);
    expect(find.text('Hoop final'), findsOneWidget);
  });

  test('formatDateTime uses day, short month, year and 24h time', () {
    final local = DateTime(2026, 10, 26, 14, 5);
    expect(formatDateTime(local), '26 Oct 2026, 14:05');
  });
}
