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

  testWidgets('delete asks for confirmation', (tester) async {
    final repository = await pumpScreen(tester, [routine('r1', 'Hoop')]);

    await tester.tap(find.byTooltip('Delete Hoop'));
    await tester.pumpAndSettle();
    expect(find.text('Delete "Hoop"?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.routines, contains('r1'));

    await tester.tap(find.byTooltip('Delete Hoop'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(repository.routines, isEmpty);
    expect(find.text('No routines yet'), findsOneWidget);
  });

  test('formatDateTime uses day, short month, year and 24h time', () {
    final local = DateTime(2026, 10, 26, 14, 5);
    expect(formatDateTime(local), '26 Oct 2026, 14:05');
  });
}
