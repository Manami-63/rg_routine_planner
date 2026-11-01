import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/app/app.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/music/presentation/music_providers.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';
import 'package:rg_routine_planner/features/routines/domain/routine_file.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';

import '../features/music/fake_music.dart';
import '../features/routines/fake_routine_file_transfer.dart';
import '../features/routines/fake_routine_repository.dart';

void main() {
  final file = RoutineFile.encode(
    Routine(
      id: 'r1',
      name: 'From my coach',
      db: DbRoutine(rulesetId: 'test-v1'),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  );

  Future<(FakeRoutineFileTransfer, FakeRoutineRepository)> pumpApp(
    WidgetTester tester,
  ) async {
    final transfer = FakeRoutineFileTransfer();
    final repository = FakeRoutineRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routineRepositoryProvider.overrideWithValue(repository),
          routineFileTransferProvider.overrideWithValue(transfer),
          musicLibraryProvider.overrideWithValue(FakeMusicLibrary()),
        ],
        child: const RgRoutinePlannerApp(),
      ),
    );
    await tester.pumpAndSettle();
    return (transfer, repository);
  }

  testWidgets('a file opened from another app is imported', (tester) async {
    final (transfer, repository) = await pumpApp(tester);

    transfer.opened['/inbox/a.rgroutine'] = file;
    transfer.fileOpened!('/inbox/a.rgroutine');
    await tester.pumpAndSettle();

    expect(repository.routines.values.single.name, 'From my coach');
    expect(transfer.opened, isEmpty);
    expect(find.text('Imported "From my coach".'), findsOneWidget);
  });

  testWidgets('an opened file that is broken is reported', (tester) async {
    final (transfer, repository) = await pumpApp(tester);

    transfer.opened['/inbox/a.rgroutine'] = 'not a routine';
    transfer.fileOpened!('/inbox/a.rgroutine');
    await tester.pumpAndSettle();

    expect(repository.routines, isEmpty);
    expect(find.text('Could not import this file.'), findsOneWidget);
  });
}
