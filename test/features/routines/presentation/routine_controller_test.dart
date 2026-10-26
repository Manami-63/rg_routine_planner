import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_routine_providers.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_controller.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_providers.dart';

import '../../db_calculator/pump_db_calculator.dart';
import '../../db_calculator/test_data.dart';
import '../fake_routine_repository.dart';

void main() {
  late FakeRoutineRepository repository;
  late ProviderContainer container;

  ProviderContainer createContainer() => ProviderContainer(
    overrides: [
      dbCatalogueRepositoryProvider.overrideWithValue(
        FakeDbCatalogueRepository(),
      ),
      routineRepositoryProvider.overrideWithValue(repository),
    ],
  );

  /// Loads the routine and keeps its auto-disposing providers alive.
  Future<RoutineController> load() async {
    container.listen(routineControllerProvider(testRoutineId), (_, _) {});
    container.listen(routineSaveStatusProvider(testRoutineId), (_, _) {});
    await container.read(routineControllerProvider(testRoutineId).future);
    return container.read(routineControllerProvider(testRoutineId).notifier);
  }

  SaveStatus status() =>
      container.read(routineSaveStatusProvider(testRoutineId));

  /// Lets queued saves (futures) complete.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() {
    repository = FakeRoutineRepository([emptyTestRoutine()]);
    container = createContainer();
    addTearDown(container.dispose);
  });

  test('loads the routine from the repository', () async {
    await load();

    final routine = container.read(routineProvider(testRoutineId));
    expect(routine, emptyTestRoutine());
  });

  test('a missing routine fails with RoutineNotFoundException', () async {
    container.listen(routineControllerProvider('missing'), (_, _) {});

    await expectLater(
      container.read(routineControllerProvider('missing').future),
      throwsA(isA<RoutineNotFoundException>()),
    );
  });

  test('DB changes save immediately and update the timestamp', () async {
    final controller = await load();

    controller.addElement(testJump);
    await settle();

    final saved = repository.routines[testRoutineId]!;
    expect(saved.db.elements, [testJump]);
    expect(saved.updatedAt.isAfter(emptyTestRoutine().updatedAt), isTrue);
    expect(status(), SaveStatus.saved);
  });

  test('subtotal follows the routine', () async {
    final controller = await load();
    container.listen(dbScoreResultProvider(testRoutineId), (_, _) {});

    controller
      ..addElement(testJump)
      ..addRisk(RiskElement(rotation: testTwoRotations));
    final result = container.read(dbScoreResultProvider(testRoutineId));

    expect(result.bodySubtotal, const Score.hundredths(30));
    expect(result.riskSubtotal, const Score.hundredths(20));
    expect(result.subtotal, const Score.hundredths(50));
  });

  test('renaming saves after a pause, not on every keystroke', () async {
    final controller = await load();

    controller
      ..rename('H')
      ..rename('Ho')
      ..rename('Hoop');
    await settle();

    expect(repository.routines[testRoutineId]!.name, isEmpty);
    expect(status(), SaveStatus.saving);

    await Future<void>.delayed(
      RoutineController.nameSaveDelay + const Duration(milliseconds: 50),
    );

    expect(repository.routines[testRoutineId]!.name, 'Hoop');
    expect(repository.saveCount, 1);
    expect(status(), SaveStatus.saved);
  });

  test('a pending rename is saved when the controller is disposed', () async {
    final controller = await load();

    controller.rename('Leaving quickly');
    container.dispose();
    await settle();

    expect(repository.routines[testRoutineId]!.name, 'Leaving quickly');
  });

  test('a failed save is reported and can be retried', () async {
    final controller = await load();
    repository.saveError = StateError('disk full');

    controller.addElement(testJump);
    await settle();
    expect(status(), SaveStatus.failed);

    repository.saveError = null;
    controller.saveNow();
    await settle();

    expect(status(), SaveStatus.saved);
    expect(repository.routines[testRoutineId]!.db.elements, [testJump]);
  });

  test('clearing DB content keeps name and level', () async {
    final controller = await load();

    controller
      ..rename('Hoop')
      ..selectLevel(figSenior)
      ..addElement(testJump)
      ..clearDb();
    final routine = container.read(routineProvider(testRoutineId));

    expect(routine.db.isEmpty, isTrue);
    expect(routine.name, 'Hoop');
    expect(routine.level, figSenior);
  });
}
