import '../../../core/scoring/apparatus.dart';
import '../../../core/utils/list_equality.dart';
import '../../../core/utils/time_order.dart';
import '../../da_calculator/domain/da_routine.dart';
import '../../db_calculator/domain/db_routine.dart';
import '../../levels/domain/competition_level.dart';
import '../../music/domain/routine_music.dart';

/// A saved routine: identity, name, apparatus, level, notes, music, its
/// dance steps combinations and its DB and DA content.
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
    this.notes = '',
    this.music,
    List<Duration?> danceStepTimes = const [],
  }) : da = da ?? DaRoutine(rulesetId: db.rulesetId),
       danceStepTimes = List.unmodifiable(danceStepTimes);

  /// A new, empty routine.
  Routine.create({
    required this.id,
    required String rulesetId,
    required DateTime now,
  }) : name = '',
       apparatus = null,
       level = null,
       notes = '',
       music = null,
       danceStepTimes = const [],
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

  /// Free text from the user, e.g. music or choreography reminders.
  final String notes;

  /// The routine's music, or `null` if none was added.
  final RoutineMusic? music;

  /// The routine's dance steps combinations (S): when each starts in the
  /// music, or `null` when not marked. S have no other details.
  final List<Duration?> danceStepTimes;

  int get danceStepCount => danceStepTimes.length;

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
    notes: notes,
    music: music,
    danceStepTimes: danceStepTimes,
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
    notes: notes,
    music: music,
    danceStepTimes: danceStepTimes,
    db: db,
    da: da,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Routine withMusic(RoutineMusic? newMusic) => Routine(
    id: id,
    name: name,
    apparatus: apparatus,
    level: level,
    notes: notes,
    music: newMusic,
    danceStepTimes: danceStepTimes,
    db: db,
    da: da,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Routine withNotes(String newNotes) => _copyWith(notes: newNotes);

  /// Adds or removes S to have [count]. Unmarked S are removed first.
  Routine withDanceStepCount(int count) {
    final times = [...danceStepTimes];
    while (times.length < count) {
      times.add(null);
    }
    while (times.length > count) {
      final unmarked = times.lastIndexOf(null);
      times.removeAt(unmarked == -1 ? times.length - 1 : unmarked);
    }
    return _copyWith(danceStepTimes: times);
  }

  /// Sets when the S at [index] starts (`null` to clear it), keeping the
  /// marked S in time order.
  Routine withDanceStepTimeAt(int index, Duration? time) {
    final times = [...danceStepTimes]..[index] = time;
    return _copyWith(danceStepTimes: reorderBy(times, timeOrder(times)));
  }

  Routine withDb(DbRoutine newDb) => _copyWith(db: newDb);

  Routine withDa(DaRoutine newDa) => _copyWith(da: newDa);

  Routine withUpdatedAt(DateTime time) => _copyWith(updatedAt: time);

  /// A copy saved as a new routine: same content, new [id] and [name],
  /// created and updated [now]. It refers to the same music file, so give
  /// it its own copy (`withMusic`) before saving.
  Routine duplicate({
    required String id,
    required String name,
    required DateTime now,
  }) => Routine(
    id: id,
    name: name,
    apparatus: apparatus,
    level: level,
    notes: notes,
    music: music,
    danceStepTimes: danceStepTimes,
    db: db,
    da: da,
    createdAt: now,
    updatedAt: now,
  );

  Routine _copyWith({
    String? name,
    String? notes,
    List<Duration?>? danceStepTimes,
    DbRoutine? db,
    DaRoutine? da,
    DateTime? updatedAt,
  }) => Routine(
    id: id,
    name: name ?? this.name,
    apparatus: apparatus,
    level: level,
    notes: notes ?? this.notes,
    music: music,
    danceStepTimes: danceStepTimes ?? this.danceStepTimes,
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
      other.notes == notes &&
      other.music == music &&
      listEqual(other.danceStepTimes, danceStepTimes) &&
      other.db == db &&
      other.da == da &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    apparatus,
    level,
    notes,
    music,
    Object.hashAll(danceStepTimes),
    db,
    da,
    createdAt,
    updatedAt,
  );
}
