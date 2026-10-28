import '../../../core/scoring/apparatus.dart';
import '../../da_calculator/domain/da_routine.dart';
import '../../db_calculator/domain/db_routine.dart';
import '../../levels/domain/competition_level.dart';

/// A saved routine: identity, name, apparatus, level and its DB and DA
/// content.
///
/// This is the unit that is persisted (and later synced to the server).
class Routine {
  /// Without [da], the routine has no DA yet.
  Routine({
    required this.id,
    required this.name,
    required this.db,
    required this.createdAt,
    required this.updatedAt,
    DaRoutine? da,
    this.apparatus,
    this.level,
  }) : da = da ?? DaRoutine(rulesetId: db.rulesetId);

  /// A new, empty routine.
  Routine.create({
    required this.id,
    required String rulesetId,
    required DateTime now,
  }) : name = '',
       apparatus = null,
       level = null,
       db = DbRoutine(rulesetId: rulesetId),
       da = DaRoutine(rulesetId: rulesetId),
       createdAt = now,
       updatedAt = now;

  /// Globally unique (UUID), so routines created offline on different
  /// devices never clash when synced.
  final String id;
  final String name;

  /// The apparatus, or `null` if none chosen.
  final Apparatus? apparatus;

  /// The competition level, or `null` if none chosen.
  final CompetitionLevel? level;

  final DbRoutine db;
  final DaRoutine da;

  /// Timestamps are UTC; convert with `toLocal()` only for display.
  final DateTime createdAt;
  final DateTime updatedAt;

  String get rulesetId => db.rulesetId;

  Routine rename(String newName) => _copyWith(name: newName);

  // Nullable fields are set with explicit constructors, because
  // `_copyWith` cannot tell "set to null" from "keep".
  Routine withApparatus(Apparatus? newApparatus) => Routine(
    id: id,
    name: name,
    apparatus: newApparatus,
    level: level,
    db: db,
    da: da,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Routine withLevel(CompetitionLevel? newLevel) => Routine(
    id: id,
    name: name,
    apparatus: apparatus,
    level: newLevel,
    db: db,
    da: da,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Routine withDb(DbRoutine newDb) => _copyWith(db: newDb);

  Routine withDa(DaRoutine newDa) => _copyWith(da: newDa);

  Routine withUpdatedAt(DateTime time) => _copyWith(updatedAt: time);

  Routine _copyWith({
    String? name,
    DbRoutine? db,
    DaRoutine? da,
    DateTime? updatedAt,
  }) => Routine(
    id: id,
    name: name ?? this.name,
    apparatus: apparatus,
    level: level,
    db: db ?? this.db,
    da: da ?? this.da,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is Routine &&
      other.id == id &&
      other.name == name &&
      other.apparatus == apparatus &&
      other.level == level &&
      other.db == db &&
      other.da == da &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(id, name, apparatus, level, db, da, createdAt, updatedAt);
}
