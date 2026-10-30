import 'routine_timeline.dart';

/// How long an item stays on screen in Play mode after its time.
const playModePopUp = Duration(seconds: 3);

/// How long the countdown shown for a dance steps combination (S) lasts.
const danceStepCountdown = Duration(seconds: 8);

/// What Play mode shows at one moment of the music.
class PlayModeFrame {
  const PlayModeFrame({
    this.current,
    this.danceStep,
    this.danceStepRemaining,
    this.next,
    this.untilNext,
  });

  /// The item that started most recently and is still on screen (S stay
  /// for their whole countdown), or `null`.
  final TimelineEntry? current;

  /// The S whose countdown is running, or `null`. It can differ from
  /// [current] when another item starts during an S.
  final TimelineEntry? danceStep;

  /// Time left in [danceStep]'s countdown.
  final Duration? danceStepRemaining;

  /// The next item to start, or `null` after the last one.
  final TimelineEntry? next;

  /// Time until [next] starts.
  final Duration? untilNext;

  @override
  bool operator ==(Object other) =>
      other is PlayModeFrame &&
      other.current == current &&
      other.danceStep == danceStep &&
      other.danceStepRemaining == danceStepRemaining &&
      other.next == next &&
      other.untilNext == untilNext;

  @override
  int get hashCode =>
      Object.hash(current, danceStep, danceStepRemaining, next, untilNext);

  @override
  String toString() =>
      'PlayModeFrame(current: $current, S: $danceStep '
      '$danceStepRemaining, next: $next in $untilNext)';
}

/// The Play mode frame at [position], from [entries] sorted by time (see
/// `RoutineTimeline.timelineEntries`).
PlayModeFrame playModeFrameAt(List<TimelineEntry> entries, Duration position) {
  TimelineEntry? current;
  TimelineEntry? danceStep;
  TimelineEntry? next;
  for (final entry in entries) {
    if (entry.time > position) {
      next = entry;
      break;
    }
    final isDanceStep = entry.kind == TimelineKind.danceStep;
    final shownFor = isDanceStep ? danceStepCountdown : playModePopUp;
    if (position < entry.time + shownFor) current = entry;
    if (isDanceStep && position < entry.time + danceStepCountdown) {
      danceStep = entry;
    }
  }
  return PlayModeFrame(
    current: current,
    danceStep: danceStep,
    danceStepRemaining: danceStep == null
        ? null
        : danceStep.time + danceStepCountdown - position,
    next: next,
    untilNext: next == null ? null : next.time - position,
  );
}
