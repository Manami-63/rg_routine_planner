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

  test('table columns give the right criteria (#5.9, p.66)', () {
    Set<DaCriterion> criteriaOf(String id) =>
        bases.singleWhere((b) => b.id == id).criteria;

    // Small throw: only "position on the floor" is N/A.
    expect(criteriaOf('fig-da-ball-small-throw'), {
      DaCriterion.outsideVisualField,
      DaCriterion.withoutHands,
      DaCriterion.underLeg,
      DaCriterion.rotation,
      DaCriterion.fullBodyWave,
      DaCriterion.db,
    });
    // Thrust: "position on the floor" and "DB" are N/A.
    expect(criteriaOf('fig-da-ball-thrust'), {
      DaCriterion.outsideVisualField,
      DaCriterion.withoutHands,
      DaCriterion.underLeg,
      DaCriterion.rotation,
      DaCriterion.fullBodyWave,
    });
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

  test('the catches that start a 2-base DA are those of #5.1.3.2', () {
    final starters = bases.where((b) => b.startsCombination);
    expect(starters.map((b) => b.id), [
      'fig-da-rope-catch-high-throw',
      'fig-da-hoop-catch-high-throw',
      'fig-da-ball-catch-one-hand',
      'fig-da-ball-catch-high-throw',
      'fig-da-clubs-catch-high-throw',
      'fig-da-clubs-catch-one-hand',
      'fig-da-clubs-catch-simultaneous',
      'fig-da-ribbon-catch-high-throw',
    ]);
    expect(starters.every((b) => b.isCatchFromHighThrow), isTrue);
  });

  test('other catches from a high throw cannot start a 2-base DA', () {
    final catches = bases.where(
      (b) => b.isCatchFromHighThrow && !b.startsCombination,
    );
    expect(catches.map((b) => b.id), [
      'fig-da-rope-catch-open-rope',
      'fig-da-ball-rebound-floor-high-throw',
    ]);
  });

  test('N/A criteria match the table rows (spot checks)', () {
    DaBase base(String id) => bases.singleWhere((b) => b.id == 'fig-da-$id');

    expect(base('hoop-thrust').criteria, {
      DaCriterion.outsideVisualField,
      DaCriterion.withoutHands,
      DaCriterion.underLeg,
      DaCriterion.rotation,
      DaCriterion.fullBodyWave,
    });
    expect(
      base('ball-catch-one-hand').criteria,
      isNot(contains(DaCriterion.withoutHands)),
    );
    expect(
      base('ribbon-stick-without-hands').criteria,
      isNot(contains(DaCriterion.rotation)),
    );
    expect(base('rope-passing-skips').criteria, {
      DaCriterion.outsideVisualField,
      DaCriterion.withoutHands,
      DaCriterion.rotation,
      DaCriterion.ropeDoubleRotation,
      DaCriterion.ropeBackward,
      DaCriterion.ropeCrossedArms,
    });
  });
}
