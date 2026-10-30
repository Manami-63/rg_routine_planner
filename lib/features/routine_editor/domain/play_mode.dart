import '../../dance_steps/domain/dance_step_checks.dart';
import 'routine_timeline.dart';

/// How long an item stays on screen in Play mode after its time.
const playModePopUp = Duration(seconds: 3);

/// How long the countdown shown for a dance steps combination (S) lasts:
/// its minimum duration.
const danceStepCountdown = danceStepDuration;

/// What Play mode shows at one moment of the music.
class PlayModeFrame {
  const PlayModeFrame({
    this.current,
    this.currentPartner,
    this.danceStep,
    this.danceStepRemaining,
    this.next,
    this.nextPartner,
    this.untilNext,
  });

  /// The item that started most recently and is still on screen (S stay
  /// for their whole countdown), or `null`.
  final TimelineEntry? current;

  /// The DA performed together with [current], a DB (or the other way
  /// round), or `null`. A pair shows as one pop-up, [current] being the DB.
  final TimelineEntry? currentPartner;

  /// The S whose countdown is running, or `null`. It can differ from
  /// [current] when another item starts during an S.
  final TimelineEntry? danceStep;

  /// Time left in [danceStep]'s countdown.
  final Duration? danceStepRemaining;

  /// The next item to start, or `null` after the last one.
  final TimelineEntry? next;

  /// The DA performed together with [next], a DB, or `null`.
  final TimelineEntry? nextPartner;

  /// Time until [next] starts.
  final Duration? untilNext;

  @override
  bool operator ==(Object other) =>
      other is PlayModeFrame &&
      other.current == current &&
      other.currentPartner == currentPartner &&
      other.danceStep == danceStep &&
      other.danceStepRemaining == danceStepRemaining &&
      other.next == next &&
      other.nextPartner == nextPartner &&
      other.untilNext == untilNext;

  @override
  int get hashCode => Object.hash(
    current,
    currentPartner,
    danceStep,
    danceStepRemaining,
    next,
    nextPartner,
    untilNext,
  );

  @override
  String toString() =>
      'PlayModeFrame(current: $current + $currentPartner, S: $danceStep '
      '$danceStepRemaining, next: $next + $nextPartner in $untilNext)';
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
  // A DB and a DA together have the same time, the DB first (see
  // `RoutineTimeline.timelineEntries`), so the DA ends up as `current`.
  final currentPair = _pairOf(entries, current);
  final nextPair = _pairOf(entries, next);
  return PlayModeFrame(
    current: currentPair.$1,
    currentPartner: currentPair.$2,
    danceStep: danceStep,
    danceStepRemaining: danceStep == null
        ? null
        : danceStep.time + danceStepCountdown - position,
    next: nextPair.$1,
    nextPartner: nextPair.$2,
    untilNext: next == null ? null : next.time - position,
  );
}

/// [entry] and the item performed together with it, if any, the DB first.
(TimelineEntry?, TimelineEntry?) _pairOf(
  List<TimelineEntry> entries,
  TimelineEntry? entry,
) {
  final partnerKind = entry?.kind.partnerKind;
  if (entry == null || partnerKind == null) return (entry, null);
  final partner = entries
      .where((e) => e.kind == partnerKind && e.time == entry.time)
      .firstOrNull;
  if (partner == null) return (entry, null);
  return entry.kind == TimelineKind.db ? (entry, partner) : (partner, entry);
}
