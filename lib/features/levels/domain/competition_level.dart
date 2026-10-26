import 'count_limit.dart';

/// How many DB and DA a level requires or allows.
class LevelRequirements {
  const LevelRequirements({
    this.db = CountLimit.none,
    this.da = CountLimit.none,
  });

  final CountLimit db;
  final CountLimit da;

  bool get isValid => db.isValid && da.isValid;

  LevelRequirements copyWith({CountLimit? db, CountLimit? da}) =>
      LevelRequirements(db: db ?? this.db, da: da ?? this.da);

  @override
  bool operator ==(Object other) =>
      other is LevelRequirements && other.db == db && other.da == da;

  @override
  int get hashCode => Object.hash(db, da);

  @override
  String toString() => 'LevelRequirements(db: $db, da: $da)';
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
  });

  /// A non-FIG level (e.g. a national level) whose requirements the user
  /// enters themselves.
  const CompetitionLevel.custom(LevelRequirements this.requirements)
    : id = customId,
      label = 'Non-FIG level',
      isFig = false;

  static const customId = 'custom';

  final String id;
  final String label;
  final bool isFig;

  /// `null` when official requirements have not been added to the app yet.
  final LevelRequirements? requirements;

  bool get isCustom => id == customId;

  @override
  bool operator ==(Object other) =>
      other is CompetitionLevel &&
      other.id == id &&
      other.label == label &&
      other.isFig == isFig &&
      other.requirements == requirements;

  @override
  int get hashCode => Object.hash(id, label, isFig, requirements);
}
