import '../../../core/floor/floor_cell.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/routine_timeline.dart';

/// Music time editing actions, kept with the timeline so the routines
/// feature does not need to know about it.
extension RoutineTimelineEditing on RoutineController {
  /// Marks the next unmarked item of [kind] at [time], and at [cell] if
  /// given. Does nothing when every item of [kind] is marked.
  void markNext(TimelineKind kind, Duration time, [FloorCell? cell]) =>
      updateRoutine((routine) {
        final index = routine.nextUnmarked(kind);
        if (index == null) return routine;
        // The cell first: setting the time can move the item.
        return routine.withCell(kind, index, cell).withTime(kind, index, time);
      });

  /// Marks the item of [kind] at [index] at [time], and at [cell] when
  /// given (otherwise its cell stays), e.g. a DB done together with a DA.
  void markAt(TimelineKind kind, int index, Duration time, [FloorCell? cell]) =>
      updateRoutine((routine) {
        // The cell first: setting the time can move the item.
        final placed = cell == null
            ? routine
            : routine.withCell(kind, index, cell);
        return placed.withTime(kind, index, time);
      });

  void setCell(TimelineKind kind, int index, FloorCell? cell) =>
      updateRoutine((routine) => routine.withCell(kind, index, cell));

  void setTime(TimelineKind kind, int index, Duration? time) =>
      updateRoutine((routine) => routine.withTime(kind, index, time));

  /// Moves a time by [offset], with its partner's (DB and DA together).
  void moveTime(TimelineKind kind, int index, Duration offset) =>
      updateRoutine((routine) => routine.withTimeMoved(kind, index, offset));

  /// Marks the DB or DA of [kind] at [index] as performed together with
  /// the item of the other kind at [partner], by giving it that time.
  void pairWith(TimelineKind kind, int index, int partner) => updateRoutine(
    (routine) => routine.withTime(
      kind,
      index,
      routine.timesOf(kind.partnerKind!)[partner],
    ),
  );

  void clearTimes() => updateRoutine((routine) => routine.withTimesCleared());
}
