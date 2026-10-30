import '../../routines/presentation/routine_controller.dart';
import '../domain/routine_timeline.dart';

/// Music time editing actions, kept with the timeline so the routines
/// feature does not need to know about it.
extension RoutineTimelineEditing on RoutineController {
  /// Marks the next unmarked item of [kind] at [time]. Does nothing when
  /// every item of [kind] is marked.
  void markNext(TimelineKind kind, Duration time) => updateRoutine((routine) {
    final index = routine.nextUnmarked(kind);
    return index == null ? routine : routine.withTime(kind, index, time);
  });

  void setTime(TimelineKind kind, int index, Duration? time) =>
      updateRoutine((routine) => routine.withTime(kind, index, time));

  void clearTimes() => updateRoutine((routine) => routine.withTimesCleared());
}
