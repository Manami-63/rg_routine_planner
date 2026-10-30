import '../../../core/floor/floor_cell.dart';
import '../../../core/scoring/db_element_group.dart';
import '../../routines/domain/routine.dart';
import 'routine_timeline.dart';

// Use of the space (CoP Artistry #9), from the marked items' floor cells.
// Advisory only: cells are a rough 3 x 3 grid, and the gymnast's travelling
// between items is only guessed.

/// How the 5 zones (#9.2) are reached by the marked items.
class FloorZoneReport {
  const FloorZoneReport({required this.visitedBy, required this.passedBy});

  /// Each zone with a marked item in it, and the first such item.
  final Map<FloorCell, TimelineEntry> visitedBy;

  /// Zones with no marked item that a straight move between two
  /// consecutive located items crosses, and the first such pair.
  final Map<FloorCell, (TimelineEntry, TimelineEntry)> passedBy;

  /// Zones neither visited nor passed through.
  List<FloorCell> get missing => [
    for (final zone in FloorCell.zones)
      if (!visitedBy.containsKey(zone) && !passedBy.containsKey(zone)) zone,
  ];
}

/// The zone report for the routine's marked items, or `null` when no item
/// has a cell yet (nothing to check).
FloorZoneReport? floorZoneReport(Routine routine) {
  final located = [
    for (final entry in routine.timelineEntries)
      if (entry.cell != null) entry,
  ];
  if (located.isEmpty) return null;

  final visitedBy = <FloorCell, TimelineEntry>{};
  for (final entry in located) {
    if (entry.cell!.isZone) visitedBy.putIfAbsent(entry.cell!, () => entry);
  }
  final passedBy = <FloorCell, (TimelineEntry, TimelineEntry)>{};
  for (var i = 1; i < located.length; i++) {
    final (from, to) = (located[i - 1], located[i]);
    for (final cell in from.cell!.crossedTo(to.cell!)) {
      if (cell.isZone && !visitedBy.containsKey(cell)) {
        passedBy.putIfAbsent(cell, () => (from, to));
      }
    }
  }
  return FloorZoneReport(visitedBy: visitedBy, passedBy: passedBy);
}

/// A DB and a DA marked this close together are taken as performed "in the
/// same moment", which counts as 1 Difficulty (#9.4.1). The app's guess:
/// the CoP gives no number.
const sameMomentWindow = Duration(seconds: 2);

/// Runs of 3 or more Difficulties in a row in the same cell (#9.4.1: the
/// same placement maintained for 3 or more Difficulties), each as the items
/// in it, in time order.
///
/// Difficulties are DB and DA. Risks and jumps/leaps involve travelling, so
/// they are not counted (and do not break a run). A DB and a DA within
/// [sameMomentWindow] count as one. An item without a cell breaks a run.
List<List<TimelineEntry>> samePlacementRuns(Routine routine) {
  bool counts(TimelineEntry entry) => switch (entry.kind) {
    TimelineKind.da => true,
    TimelineKind.db =>
      routine.db.elements[entry.index].group != DbElementGroup.jump,
    TimelineKind.risk || TimelineKind.danceStep => false,
  };

  // Group a DB and a DA performed in the same moment.
  final difficulties = <List<TimelineEntry>>[];
  for (final entry in routine.timelineEntries.where(counts)) {
    final last = difficulties.lastOrNull;
    if (last != null &&
        last.length == 1 &&
        last.single.kind != entry.kind &&
        entry.time - last.single.time <= sameMomentWindow) {
      last.add(entry);
    } else {
      difficulties.add([entry]);
    }
  }

  final runs = <List<TimelineEntry>>[];
  var run = <List<TimelineEntry>>[];
  void endRun() {
    if (run.length >= 3) runs.add([for (final d in run) ...d]);
    run = [];
  }

  for (final difficulty in difficulties) {
    final cell = difficulty.first.cell;
    if (cell == null) {
      endRun();
      continue;
    }
    if (run.isNotEmpty && run.first.first.cell != cell) endRun();
    run.add(difficulty);
  }
  endRun();
  return runs;
}
