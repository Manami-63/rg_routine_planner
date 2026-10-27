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

    test('subtracts and multiplies', () {
      expect(
        const Score.hundredths(30) - const Score.hundredths(10),
        const Score.hundredths(20),
      );
      expect(const Score.hundredths(20) * 3, const Score.hundredths(60));
    });

    test('parses typed values', () {
      expect(Score.tryParse('0.4'), const Score.hundredths(40));
      expect(Score.tryParse('0.45'), const Score.hundredths(45));
      expect(Score.tryParse('.4'), const Score.hundredths(40));
      expect(Score.tryParse('1'), const Score.hundredths(100));
      expect(Score.tryParse(' 0,3 '), const Score.hundredths(30));
      expect(Score.tryParse('1.'), const Score.hundredths(100));
    });

    test('rejects invalid values', () {
      for (final text in ['', '.', 'abc', '0.455', '-0.1', '1.2.3']) {
        expect(Score.tryParse(text), isNull, reason: text);
      }
    });
  });
}
