import '../domain/competition_level.dart';
import '../domain/count_limit.dart';

// FIG level presets.
//
// Counts as per the FIG Code of Points 2025-2028 (also listed for Junior
// and Senior in the Gymnastics Victoria 2026 Technical Information and Event
// Handbook, p.60; confirmed by the user to match the CoP). Only maximums are
// set: more elements may be performed, but only these many count.
//
// FIG levels have no freehand routines, so `freehandRequirements` is null.

const figSenior = CompetitionLevel(
  id: 'fig-senior',
  label: 'FIG Senior',
  isFig: true,
  requirements: LevelRequirements(
    db: CountLimit(max: 8),
    risk: CountLimit(max: 4),
    da: CountLimit(max: 15),
  ),
);

const figJunior = CompetitionLevel(
  id: 'fig-junior',
  label: 'FIG Junior',
  isFig: true,
  requirements: LevelRequirements(
    db: CountLimit(max: 6),
    risk: CountLimit(max: 3),
    da: CountLimit(max: 12),
  ),
);

const figLevels = <CompetitionLevel>[figSenior, figJunior];
