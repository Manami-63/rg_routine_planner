import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/play_mode.dart';
import 'package:rg_routine_planner/features/routine_editor/domain/routine_timeline.dart';

void main() {
  Duration s(num seconds) => Duration(milliseconds: (seconds * 1000).round());

  TimelineEntry entry(TimelineKind kind, int index, num seconds) =>
      TimelineEntry(kind: kind, index: index, name: 'x', time: s(seconds));

  final db = entry(TimelineKind.db, 0, 5);
  final danceStep = entry(TimelineKind.danceStep, 0, 10);
  final da = entry(TimelineKind.da, 0, 13);
  final risk = entry(TimelineKind.risk, 0, 30);
  final entries = [db, danceStep, da, risk];

  test('before the first item: nothing current, the first is next', () {
    expect(
      playModeFrameAt(entries, s(1)),
      PlayModeFrame(next: db, untilNext: s(4)),
    );
  });

  test('an item stays current for the pop-up time', () {
    expect(playModeFrameAt(entries, s(5)).current, db);
    expect(playModeFrameAt(entries, s(7.9)).current, db);
    expect(playModeFrameAt(entries, s(8)).current, isNull);
    expect(playModeFrameAt(entries, s(8)).next, danceStep);
  });

  test('an S is current for its whole countdown', () {
    final frame = playModeFrameAt(entries, s(11.5));

    expect(frame.current, danceStep);
    expect(frame.danceStep, danceStep);
    expect(frame.danceStepRemaining, s(6.5));
    expect(frame.next, da);
    expect(frame.untilNext, s(1.5));
  });

  test('an item starting during an S becomes current; the S keeps going', () {
    final frame = playModeFrameAt(entries, s(14));

    expect(frame.current, da);
    expect(frame.danceStep, danceStep);
    expect(frame.danceStepRemaining, s(4));
  });

  test('the S countdown ends after 8 s', () {
    final frame = playModeFrameAt(entries, s(18));

    expect(frame.danceStep, isNull);
    expect(frame.current, isNull);
    expect(frame.next, risk);
  });

  test('after the last item nothing is next', () {
    expect(playModeFrameAt(entries, s(40)), const PlayModeFrame());
    expect(playModeFrameAt(const [], s(1)), const PlayModeFrame());
  });
}
