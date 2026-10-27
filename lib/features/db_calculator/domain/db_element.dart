import '../../../core/scoring/db_element_group.dart';
import '../../../core/scoring/score.dart';

export '../../../core/scoring/db_element_group.dart';

/// A single Difficulty of Body element in a catalogue.
class DbElement {
  const DbElement({
    required this.id,
    required this.name,
    required this.group,
    required this.value,
    required this.rulesetId,
    this.canBeOnFlatFoot = false,
    this.canSlowTurn = false,
    this.extraRotationValue,
    this.canBeInSeries = false,
  }) : isCustom = false;

  /// An element the user entered themselves, e.g. a DB newly approved by
  /// FIG that is not in the catalogue yet. Its value is the routine's
  /// manual value (see `DbElementOptions.manualValue`).
  const DbElement.custom({
    required this.name,
    required this.group,
    required this.rulesetId,
  }) : id = customId,
       value = Score.zero,
       canBeOnFlatFoot = false,
       canSlowTurn = false,
       extraRotationValue = null,
       // The user decides; balances never form series (#10.9.6).
       canBeInSeries = group != DbElementGroup.balance,
       isCustom = true;

  /// The id stored for every custom element.
  static const customId = 'custom';

  /// A saved reference whose id is not in the current catalogue (e.g. the
  /// catalogue changed). Keeps the id so re-saving does not lose it.
  const DbElement.unknown({required this.id, required this.rulesetId})
    : name = 'Unknown element',
      group = DbElementGroup.unknown,
      value = Score.zero,
      canBeOnFlatFoot = false,
      canSlowTurn = false,
      extraRotationValue = null,
      canBeInSeries = false,
      isCustom = false;

  final String id;
  final String name;
  final DbElementGroup group;
  final Score value;

  /// The [RulesetVersion.id] this element's value belongs to.
  final String rulesetId;

  /// A balance on the foot whose listed value is on relevé, so it can also
  /// be performed on flat foot.
  final bool canBeOnFlatFoot;

  /// A balance that may be performed with a "slow turn".
  final bool canSlowTurn;

  /// The value of each rotation above the base, for rotation DB that can
  /// have additional rotations. `null` when not possible.
  final Score? extraRotationValue;

  /// A jump/leap or pivot/illusion that may be performed in a series of
  /// identical elements, each counting as 1 DB (#2.4.3, #8.10, #12.8).
  final bool canBeInSeries;

  final bool isCustom;

  bool get isUnknown => group == DbElementGroup.unknown;

  @override
  bool operator ==(Object other) =>
      other is DbElement &&
      other.id == id &&
      other.name == name &&
      other.group == group &&
      other.value == value &&
      other.rulesetId == rulesetId &&
      other.canBeOnFlatFoot == canBeOnFlatFoot &&
      other.canSlowTurn == canSlowTurn &&
      other.extraRotationValue == extraRotationValue &&
      other.canBeInSeries == canBeInSeries &&
      other.isCustom == isCustom;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    group,
    value,
    rulesetId,
    canBeOnFlatFoot,
    canSlowTurn,
    extraRotationValue,
    canBeInSeries,
    isCustom,
  );

  @override
  String toString() => 'DbElement($id, ${value.format()})';
}
