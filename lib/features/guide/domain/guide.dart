// The step-by-step guide for a new routine: which steps a path has and
// which one is next. Most steps finish when the routine shows they were
// done (music added, a DB added); the others when the user taps on.

/// How the user chose to start the routine.
enum GuidePath {
  /// Build the routine while the music plays (Music tab).
  music,

  /// Choose the DB and DA first, then add music to mark the times.
  difficulties,
}

/// One step of the guide.
enum GuideStep {
  addMusic,
  markFirst,
  timeline,
  floorMat,
  playMode,
  firstDb,
  total,
  firstDa,
  firstRisk,
  markTimes;

  /// Steps that only finish when the user taps on (nothing in the routine
  /// shows they are done).
  bool get needsTap => switch (this) {
    timeline || total || playMode || markTimes => true,
    _ => false,
  };
}

/// What the routine already has, for deciding which steps are done.
class GuideFacts {
  const GuideFacts({
    this.hasMusic = false,
    this.markedCount = 0,
    this.hasFloorCell = false,
    this.dbCount = 0,
    this.daCount = 0,
    this.riskCount = 0,
    this.freehand = false,
  });

  final bool hasMusic;

  /// DB, R, DA and S with a music time.
  final int markedCount;

  /// Whether any marked item has a place on the floor.
  final bool hasFloorCell;
  final int dbCount;
  final int daCount;
  final int riskCount;

  /// Freehand routines have no risks and no FIG DA.
  final bool freehand;
}

/// The steps of [path], in order. Freehand skips the DA and risk steps.
List<GuideStep> guideSteps(GuidePath path, {required bool freehand}) =>
    switch (path) {
      GuidePath.music => const [
        GuideStep.addMusic,
        GuideStep.markFirst,
        GuideStep.timeline,
        GuideStep.floorMat,
        GuideStep.playMode,
      ],
      GuidePath.difficulties => [
        GuideStep.firstDb,
        GuideStep.total,
        if (!freehand) ...[GuideStep.firstDa, GuideStep.firstRisk],
        GuideStep.addMusic,
        GuideStep.markTimes,
      ],
    };

/// A routine's guide: its path and the steps the user tapped on.
class GuideProgress {
  const GuideProgress({
    required this.routineId,
    required this.path,
    this.tapped = const {},
  });

  final String routineId;
  final GuidePath path;
  final Set<GuideStep> tapped;

  GuideProgress withTapped(GuideStep step) => GuideProgress(
    routineId: routineId,
    path: path,
    tapped: {...tapped, step},
  );

  bool isDone(GuideStep step, GuideFacts facts) =>
      tapped.contains(step) ||
      switch (step) {
        GuideStep.addMusic => facts.hasMusic,
        GuideStep.markFirst => facts.markedCount > 0,
        GuideStep.floorMat => facts.hasFloorCell,
        GuideStep.firstDb => facts.dbCount > 0,
        GuideStep.firstDa => facts.daCount > 0,
        GuideStep.firstRisk => facts.riskCount > 0,
        GuideStep.timeline ||
        GuideStep.total ||
        GuideStep.playMode ||
        GuideStep.markTimes => false,
      };

  /// The first step not done yet, or null when the guide is finished.
  GuideStep? currentStep(GuideFacts facts) {
    for (final step in guideSteps(path, freehand: facts.freehand)) {
      if (!isDone(step, facts)) return step;
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'routineId': routineId,
    'path': path.name,
    'tapped': [for (final step in tapped) step.name],
  };

  /// Null when [json] is not a guide (e.g. written by another version).
  static GuideProgress? fromJson(Object? json) {
    if (json is! Map) return null;
    final routineId = json['routineId'];
    final path = GuidePath.values.asNameMap()[json['path']];
    if (routineId is! String || path == null) return null;
    final steps = GuideStep.values.asNameMap();
    final tapped = json['tapped'];
    return GuideProgress(
      routineId: routineId,
      path: path,
      tapped: {
        if (tapped is List)
          for (final name in tapped) ?steps[name],
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GuideProgress &&
      other.routineId == routineId &&
      other.path == path &&
      other.tapped.length == tapped.length &&
      other.tapped.containsAll(tapped);

  @override
  int get hashCode => Object.hash(routineId, path, tapped.length);
}

/// Whether new routines offer the guide, and the routine being guided.
/// Only one routine is guided at a time: starting a new one replaces it.
class GuideSettings {
  const GuideSettings({this.enabled = true, this.active});

  /// The guide is off: nothing is offered.
  static const off = GuideSettings(enabled: false);

  final bool enabled;
  final GuideProgress? active;

  /// The guide for [routineId], if that routine is being guided.
  GuideProgress? forRoutine(String routineId) =>
      active?.routineId == routineId ? active : null;

  @override
  bool operator ==(Object other) =>
      other is GuideSettings &&
      other.enabled == enabled &&
      other.active == active;

  @override
  int get hashCode => Object.hash(enabled, active);
}
