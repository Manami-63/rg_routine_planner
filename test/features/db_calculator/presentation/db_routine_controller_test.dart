import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';

import '../test_data.dart';

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

  DbRoutineController controller() =>
      container.read(dbRoutineControllerProvider.notifier);

  test('starts empty, unnamed and on the repository ruleset', () {
    final routine = container.read(dbRoutineControllerProvider);

    expect(routine.isEmpty, isTrue);
    expect(routine.name, isEmpty);
    expect(routine.rulesetId, testRuleset.id);
  });

  test('subtotal follows add, remove and clear', () {
    controller()
      ..add(testJump)
      ..add(testBalance);
    expect(
      container.read(dbScoreResultProvider).subtotal,
      const Score.hundredths(50),
    );

    controller().removeAt(0);
    expect(
      container.read(dbScoreResultProvider).subtotal,
      const Score.hundredths(20),
    );

    controller().clear();
    expect(container.read(dbScoreResultProvider).subtotal, Score.zero);
  });

  test('subtotal includes risks', () {
    controller()
      ..add(testJump)
      ..addRisk(RiskElement(rotation: testTwoRotations));
    final result = container.read(dbScoreResultProvider);

    expect(result.bodySubtotal, const Score.hundredths(30));
    expect(result.riskSubtotal, const Score.hundredths(20));
    expect(result.subtotal, const Score.hundredths(50));

    controller().removeRiskAt(0);
    expect(container.read(dbScoreResultProvider).riskSubtotal, Score.zero);
  });

  test('clear removes risks too', () {
    controller()
      ..add(testJump)
      ..addRisk(RiskElement(rotation: testTwoRotations))
      ..clear();

    expect(container.read(dbRoutineControllerProvider).isEmpty, isTrue);
  });

  test('rename updates the name', () {
    controller().rename('Ribbon final');

    expect(container.read(dbRoutineControllerProvider).name, 'Ribbon final');
  });
}
