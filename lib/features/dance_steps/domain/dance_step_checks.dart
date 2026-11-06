import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/score.dart';
import '../../routines/domain/routine.dart';

/// How long a dance steps combination lasts at least (CoP #5.2.1): the
/// checks look at this much music from each S's time.
const danceStepDuration = Duration(seconds: 8);

/// DB worth this much or more may not be performed during an S (#5.2.5).
const danceStepDbValueLimit = Score.hundredths(20);

/// The kinds of item that may not be performed during an S (#5.2.5).
enum DanceStepConflictKind {
  /// Every risk includes a high throw.
  risk('R'),
  da('DA'),

  /// Only DB worth [danceStepDbValueLimit] or more.
  db('DB');

  const DanceStepConflictKind(this.label);

  final String label;
}

/// An item marked during the first 8 s of an S, which the S may not
/// include (#5.2.5), so the S may not be valid (#5.3.3).
class DanceStepConflict {
  const DanceStepConflict({
    required this.danceStepIndex,
    required this.kind,
    required this.index,
    this.value,
  });

  /// Position of the S among the routine's S.
  final int danceStepIndex;
  final DanceStepConflictKind kind;

  /// Position of the item among the items of [kind].
  final int index;

  /// The DB's value, for DB conflicts.
  final Score? value;

  /// e.g. "DB 3 (0.30)".
  String get itemLabel => [
    '${kind.label} ${index + 1}',
    if (value case final value?) '(${value.format()})',
  ].join(' ');

  @override
  bool operator ==(Object other) =>
      other is DanceStepConflict &&
      other.danceStepIndex == danceStepIndex &&
      other.kind == kind &&
      other.index == index &&
      other.value == value;

  @override
  int get hashCode => Object.hash(danceStepIndex, kind, index, value);

  @override
  String toString() => 'DanceStepConflict(S ${danceStepIndex + 1}: $itemLabel)';
}

/// Items whose music time falls within the 8 s of a marked S and may not
/// be performed there: risks (high throws), DA and DB worth 0.20 or more
/// (CoP #5.2.5). [dbValues] are the routine's DB values (same positions).
///
/// Only items with times can be checked. Pre-acrobatic elements outside DA
/// and risks are not recorded, so they are not checked. Freehand routines
/// have no risks to check (their DA are a level's own, checked the same).
List<DanceStepConflict> danceStepConflicts(
  Routine routine, {
  required List<Score> dbValues,
}) {
  final isFreehand = routine.apparatus == Apparatus.freehand;
  final conflicts = <DanceStepConflict>[];
  for (final (s, start) in routine.danceStepTimes.indexed) {
    if (start == null) continue;
    bool during(Duration? time) =>
        time != null && time >= start && time < start + danceStepDuration;

    if (!isFreehand) {
      for (final (i, time) in routine.db.riskTimes.indexed) {
        if (during(time)) {
          conflicts.add(
            DanceStepConflict(
              danceStepIndex: s,
              kind: DanceStepConflictKind.risk,
              index: i,
            ),
          );
        }
      }
    }
    for (final (i, time) in routine.da.times.indexed) {
      if (during(time)) {
        conflicts.add(
          DanceStepConflict(
            danceStepIndex: s,
            kind: DanceStepConflictKind.da,
            index: i,
          ),
        );
      }
    }
    for (final (i, time) in routine.db.elementTimes.indexed) {
      if (during(time) && dbValues[i].compareTo(danceStepDbValueLimit) >= 0) {
        conflicts.add(
          DanceStepConflict(
            danceStepIndex: s,
            kind: DanceStepConflictKind.db,
            index: i,
            value: dbValues[i],
          ),
        );
      }
    }
  }
  return conflicts;
}
