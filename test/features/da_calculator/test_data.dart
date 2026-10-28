import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/ruleset.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/da_calculator/data/da_catalogue_repository.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_base.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';

import '../db_calculator/test_data.dart';

// DA test fixtures, in the same ruleset as the DB fixtures and independent
// of the app's FIG catalogue.

const _general = {
  DaCriterion.outsideVisualField,
  DaCriterion.withoutHands,
  DaCriterion.underLeg,
  DaCriterion.positionOnFloor,
  DaCriterion.fullBodyWave,
  DaCriterion.db,
  DaCriterion.rotation,
};

const testRoll = DaBase(
  id: 'hoop-roll',
  name: 'Test Roll',
  apparatus: Apparatus.hoop,
  value: Score.hundredths(30),
  rulesetId: 'test-v1',
  // "Under the leg" is N/A.
  criteria: {
    DaCriterion.outsideVisualField,
    DaCriterion.withoutHands,
    DaCriterion.positionOnFloor,
    DaCriterion.fullBodyWave,
    DaCriterion.db,
    DaCriterion.rotation,
  },
  note: 'Test roll note',
);

const testThrow = DaBase(
  id: 'hoop-throw',
  name: 'Test Throw',
  apparatus: Apparatus.hoop,
  value: Score.hundredths(20),
  rulesetId: 'test-v1',
  criteria: _general,
);

const testCatch = DaBase(
  id: 'hoop-catch',
  name: 'Test Catch',
  apparatus: Apparatus.hoop,
  value: Score.hundredths(30),
  rulesetId: 'test-v1',
  criteria: _general,
  startsCombination: true,
  isCatchFromHighThrow: true,
);

const testBallBounce = DaBase(
  id: 'ball-bounce',
  name: 'Test Bounce',
  apparatus: Apparatus.ball,
  value: Score.hundredths(20),
  rulesetId: 'test-v1',
  criteria: _general,
);

class FakeDaCatalogueRepository implements DaCatalogueRepository {
  FakeDaCatalogueRepository({
    this.bases = const [testRoll, testThrow, testCatch, testBallBounce],
    this.error,
  });

  final List<DaBase> bases;

  /// When set, [fetchBases] throws this error. Mutable so a test can make
  /// a retry succeed.
  Object? error;

  @override
  RulesetVersion get ruleset => testRuleset;

  @override
  Future<List<DaBase>> fetchBases() async {
    if (error case final error?) throw error;
    return bases;
  }
}
