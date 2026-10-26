import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_routine_providers.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_controller.dart';

import '../../db_calculator/test_data.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test(
      overrides: [
        dbCatalogueRepositoryProvider.overrideWithValue(
          FakeDbCatalogueRepository(),
        ),
      ],
    );
  });

  RoutineController controller() =>
      container.read(routineControllerProvider.notifier);

  test('starts empty, unnamed, without level, on the repository ruleset', () {
    final routine = container.read(routineControllerProvider);

    expect(routine.db.isEmpty, isTrue);
    expect(routine.name, isEmpty);
    expect(routine.level, isNull);
    expect(routine.rulesetId, testRuleset.id);
    expect(routine.id, isNotEmpty);
  });

  test('subtotal follows add, remove and clear', () {
    controller()
      ..addElement(testJump)
      ..addElement(testBalance);
    expect(
      container.read(dbScoreResultProvider).subtotal,
      const Score.hundredths(50),
    );

    controller().removeElementAt(0);
    expect(
      container.read(dbScoreResultProvider).subtotal,
      const Score.hundredths(20),
    );

    controller().clearDb();
    expect(container.read(dbScoreResultProvider).subtotal, Score.zero);
  });

  test('subtotal includes risks', () {
    controller()
      ..addElement(testJump)
      ..addRisk(RiskElement(rotation: testTwoRotations));
    final result = container.read(dbScoreResultProvider);

    expect(result.bodySubtotal, const Score.hundredths(30));
    expect(result.riskSubtotal, const Score.hundredths(20));
    expect(result.subtotal, const Score.hundredths(50));

    controller().removeRiskAt(0);
    expect(container.read(dbScoreResultProvider).riskSubtotal, Score.zero);
  });

  test('clearing DB content keeps name and level', () {
    controller()
      ..rename('Hoop')
      ..selectLevel(figSenior)
      ..addElement(testJump)
      ..addRisk(RiskElement(rotation: testTwoRotations))
      ..clearDb();
    final routine = container.read(routineControllerProvider);

    expect(routine.db.isEmpty, isTrue);
    expect(routine.name, 'Hoop');
    expect(routine.level, figSenior);
  });

  test('rename and selectLevel update the routine', () {
    controller()
      ..rename('Ribbon final')
      ..selectLevel(figJunior);
    final routine = container.read(routineControllerProvider);

    expect(routine.name, 'Ribbon final');
    expect(routine.level, figJunior);
  });
}
