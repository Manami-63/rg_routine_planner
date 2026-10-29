import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';
import 'package:rg_routine_planner/features/routines/presentation/routines_screen.dart';

import '../../db_calculator/test_data.dart';
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
    List<Routine> routines,
  ) async {
    final repository = FakeRoutineRepository(routines);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routineRepositoryProvider.overrideWithValue(repository)],
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
    expect(find.textContaining('FIG Senior · 2 DB · 1 risk'), findsOneWidget);
    expect(find.textContaining('No level · 0 DB · 0 risks'), findsNWidgets(2));
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
