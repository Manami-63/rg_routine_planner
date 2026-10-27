import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_counting.dart';

void main() {
  DbCounting select({
    List<int> values = const [],
    List<int>? dbs,
    int risks = 0,
    DbCountLimits limits = DbCountLimits.none,
  }) => DbCounting.select(
    elementValues: [for (final v in values) Score.hundredths(v)],
    dbPerElement: dbs ?? List.filled(values.length, 1),
    riskCount: risks,
    limits: limits,
  );

  test('without limits everything counts', () {
    final counting = select(values: [30, 20], risks: 2);

    expect(counting.countedPerElement, [1, 1]);
    expect(counting.countedRisks, {0, 1});
  });

  test('the highest-valued elements count', () {
    final counting = select(
      values: [10, 30, 20, 10],
      limits: const DbCountLimits(maxElements: 2),
    );

    expect(counting.countedPerElement, [0, 1, 1, 0]);
    expect(counting.isElementCounted(0), isFalse);
  });

  test('an earlier element wins a tie', () {
    final counting = select(
      values: [30, 30, 30],
      limits: const DbCountLimits(maxElements: 2),
    );

    expect(counting.countedPerElement, [1, 1, 0]);
  });

  test('the first risks count', () {
    final counting = select(risks: 4, limits: const DbCountLimits(maxRisks: 3));

    expect(counting.countedRisks, {0, 1, 2});
    expect(counting.isRiskCounted(3), isFalse);
  });

  test('a maximum of zero counts nothing', () {
    final counting = select(
      values: [30],
      risks: 1,
      limits: const DbCountLimits(maxElements: 0, maxRisks: 0),
    );

    expect(counting.countedDbCount, 0);
    expect(counting.countedRisks, isEmpty);
  });

  test('fewer than the maximum all count', () {
    final counting = select(
      values: [30],
      risks: 1,
      limits: const DbCountLimits(maxElements: 6, maxRisks: 3),
    );

    expect(counting.countedPerElement, [1]);
    expect(counting.countedRisks, {0});
  });

  test('each element of a series is 1 DB; part of a series may count', () {
    // A series of 3 (0.50 each) and a single 0.30; highest 4 count.
    final counting = select(
      values: [50, 30, 40],
      dbs: [3, 1, 1],
      limits: const DbCountLimits(maxElements: 4),
    );

    expect(counting.countedPerElement, [3, 0, 1]);
    expect(counting.countedDbCount, 4);
    expect(counting.isElementCounted(1), isFalse);
  });

  test('an element worth 0 DB (a repetition) never counts', () {
    final counting = select(values: [30, 30], dbs: [1, 0]);

    expect(counting.countedPerElement, [1, 0]);
  });
}
