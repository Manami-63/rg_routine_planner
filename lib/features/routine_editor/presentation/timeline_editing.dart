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

  void setCell(TimelineKind kind, int index, FloorCell? cell) =>
      updateRoutine((routine) => routine.withCell(kind, index, cell));

  void setTime(TimelineKind kind, int index, Duration? time) =>
      updateRoutine((routine) => routine.withTime(kind, index, time));

  void clearTimes() => updateRoutine((routine) => routine.withTimesCleared());
}
