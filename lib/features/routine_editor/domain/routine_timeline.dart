import '../../../core/floor/floor_cell.dart';
import '../../da_calculator/domain/da_base.dart';
import '../../da_calculator/domain/da_element.dart';
import '../../db_calculator/domain/db_element.dart';
import '../../db_calculator/domain/risk.dart';
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

  /// The kind that can be performed together with this one, in the same
  /// moment: a DB with a DA and the other way round (CoP #9.4.1). `null`
  /// for risks and S.
  TimelineKind? get partnerKind => switch (this) {
    db => da,
    da => db,
    risk || danceStep => null,
  };
}

/// One item of a routine with a music time.
class TimelineEntry {
  const TimelineEntry({
    required this.kind,
    required this.index,
    required this.name,
    required this.time,
    this.cell,
    this.db,
    this.da,
    this.risk,
  });

  final TimelineKind kind;

  /// Position among the items of [kind] (performance order).
  final int index;

  /// What the item is, e.g. the DB's name.
  final String name;
  final Duration time;

  /// Where on the floor it starts, or `null` when not set.
  final FloorCell? cell;

  /// The DB, when this entry is one (for showing its symbol).
  final DbElement? db;

  /// The DA, when this entry is one (for showing its symbols).
  final DaElement? da;

  /// The risk, when this entry is one (for showing its symbols).
  final RiskElement? risk;

  /// Whether it was marked to be chosen later.
  bool get isPending =>
      (db?.isPending ?? false) ||
      (da?.isPending ?? false) ||
      (risk?.isPending ?? false);

  @override
  bool operator ==(Object other) =>
      other is TimelineEntry &&
      other.kind == kind &&
      other.index == index &&
      other.name == name &&
      other.time == time &&
      other.cell == cell &&
      other.db == db &&
      other.da == da &&
      other.risk == risk;

  @override
  int get hashCode => Object.hash(kind, index, name, time, cell, db, da, risk);

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

  /// The cells of the items of [kind], in list order (`null` = not set).
  List<FloorCell?> cellsOf(TimelineKind kind) => switch (kind) {
    TimelineKind.db => db.elementCells,
    TimelineKind.risk => db.riskCells,
    TimelineKind.da => da.cells,
    TimelineKind.danceStep => danceStepCells,
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
              cell: cellsOf(kind)[i],
              db: kind == TimelineKind.db ? db.elements[i] : null,
              da: kind == TimelineKind.da ? da.elements[i] : null,
              risk: kind == TimelineKind.risk ? db.risks[i] : null,
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

  /// The item of the other kind performed together with the DB or DA of
  /// [kind] at [index] (its position among its kind), or `null`.
  ///
  /// A DB and a DA are together when they have exactly the same time, as
  /// they get when the second is marked while the music is paused after
  /// the first (or when paired on the timeline).
  int? partnerOf(TimelineKind kind, int index) {
    final partnerKind = kind.partnerKind;
    final time = timesOf(kind)[index];
    if (partnerKind == null || time == null) return null;
    final partner = timesOf(partnerKind).indexOf(time);
    return partner == -1 ? null : partner;
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

  /// Moves the time of the item of [kind] at [index] by [offset], and its
  /// partner's (see [partnerOf]) with it, so they stay together. Times
  /// below zero become zero.
  Routine withTimeMoved(TimelineKind kind, int index, Duration offset) {
    final time = timesOf(kind)[index];
    if (time == null) return this;
    final partner = partnerOf(kind, index);
    final moved = withTime(kind, index, time + offset);
    // Setting a time only reorders items of its own kind, so the
    // partner's index still holds.
    return partner == null
        ? moved
        : moved.withTime(kind.partnerKind!, partner, time + offset);
  }

  /// Adds an item of [kind] that is chosen later (an S needs no choice).
  Routine withPendingAdded(TimelineKind kind) => switch (kind) {
    TimelineKind.db => withDb(
      db.withElementAdded(DbElement.pending(rulesetId: rulesetId)),
    ),
    TimelineKind.risk => withDb(
      db.withRiskAdded(
        RiskElement(rotation: RiskRotationOption.pending(rulesetId: rulesetId)),
      ),
    ),
    TimelineKind.da => withDa(
      da.withElementAdded(
        DaElement(base: DaBase.pending(rulesetId: rulesetId)),
      ),
    ),
    TimelineKind.danceStep => withDanceStepCount(danceStepCount + 1),
  };

  /// Sets where on the floor the item of [kind] at [index] starts (`null`
  /// clears it).
  Routine withCell(TimelineKind kind, int index, FloorCell? cell) =>
      switch (kind) {
        TimelineKind.db => withDb(db.withElementCellAt(index, cell)),
        TimelineKind.risk => withDb(db.withRiskCellAt(index, cell)),
        TimelineKind.da => withDa(da.withElementCellAt(index, cell)),
        TimelineKind.danceStep => withDanceStepCellAt(index, cell),
      };

  /// Clears every time and cell; the lists keep their order.
  Routine withTimesCleared() =>
      withDb(db.withTimesCleared())
          .withDa(da.withTimesCleared())
          .withDanceStepCount(0)
          .withDanceStepCount(danceStepCount);

  bool get hasTimes => TimelineKind.values.any(
    (kind) => timesOf(kind).any((time) => time != null),
  );
}
