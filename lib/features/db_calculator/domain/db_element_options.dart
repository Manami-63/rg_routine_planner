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
    this.rotationCycles,
  });

  /// Only the first 10 Fouetté components are evaluated (#12.11).
  static const maxCycles = 10;

  /// Whether [text] is a valid [rotationCycles]: digits from 1 to 9.
  static bool areValidCycles(String text) => RegExp(r'^[1-9]+$').hasMatch(text);

  /// The rotations that count in [cycles]: those of the first 10.
  static int rotationsIn(String cycles) => cycles
      .split('')
      .take(maxCycles)
      .fold(0, (sum, digit) => sum + int.parse(digit));

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

  /// The rotations in each cycle of a Fouetté as digits, e.g. "2121" (6
  /// rotations), or `null`. It only records how it is performed:
  /// [extraRotations] is set from it and gives the value (#12.2.5).
  final String? rotationCycles;

  bool get isDefault => this == none;

  @override
  bool operator ==(Object other) =>
      other is DbElementOptions &&
      other.flatFoot == flatFoot &&
      other.slowTurn == slowTurn &&
      other.extraRotations == extraRotations &&
      other.seriesCount == seriesCount &&
      other.manualValue == manualValue &&
      other.rotationCycles == rotationCycles;

  @override
  int get hashCode => Object.hash(
    flatFoot,
    slowTurn,
    extraRotations,
    seriesCount,
    manualValue,
    rotationCycles,
  );

  @override
  String toString() =>
      'DbElementOptions(flat: $flatFoot, slow: $slowTurn, '
      '+$extraRotations, x$seriesCount, manual: $manualValue, '
      'cycles: $rotationCycles)';
}
