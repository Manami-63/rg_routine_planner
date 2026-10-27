import '../../../core/scoring/score.dart';

/// How a gymnast performs one DB in a routine, beyond the catalogue entry.
///
/// Which options apply depends on the element (see `DbElement`); how they
/// change the value is the scoring engine's decision.
class DbElementOptions {
  const DbElementOptions({
    this.flatFoot = false,
    this.slowTurn = false,
    this.extraRotations = 0,
    this.seriesCount = 1,
    this.manualValue,
  });

  static const none = DbElementOptions();

  /// A balance performed on flat foot instead of relevé.
  final bool flatFoot;

  /// A balance performed with a "slow turn".
  final bool slowTurn;

  /// Rotations above the base rotation of a rotation DB.
  final int extraRotations;

  /// How many identical elements are performed in a series (1 = not a
  /// series). Each counts as 1 DB.
  final int seriesCount;

  /// A value entered by the user, replacing the calculated one (e.g. a DB
  /// newly approved by FIG, or a national value table), for each element
  /// of a series. It also makes a repetition count, for levels that allow
  /// it. `null` when not set.
  final Score? manualValue;

  bool get isDefault => this == none;

  @override
  bool operator ==(Object other) =>
      other is DbElementOptions &&
      other.flatFoot == flatFoot &&
      other.slowTurn == slowTurn &&
      other.extraRotations == extraRotations &&
      other.seriesCount == seriesCount &&
      other.manualValue == manualValue;

  @override
  int get hashCode =>
      Object.hash(flatFoot, slowTurn, extraRotations, seriesCount, manualValue);

  @override
  String toString() =>
      'DbElementOptions(flat: $flatFoot, slow: $slowTurn, '
      '+$extraRotations, x$seriesCount, manual: $manualValue)';
}
