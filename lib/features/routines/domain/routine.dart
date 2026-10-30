import '../../../core/floor/floor_cell.dart';
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
    List<FloorCell?>? danceStepCells,
  }) : da = da ?? DaRoutine(rulesetId: db.rulesetId),
       danceStepTimes = List.unmodifiable(danceStepTimes),
       danceStepCells = List.unmodifiable(
         danceStepCells ?? List<FloorCell?>.filled(danceStepTimes.length, null),
       ) {
    if (this.danceStepCells.length != this.danceStepTimes.length) {
      throw ArgumentError('danceStepCells must match danceStepTimes');
    }
  }

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
       danceStepCells = const [],
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

  /// Where on the floor each S starts (same positions), or `null`.
  final List<FloorCell?> danceStepCells;

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
    danceStepCells: danceStepCells,
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
    danceStepCells: danceStepCells,
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
    danceStepCells: danceStepCells,
    db: db,
    da: da,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Routine withNotes(String newNotes) => _copyWith(notes: newNotes);

  /// Adds or removes S to have [count]. Unmarked S are removed first.
  Routine withDanceStepCount(int count) {
    final times = [...danceStepTimes];
    final cells = [...danceStepCells];
    while (times.length < count) {
      times.add(null);
      cells.add(null);
    }
    while (times.length > count) {
      final unmarked = times.lastIndexOf(null);
      final index = unmarked == -1 ? times.length - 1 : unmarked;
      times.removeAt(index);
      cells.removeAt(index);
    }
    return _copyWith(danceStepTimes: times, danceStepCells: cells);
  }

  /// Sets when the S at [index] starts, keeping the marked S in time
  /// order. `null` clears the time and the cell.
  Routine withDanceStepTimeAt(int index, Duration? time) {
    final times = [...danceStepTimes]..[index] = time;
    final cells = [...danceStepCells];
    if (time == null) cells[index] = null;
    final order = timeOrder(times);
    return _copyWith(
      danceStepTimes: reorderBy(times, order),
      danceStepCells: reorderBy(cells, order),
    );
  }

  Routine withDanceStepCellAt(int index, FloorCell? cell) =>
      _copyWith(danceStepCells: [...danceStepCells]..[index] = cell);

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
    danceStepCells: danceStepCells,
    db: db,
    da: da,
    createdAt: now,
    updatedAt: now,
  );

  Routine _copyWith({
    String? name,
    String? notes,
    List<Duration?>? danceStepTimes,
    List<FloorCell?>? danceStepCells,
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
    danceStepCells: danceStepCells ?? this.danceStepCells,
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
      listEqual(other.danceStepCells, danceStepCells) &&
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
    Object.hashAll(danceStepCells),
    db,
    da,
    createdAt,
    updatedAt,
  );
}
