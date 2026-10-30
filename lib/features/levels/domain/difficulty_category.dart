import 'competition_level.dart';
import 'count_limit.dart';

/// The kinds of difficulty a level limits, and what each maximum means.
///
/// A routine may contain more than the maximum; the extra elements are
/// not counted. Which ones count differs per category.
enum DifficultyCategory {
  /// The highest-valued DB count.
  db('DB', 'DB'),

  /// Risks count in performance order.
  risk('R', 'risks'),

  /// DA count in performance (chronological) order.
  da('DA', 'DA');

  const DifficultyCategory(this.label, this.noun);

  /// Short name used in summaries, e.g. "R".
  final String label;

  /// Name used for several, e.g. "the number of risks".
  final String noun;

  /// Name used after [count], e.g. "1 risk" or "3 risks".
  String nounFor(int count) => this == risk && count == 1 ? 'risk' : noun;

  CountLimit limitOf(LevelRequirements requirements) => switch (this) {
    db => requirements.db,
    risk => requirements.risk,
    da => requirements.da,
  };

  /// Which elements count when there are more than [max], e.g. "highest 6
  /// count".
  String countedRule(int max) => switch (this) {
    db => 'highest $max count',
    risk || da => 'first $max count',
  };
}
