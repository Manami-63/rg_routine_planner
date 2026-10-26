import '../../db_calculator/domain/db_routine.dart';
import '../../levels/domain/competition_level.dart';

/// A saved routine: identity, name, level and its DB content.
///
/// This is the unit that is persisted (and later synced to the server).
/// DA content will be added next to [db].
class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.db,
    required this.createdAt,
    required this.updatedAt,
    this.level,
  });

  /// A new, empty routine.
  Routine.create({
    required this.id,
    required String rulesetId,
    required DateTime now,
  }) : name = '',
       level = null,
       db = DbRoutine(rulesetId: rulesetId),
       createdAt = now,
       updatedAt = now;

  /// Globally unique (UUID), so routines created offline on different
  /// devices never clash when synced.
  final String id;
  final String name;

  /// The competition level, or `null` if none chosen.
  final CompetitionLevel? level;

  final DbRoutine db;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get rulesetId => db.rulesetId;

  Routine rename(String newName) => _copyWith(name: newName);

  Routine withLevel(CompetitionLevel? newLevel) => Routine(
    id: id,
    name: name,
    level: newLevel,
    db: db,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Routine withDb(DbRoutine newDb) => _copyWith(db: newDb);

  Routine withUpdatedAt(DateTime time) => _copyWith(updatedAt: time);

  Routine _copyWith({String? name, DbRoutine? db, DateTime? updatedAt}) =>
      Routine(
        id: id,
        name: name ?? this.name,
        level: level,
        db: db ?? this.db,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      other is Routine &&
      other.id == id &&
      other.name == name &&
      other.level == level &&
      other.db == db &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, name, level, db, createdAt, updatedAt);
}
