import '../../routines/domain/routine.dart';

/// The kinds of item that can be marked on the music.
enum TimelineKind {
  db('DB'),
  risk('R'),
  da('DA'),
  danceStep('S');

  const TimelineKind(this.label);

  /// Short name, e.g. "R".
  final String label;
}

/// One item of a routine with a music time.
class TimelineEntry {
  const TimelineEntry({
    required this.kind,
    required this.index,
    required this.name,
    required this.time,
  });

  final TimelineKind kind;

  /// Position among the items of [kind] (performance order).
  final int index;

  /// What the item is, e.g. the DB's name.
  final String name;
  final Duration time;

  @override
  bool operator ==(Object other) =>
      other is TimelineEntry &&
      other.kind == kind &&
      other.index == index &&
      other.name == name &&
      other.time == time;

  @override
  int get hashCode => Object.hash(kind, index, name, time);

  @override
  String toString() => 'TimelineEntry(${kind.label} $index, $time)';
}

/// Music times of a routine's DB, risks, DA and S.
///
/// Setting a time puts the timed items of that kind in time order, so the
/// lists follow the music (and the first N risks and DA count correctly).
extension RoutineTimeline on Routine {
  /// The times of the items of [kind], in list order (`null` = not marked).
  List<Duration?> timesOf(TimelineKind kind) => switch (kind) {
    TimelineKind.db => db.elementTimes,
    TimelineKind.risk => db.riskTimes,
    TimelineKind.da => da.times,
    TimelineKind.danceStep => danceStepTimes,
  };

  /// The first item of [kind] without a time, or `null` when all are
  /// marked (or there are none).
  int? nextUnmarked(TimelineKind kind) {
    final index = timesOf(kind).indexOf(null);
    return index == -1 ? null : index;
  }

  /// Every marked item, by time (ties in [TimelineKind] order).
  List<TimelineEntry> get timelineEntries {
    final entries = [
      for (final kind in TimelineKind.values)
        for (final (i, time) in timesOf(kind).indexed)
          if (time != null)
            TimelineEntry(
              kind: kind,
              index: i,
              name: _nameOf(kind, i),
              time: time,
            ),
    ];
    // `sort` is not stable, so ties are broken explicitly.
    entries.sort((a, b) {
      final byTime = a.time.compareTo(b.time);
      if (byTime != 0) return byTime;
      final byKind = a.kind.index.compareTo(b.kind.index);
      return byKind != 0 ? byKind : a.index.compareTo(b.index);
    });
    return entries;
  }

  String _nameOf(TimelineKind kind, int index) => switch (kind) {
    TimelineKind.db => db.elements[index].name,
    TimelineKind.risk => db.risks[index].description,
    TimelineKind.da => da.elements[index].name,
    TimelineKind.danceStep => 'Dance steps combination',
  };

  /// Sets the time of the item of [kind] at [index] (`null` clears it).
  /// Times below zero become zero.
  Routine withTime(TimelineKind kind, int index, Duration? time) {
    final clamped = time == null || time >= Duration.zero
        ? time
        : Duration.zero;
    return switch (kind) {
      TimelineKind.db => withDb(db.withElementTimeAt(index, clamped)),
      TimelineKind.risk => withDb(db.withRiskTimeAt(index, clamped)),
      TimelineKind.da => withDa(da.withElementTimeAt(index, clamped)),
      TimelineKind.danceStep => withDanceStepTimeAt(index, clamped),
    };
  }

  /// Clears every time; the lists keep their order.
  Routine withTimesCleared() =>
      withDb(db.withTimesCleared())
          .withDa(da.withTimesCleared())
          .withDanceStepCount(0)
          .withDanceStepCount(danceStepCount);

  bool get hasTimes => TimelineKind.values.any(
    (kind) => timesOf(kind).any((time) => time != null),
  );
}
