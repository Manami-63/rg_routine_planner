import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';

void main() {
  group('CountLimit', () {
    test('no limit reports noLimit for any count', () {
      expect(CountLimit.none.isSet, isFalse);
      expect(CountLimit.none.statusOf(0), CountStatus.noLimit);
      expect(CountLimit.none.statusOf(99), CountStatus.noLimit);
    });

    test('min and max classify counts', () {
      const limit = CountLimit(min: 2, max: 4);

      expect(limit.statusOf(1), CountStatus.belowMinimum);
      expect(limit.statusOf(2), CountStatus.withinLimits);
      expect(limit.statusOf(4), CountStatus.withinLimits);
      expect(limit.statusOf(5), CountStatus.aboveMaximum);
    });

    test('works with only a minimum or only a maximum', () {
      expect(const CountLimit(min: 3).statusOf(10), CountStatus.withinLimits);
      expect(const CountLimit(min: 3).statusOf(2), CountStatus.belowMinimum);
      expect(const CountLimit(max: 3).statusOf(0), CountStatus.withinLimits);
      expect(const CountLimit(max: 3).statusOf(4), CountStatus.aboveMaximum);
    });

    test('is invalid when minimum exceeds maximum', () {
      expect(const CountLimit(min: 2, max: 4).isValid, isTrue);
      expect(const CountLimit(min: 4, max: 4).isValid, isTrue);
      expect(const CountLimit(min: 5, max: 4).isValid, isFalse);
      expect(const CountLimit(min: 5).isValid, isTrue);
    });

    test('withMin and withMax keep the other side', () {
      const limit = CountLimit(min: 1, max: 3);

      expect(limit.withMin(null), const CountLimit(max: 3));
      expect(limit.withMax(5), const CountLimit(min: 1, max: 5));
    });
  });
}
