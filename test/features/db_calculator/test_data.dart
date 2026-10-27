import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/ruleset.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/data/db_catalogue_repository.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';

// Test fixtures, independent of the app's FIG catalogue so tests do not
// break when catalogue data changes.

const testRuleset = RulesetVersion(
  id: 'test-v1',
  label: 'Test ruleset',
  isOfficial: false,
);

const testJump = DbElement(
  id: 'jump',
  name: 'Test Jump',
  group: DbElementGroup.jump,
  value: Score.hundredths(30),
  rulesetId: 'test-v1',
  canBeInSeries: true,
  family: '1 · Test jumps',
);

const testBalance = DbElement(
  id: 'balance',
  name: 'Test Balance',
  group: DbElementGroup.balance,
  value: Score.hundredths(20),
  rulesetId: 'test-v1',
  canBeOnFlatFoot: true,
  canSlowTurn: true,
  family: '1 · Test balances',
);

const testRotation = DbElement(
  id: 'rotation',
  name: 'Test Rotation',
  group: DbElementGroup.rotation,
  value: Score.hundredths(10),
  rulesetId: 'test-v1',
  extraRotationValue: Score.hundredths(10),
  family: '1 · Test rotations',
);

const testTwoRotations = RiskRotationOption(
  id: 'rot-2',
  label: '2 rotations',
  rotations: 2,
  value: Score.hundredths(20),
  rulesetId: 'test-v1',
);

const testThreeRotations = RiskRotationOption(
  id: 'rot-3',
  label: '3 rotations',
  rotations: 3,
  value: Score.hundredths(30),
  rulesetId: 'test-v1',
);

const testCriterionA = RiskCriterion(
  id: 'crit-a',
  name: 'Criterion A',
  value: Score.hundredths(10),
  rulesetId: 'test-v1',
  phase: RiskPhase.throwing,
);

const testCriterionB = RiskCriterion(
  id: 'crit-b',
  name: 'Criterion B',
  value: Score.hundredths(20),
  rulesetId: 'test-v1',
  phase: RiskPhase.catching,
);

/// Only offered for Ball routines.
const testBallCriterion = RiskCriterion(
  id: 'crit-ball',
  name: 'Ball catch',
  value: Score.hundredths(10),
  rulesetId: 'test-v1',
  phase: RiskPhase.catching,
  apparatus: {Apparatus.ball},
  note: 'Test note',
);

final testRiskCatalogue = RiskCatalogue(
  rotationOptions: const [testTwoRotations, testThreeRotations],
  criteria: const [testCriterionA, testCriterionB, testBallCriterion],
);

class FakeDbCatalogueRepository implements DbCatalogueRepository {
  FakeDbCatalogueRepository({
    this.elements = const [testJump, testBalance, testRotation],
    this.future,
    this.error,
    RiskCatalogue? riskCatalogue,
    this.riskError,
  }) : riskCatalogue = riskCatalogue ?? testRiskCatalogue;

  final List<DbElement> elements;

  /// When set, awaited instead of returning [elements] (e.g. a pending
  /// future to test the loading state).
  final Future<List<DbElement>>? future;

  /// When set, [fetchElements] throws this error. Mutable so a test can
  /// make a retry succeed.
  Object? error;

  final RiskCatalogue riskCatalogue;

  /// When set, [fetchRiskCatalogue] throws this error.
  Object? riskError;

  @override
  RulesetVersion get ruleset => testRuleset;

  @override
  Future<List<DbElement>> fetchElements() async {
    if (error case final error?) throw error;
    return future ?? elements;
  }

  @override
  Future<RiskCatalogue> fetchRiskCatalogue() async {
    if (riskError case final riskError?) throw riskError;
    return riskCatalogue;
  }
}
