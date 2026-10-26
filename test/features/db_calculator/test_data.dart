import 'package:rg_routine_planner/core/scoring/ruleset.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/data/db_element_repository.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';

// Test fixtures, independent of the app's sample catalogue so tests do not
// break when sample values change.

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
);

const testBalance = DbElement(
  id: 'balance',
  name: 'Test Balance',
  group: DbElementGroup.balance,
  value: Score.hundredths(20),
  rulesetId: 'test-v1',
);

const testRotation = DbElement(
  id: 'rotation',
  name: 'Test Rotation',
  group: DbElementGroup.rotation,
  value: Score.hundredths(10),
  rulesetId: 'test-v1',
);

class FakeDbElementRepository implements DbElementRepository {
  FakeDbElementRepository({
    this.elements = const [testJump, testBalance, testRotation],
    this.future,
    this.error,
  });

  final List<DbElement> elements;

  /// When set, awaited instead of returning [elements] (e.g. a pending
  /// future to test the loading state).
  final Future<List<DbElement>>? future;

  /// When set, [fetchElements] throws this error. Mutable so a test can
  /// make a retry succeed.
  Object? error;

  @override
  RulesetVersion get ruleset => testRuleset;

  @override
  Future<List<DbElement>> fetchElements() async {
    if (error case final error?) throw error;
    return future ?? elements;
  }
}
