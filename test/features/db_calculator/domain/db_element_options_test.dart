import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/data/fig_db_catalogue_repository.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_scoring_engine.dart';
import 'package:rg_routine_planner/core/scoring/fig_ruleset.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';

void main() {
  test('cycles are digits from 1 to 9', () {
    expect(DbElementOptions.areValidCycles('2121'), isTrue);
    expect(DbElementOptions.areValidCycles(''), isFalse);
    expect(DbElementOptions.areValidCycles('201'), isFalse);
    expect(DbElementOptions.areValidCycles('2a'), isFalse);
  });

  test('only the first 10 cycles count (#12.11)', () {
    expect(DbElementOptions.rotationsIn('2121'), 6);
    expect(DbElementOptions.rotationsIn('111112222299'), 15);
  });

  test(
    'the Fouetté values match the Code of Points (#12.2.5, #12.11)',
    () async {
      final elements = await const FigDbCatalogueRepository().fetchElements();
      final passe = elements.singleWhere((e) => e.id == 'fig-3.1601');
      final straight = elements.singleWhere((e) => e.id == 'fig-3.1602');
      const engine = ProvisionalDbScoringEngine(ruleset: figRuleset);
      Score value(element, int rotations) => engine.elementValue(
        element,
        DbElementOptions(extraRotations: rotations - 1),
      );

      expect(passe.canHaveCycles, isTrue);
      expect(straight.canHaveCycles, isTrue);
      expect(elements.where((e) => e.canHaveCycles), hasLength(2));
      // #12.2.5 examples: 6 rotations in passé, 5 with the leg straight.
      expect(value(passe, 6), const Score.hundredths(60));
      expect(value(straight, 5), const Score.hundredths(60));
      // #12.11 example: 5 × 360° + 5 × 720°.
      expect(
        value(passe, DbElementOptions.rotationsIn('1111122222')),
        const Score.hundredths(150),
      );
    },
  );
}
