import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';

void main() {
  group('Score', () {
    test('adds without floating-point drift', () {
      const a = Score.hundredths(10);
      const b = Score.hundredths(20);

      expect(a + b, const Score.hundredths(30));
      expect((a + b).format(), '0.30');
    });

    test('formats with two decimal places', () {
      expect(Score.zero.format(), '0.00');
      expect(const Score.hundredths(5).format(), '0.05');
      expect(const Score.hundredths(250).format(), '2.50');
      expect(const Score.hundredths(-15).format(), '-0.15');
    });

    test('compares by value', () {
      expect(
        const Score.hundredths(10).compareTo(const Score.hundredths(20)),
        lessThan(0),
      );
      expect(const Score.hundredths(10), const Score.hundredths(10));
    });
  });
}
