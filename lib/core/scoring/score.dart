/// A difficulty score, stored as an integer number of hundredths.
///
/// Rhythmic gymnastics values move in steps such as 0.10 or 0.05. Adding
/// `double`s accumulates binary rounding errors (`0.1 + 0.2 != 0.3`), so
/// all arithmetic is done on whole hundredths and only converted to a
/// decimal string for display.
class Score implements Comparable<Score> {
  const Score.hundredths(this.hundredths);

  static const zero = Score.hundredths(0);

  final int hundredths;

  Score operator +(Score other) =>
      Score.hundredths(hundredths + other.hundredths);

  /// Formats the score with two decimal places, e.g. `0.30`.
  String format() {
    final sign = hundredths < 0 ? '-' : '';
    final absolute = hundredths.abs();
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '$sign$whole.$fraction';
  }

  @override
  int compareTo(Score other) => hundredths.compareTo(other.hundredths);

  @override
  bool operator ==(Object other) =>
      other is Score && other.hundredths == hundredths;

  @override
  int get hashCode => hundredths.hashCode;

  @override
  String toString() => 'Score(${format()})';
}
