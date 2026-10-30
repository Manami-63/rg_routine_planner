import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/floor/floor_cell.dart';

void main() {
  FloorCell n(int number) => FloorCell.fromNumber(number)!;

  test('cells are numbered 1 to 9 like text, front at the bottom', () {
    expect(FloorCell.backLeft.number, 1);
    expect(FloorCell.centre.number, 5);
    expect(FloorCell.frontRight.number, 9);
    expect(FloorCell.fromNumber(10), isNull);
    expect(FloorCell.fromNumber(null), isNull);
  });

  test('the zones are the corners and the centre', () {
    expect(FloorCell.zones.map((c) => c.number), [1, 3, 5, 7, 9]);
  });

  test('a straight move crosses the cells between', () {
    expect(n(1).crossedTo(n(3)), {n(2)});
    expect(n(1).crossedTo(n(9)), {n(5)});
    expect(n(3).crossedTo(n(7)), {n(5)});
    expect(n(2).crossedTo(n(8)), {n(5)});
    expect(n(4).crossedTo(n(6)), {n(5)});
    expect(n(1).crossedTo(n(6)), {n(2), n(5)});
    expect(n(1).crossedTo(n(2)), isEmpty);
    expect(n(5).crossedTo(n(5)), isEmpty);
  });

  test('touching only a corner point does not count', () {
    expect(n(2).crossedTo(n(4)), isEmpty);
    expect(n(6).crossedTo(n(8)), isEmpty);
  });
}
