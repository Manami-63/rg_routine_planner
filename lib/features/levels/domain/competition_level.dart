import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/db_element_group.dart';
import '../../../core/scoring/score.dart';
import '../../../core/utils/list_equality.dart';
import 'count_limit.dart';

/// How many DB, risks (R) and DA a level allows, and which body groups it
/// requires.
///
/// What a maximum means depends on the category (see `DifficultyCategory`):
/// extra elements may still be performed, they are just not counted.
class LevelRequirements {
  const LevelRequirements({
    this.db = CountLimit.none,
    this.risk = CountLimit.none,
    this.da = CountLimit.none,
    this.requiredBodyGroups = const {},
    this.missingBodyGroupPenalty,
  });

  final CountLimit db;
  final CountLimit risk;
  final CountLimit da;

  /// Body groups the routine must include (e.g. one leap, one balance),
  /// among all its DB, counted or not. Missing ones only produce an
  /// advisory alert; no penalty is calculated.
  final Set<DbElementGroup> requiredBodyGroups;

  /// The penalty for each missing body group, when the level's rules state
  /// it (shown in the alert only). `null` when unknown.
  final Score? missingBodyGroupPenalty;

  bool get isValid => db.isValid && risk.isValid && da.isValid;

  LevelRequirements copyWith({
    CountLimit? db,
    CountLimit? risk,
    CountLimit? da,
    Set<DbElementGroup>? requiredBodyGroups,
  }) => LevelRequirements(
    db: db ?? this.db,
    risk: risk ?? this.risk,
    da: da ?? this.da,
    requiredBodyGroups: requiredBodyGroups ?? this.requiredBodyGroups,
    missingBodyGroupPenalty: missingBodyGroupPenalty,
  );

  @override
  bool operator ==(Object other) =>
      other is LevelRequirements &&
      other.db == db &&
      other.risk == risk &&
      other.da == da &&
      setEqual(other.requiredBodyGroups, requiredBodyGroups) &&
      other.missingBodyGroupPenalty == missingBodyGroupPenalty;

  @override
  int get hashCode => Object.hash(
    db,
    risk,
    da,
    Object.hashAllUnordered(requiredBodyGroups),
    missingBodyGroupPenalty,
  );

  @override
  String toString() =>
      'LevelRequirements(db: $db, risk: $risk, da: $da, '
      'groups: $requiredBodyGroups)';
}

/// A competition level a routine is planned for.
///
/// Shared by the DB and (future) DA calculators, so it lives in its own
/// feature rather than inside either of them.
class CompetitionLevel {
  const CompetitionLevel({
    required this.id,
    required this.label,
    required this.isFig,
    this.requirements,
    this.freehandRequirements,
  });

  /// A non-FIG level (e.g. a national level) whose requirements the user
  /// enters themselves. They are entered for the routine at hand, so the
  /// same numbers apply to freehand and apparatus routines.
  const CompetitionLevel.custom(LevelRequirements this.requirements)
    : id = customId,
      label = 'Non-FIG level',
      isFig = false,
      freehandRequirements = requirements;

  static const customId = 'custom';

  final String id;
  final String label;
  final bool isFig;

  /// Requirements for apparatus routines. `null` when they have not been
  /// added to the app yet.
  final LevelRequirements? requirements;

  /// Requirements for freehand routines, which often differ (e.g. more DB
  /// counted). `null` when not added or the level has no freehand.
  final LevelRequirements? freehandRequirements;

  bool get isCustom => id == customId;

  /// The requirements that apply to a routine with [apparatus]. Without an
  /// apparatus chosen, the apparatus requirements are used.
  LevelRequirements? requirementsFor(Apparatus? apparatus) =>
      apparatus == Apparatus.freehand ? freehandRequirements : requirements;

  @override
  bool operator ==(Object other) =>
      other is CompetitionLevel &&
      other.id == id &&
      other.label == label &&
      other.isFig == isFig &&
      other.requirements == requirements &&
      other.freehandRequirements == freehandRequirements;

  @override
  int get hashCode =>
      Object.hash(id, label, isFig, requirements, freehandRequirements);
}
