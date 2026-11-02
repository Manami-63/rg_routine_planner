import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/ruleset.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_base.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_routine.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_scoring_engine.dart';

import '../../db_calculator/test_data.dart';
import '../test_data.dart';

void main() {
  const engine = ProvisionalDaScoringEngine(ruleset: testRuleset);

  const ovf = DaCriterion.outsideVisualField;
  const db = DaCriterion.db;
  const rotation = DaCriterion.rotation;
  const floor = DaCriterion.positionOnFloor;

  DaElement da(
    DaBase base, [
    Set<DaCriterion> criteria = const {ovf, db},
    DaBase? secondBase,
  ]) => DaElement(base: base, secondBase: secondBase, criteria: criteria);

  DaScoreResult calculate(
    List<DaElement> elements, {
    Apparatus? apparatus = Apparatus.hoop,
    int? maxCounted,
  }) => engine.calculate(
    DaRoutine(rulesetId: 'test-v1', elements: elements),
    apparatus: apparatus,
    maxCounted: maxCounted,
  );

  test('a DA chosen later adds nothing but holds its place', () {
    final pending = DaElement(base: const DaBase.pending(rulesetId: 'test-v1'));
    final result = calculate([pending, da(testRoll)], maxCounted: 1);
    expect(result.statuses, [DaStatus.notChosen, DaStatus.valid]);
    expect(result.counted, {0});
    expect(result.subtotal, Score.zero);
  });

  group('value', () {
    test('1 base is worth the base value', () {
      expect(engine.daValue(da(testRoll)), const Score.hundredths(30));
    });

    test('a 2nd base adds 0.10 to the highest base (#5.3.2)', () {
      expect(
        engine.daValue(da(testCatch, const {ovf}, testThrow)),
        const Score.hundredths(40),
      );
    });

    test('a manual value replaces it', () {
      expect(
        engine.daValue(
          DaElement(base: testRoll, manualValue: const Score.hundredths(45)),
        ),
        const Score.hundredths(45),
      );
    });
  });

  group('criteria', () {
    test('1 base needs 2 available criteria', () {
      final result = calculate([
        da(testRoll, const {ovf}),
        // "Under the leg" is N/A for the roll, so only 1 counts.
        da(testRoll, const {ovf, DaCriterion.underLeg}),
        da(testRoll),
      ]);

      expect(result.statuses, [
        DaStatus.tooFewCriteria,
        DaStatus.tooFewCriteria,
        DaStatus.valid,
      ]);
      expect(result.subtotal, const Score.hundredths(30));
      expect(result.daCount, 1);
    });

    test('2 bases need 1 criterion available for both', () {
      expect(engine.availableCriteria(testCatch, testRoll), testRoll.criteria);
      expect(engine.requiredCriteria(da(testCatch, const {}, testRoll)), 1);

      final result = calculate([
        da(testCatch, const {DaCriterion.underLeg}, testRoll),
        da(testCatch, const {rotation}, testRoll),
      ]);

      expect(result.statuses, [DaStatus.tooFewCriteria, DaStatus.valid]);
      expect(result.subtotal, const Score.hundredths(40));
    });
  });

  group('validity', () {
    test('an identical repetition is not valid but uses a DA (#5.6.2)', () {
      final result = calculate([
        da(testRoll),
        da(testRoll, const {ovf, rotation}),
        da(testRoll),
        da(testThrow),
      ], maxCounted: 3);

      expect(result.statuses, [
        DaStatus.valid,
        DaStatus.valid,
        DaStatus.repetition,
        DaStatus.valid,
      ]);
      // The repetition takes the 3rd counted DA, so the throw is not counted.
      expect(result.counted, {0, 1, 2});
      expect(result.subtotal, const Score.hundredths(60));
    });

    test('only 3 DA with a pre-acrobatic rotation are valid (#5.4.7)', () {
      DaElement preAcro(DaBase base) => DaElement(
        base: base,
        criteria: const {ovf, rotation},
        preAcrobatic: true,
      );
      final result = calculate([
        preAcro(testRoll),
        preAcro(testThrow),
        preAcro(testCatch),
        // A rotation that is not pre-acrobatic does not count towards 3.
        da(testRoll, const {db, rotation}),
        DaElement(
          base: testThrow,
          criteria: const {db, rotation},
          preAcrobatic: true,
        ),
      ]);

      expect(result.statuses, [
        DaStatus.valid,
        DaStatus.valid,
        DaStatus.valid,
        DaStatus.valid,
        DaStatus.tooManyPreAcrobatic,
      ]);
    });

    test('a base for another apparatus is not a DA', () {
      final result = calculate([da(testBallBounce), da(testRoll)]);

      expect(result.statuses.first, DaStatus.otherApparatus);
      expect(result.counted, {1});
    });

    test('an unknown base is not a DA', () {
      final result = calculate([
        da(const DaBase.unknown(id: 'gone', rulesetId: 'test-v1')),
      ]);

      expect(result.statuses.single, DaStatus.unknownBase);
      expect(result.subtotal, Score.zero);
    });

    test('a manual value skips the checks', () {
      final result = calculate([
        da(testRoll),
        DaElement(
          base: testRoll,
          criteria: const {ovf, db},
          manualValue: const Score.hundredths(10),
        ),
        DaElement(
          base: const DaBase.custom(name: 'Own DA', rulesetId: 'test-v1'),
          manualValue: const Score.hundredths(20),
        ),
      ]);

      expect(result.statuses, everyElement(DaStatus.valid));
      expect(result.subtotal, const Score.hundredths(60));
    });
  });

  group('counting', () {
    test('the first DA count, in chronological order (#5.2.1)', () {
      final result = calculate([
        da(testThrow),
        da(testRoll, const {ovf}), // Not a DA: does not use one.
        da(testRoll),
        da(testCatch),
      ], maxCounted: 2);

      expect(result.counted, {0, 2});
      expect(result.subtotal, const Score.hundredths(50));
      expect(result.countedCount, 2);
      expect(result.daCount, 3);
      expect(result.countLimitApplied, isTrue);
    });

    test('a maximum of 0 counts nothing (e.g. freehand)', () {
      final result = calculate([da(testRoll)], maxCounted: 0);

      expect(result.counted, isEmpty);
      expect(result.subtotal, Score.zero);
    });
  });

  test('warns from the 4th consecutive DA on the floor (#5.4.6)', () {
    final onFloor = da(testRoll, const {floor, ovf});
    final result = calculate([
      onFloor,
      da(testThrow, const {floor, ovf}),
      da(testCatch, const {floor, ovf}),
      da(testThrow, const {floor, db}),
      da(testCatch, const {floor, db}),
      da(testRoll), // Leaves the floor.
      da(testThrow, const {floor, rotation}),
    ]);

    expect(result.floorWarnings, {3, 4});
    // Only a warning: they stay valid.
    expect(result.statuses[3], DaStatus.valid);
  });

  test('results are always provisional', () {
    expect(calculate(const []).notices, {
      DaScoreNotice.unofficialRuleset,
      DaScoreNotice.rulesNotValidated,
    });
    const official = ProvisionalDaScoringEngine(
      ruleset: RulesetVersion(id: 'test-v1', label: 'T', isOfficial: true),
    );
    expect(official.calculate(DaRoutine(rulesetId: 'test-v1')).notices, {
      DaScoreNotice.rulesNotValidated,
    });
  });

  test('rejects data from another ruleset', () {
    expect(
      () => engine.calculate(DaRoutine(rulesetId: 'other')),
      throwsArgumentError,
    );
    expect(
      () => engine.daValue(
        DaElement(
          base: const DaBase.unknown(id: 'x', rulesetId: 'other'),
        ),
      ),
      throwsArgumentError,
    );
  });
}
