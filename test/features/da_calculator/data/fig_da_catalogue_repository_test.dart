import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/fig_ruleset.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/da_calculator/data/fig_da_catalogue_repository.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_base.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';

void main() {
  const repository = FigDaCatalogueRepository();
  late List<DaBase> bases;

  setUp(() async => bases = await repository.fetchBases());

  List<DaBase> of(Apparatus apparatus) =>
      bases.where((b) => b.apparatus == apparatus).toList();

  test('shares the FIG ruleset with DB', () {
    expect(repository.ruleset, figRuleset);
    for (final base in bases) {
      expect(base.rulesetId, figRulesetId);
    }
  });

  test('has every base of the DA tables (#5.8-5.11, #7.3)', () {
    expect(of(Apparatus.rope), hasLength(15));
    expect(of(Apparatus.hoop), hasLength(13));
    expect(of(Apparatus.ball), hasLength(11));
    expect(of(Apparatus.clubs), hasLength(15));
    expect(of(Apparatus.ribbon), hasLength(14));
    expect(of(Apparatus.freehand), isEmpty);
    expect(bases.map((b) => b.id).toSet(), hasLength(bases.length));
  });

  test('values are 0.20 to 0.40, the boomerang in the air the highest', () {
    for (final base in bases) {
      expect([20, 30, 40], contains(base.value.hundredths), reason: base.name);
    }
    expect(
      bases.where((b) => b.value == const Score.hundredths(40)).single.id,
      'fig-da-ribbon-boomerang-air',
    );
  });

  test('every base allows at least 2 criteria', () {
    for (final base in bases) {
      expect(base.criteria.length, greaterThanOrEqualTo(2), reason: base.id);
    }
  });

  test('Rope-specific criteria only on Rope passing bases', () {
    final withRopeCriteria = bases.where(
      (b) => b.criteria.any((c) => c.isRopeSpecific),
    );
    expect(withRopeCriteria.map((b) => b.id), [
      'fig-da-rope-passing-through',
      'fig-da-rope-passing-skips',
    ]);
  });

  test('each apparatus has 1 catch that starts a 2-base DA', () {
    for (final apparatus in Apparatus.values.where((a) => a.hasApparatus)) {
      final starters = of(apparatus).where((b) => b.startsCombination);
      expect(starters, hasLength(1), reason: apparatus.label);
      expect(starters.single.isCatchFromHighThrow, isTrue);
    }
  });

  test('other catches from a high throw cannot be a 2nd base', () {
    final catches = bases.where(
      (b) => b.isCatchFromHighThrow && !b.startsCombination,
    );
    expect(catches.map((b) => b.id), [
      'fig-da-rope-catch-open-rope',
      'fig-da-ball-catch-one-hand',
      'fig-da-ball-rebound-floor-high-throw',
      'fig-da-clubs-catch-one-hand',
      'fig-da-clubs-catch-simultaneous',
    ]);
  });

  test('N/A criteria match the table rows (spot checks)', () {
    DaBase base(String id) => bases.singleWhere((b) => b.id == 'fig-da-$id');

    expect(
      base('hoop-thrust').criteria,
      isNot(contains(DaCriterion.fullBodyWave)),
    );
    expect(base('hoop-thrust').criteria, isNot(contains(DaCriterion.rotation)));
    expect(
      base('ball-catch-one-hand').criteria,
      isNot(contains(DaCriterion.withoutHands)),
    );
    expect(
      base('ribbon-stick-without-hands').criteria,
      isNot(contains(DaCriterion.positionOnFloor)),
    );
    expect(base('rope-passing-skips').criteria, {
      DaCriterion.outsideVisualField,
      DaCriterion.withoutHands,
      DaCriterion.positionOnFloor,
      DaCriterion.ropeDoubleRotation,
      DaCriterion.ropeBackward,
      DaCriterion.ropeCrossedArms,
    });
  });
}
