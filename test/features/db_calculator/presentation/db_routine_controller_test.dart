import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/presentation/db_calculator_providers.dart';

import '../test_data.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test(
      overrides: [
        dbElementRepositoryProvider.overrideWithValue(
          FakeDbElementRepository(),
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

  test('rename updates the name', () {
    controller().rename('Ribbon final');

    expect(container.read(dbRoutineControllerProvider).name, 'Ribbon final');
  });
}
