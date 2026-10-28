import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/score.dart';
import '../../../core/utils/list_equality.dart';
import 'da_criterion.dart';

/// An apparatus technical element ("base") a DA is built on, from a DA
/// table of the ruleset.
class DaBase {
  const DaBase({
    required this.id,
    required this.name,
    required Apparatus this.apparatus,
    required this.value,
    required this.rulesetId,
    required this.criteria,
    this.startsCombination = false,
    this.isCatchFromHighThrow = false,
    this.note,
  }) : isCustom = false,
       isUnknown = false;

  /// A DA the user entered themselves, valued by the entry's manual value
  /// (e.g. a level with its own DA rules).
  const DaBase.custom({required this.name, required this.rulesetId})
    : id = customId,
      apparatus = null,
      value = Score.zero,
      criteria = const {},
      startsCombination = false,
      isCatchFromHighThrow = false,
      note = null,
      isCustom = true,
      isUnknown = false;

  /// A saved reference whose id is not in the current catalogue. Keeps the
  /// id so re-saving does not lose it.
  const DaBase.unknown({required this.id, required this.rulesetId})
    : name = 'Unknown base',
      apparatus = null,
      value = Score.zero,
      criteria = const {},
      startsCombination = false,
      isCatchFromHighThrow = false,
      note = null,
      isCustom = false,
      isUnknown = true;

  /// The id stored for every custom DA.
  static const customId = 'custom';

  final String id;
  final String name;

  /// The apparatus whose table it is in; `null` for custom and unknown.
  final Apparatus? apparatus;
  final Score value;
  final String rulesetId;

  /// The criteria available for this base; the others are "N/A" (#5.4.2).
  final Set<DaCriterion> criteria;

  /// Whether a 2nd base can follow it in one DA, with 1 criterion during
  /// both (#5.1.3.2: "catch from a high throw").
  final bool startsCombination;

  /// A catch from a high throw. Only 1 such base is valid in one DA
  /// (#5.9, #5.10), so it cannot be the 2nd base.
  final bool isCatchFromHighThrow;

  /// A condition from the table shown with it. Not enforced.
  final String? note;

  final bool isCustom;
  final bool isUnknown;

  @override
  bool operator ==(Object other) =>
      other is DaBase &&
      other.id == id &&
      other.name == name &&
      other.apparatus == apparatus &&
      other.value == value &&
      other.rulesetId == rulesetId &&
      setEqual(other.criteria, criteria) &&
      other.startsCombination == startsCombination &&
      other.isCatchFromHighThrow == isCatchFromHighThrow &&
      other.note == note &&
      other.isCustom == isCustom &&
      other.isUnknown == isUnknown;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    apparatus,
    value,
    rulesetId,
    Object.hashAllUnordered(criteria),
    startsCombination,
    isCatchFromHighThrow,
    note,
    isCustom,
    isUnknown,
  );

  @override
  String toString() => 'DaBase($id)';
}
