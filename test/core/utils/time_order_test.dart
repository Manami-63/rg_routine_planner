import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/utils/time_order.dart';

void main() {
  Duration s(int seconds) => Duration(seconds: seconds);

  test('timed items are sorted, untimed ones keep their positions', () {
    final times = [s(30), null, s(10), s(20), null];

    final order = timeOrder(times);

    expect(order, [2, 1, 3, 0, 4]);
    expect(reorderBy(times, order), [s(10), null, s(20), s(30), null]);
  });

  test('equal times keep their order', () {
    expect(timeOrder([s(5), s(5), s(1)]), [2, 0, 1]);
  });

  test('nothing timed changes nothing', () {
    expect(timeOrder([null, null]), [0, 1]);
    expect(timeOrder(const []), isEmpty);
  });
}
