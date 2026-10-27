import '../../../core/scoring/db_element_group.dart';
import '../../../core/scoring/score.dart';
import '../domain/competition_level.dart';
import '../domain/count_limit.dart';

// FIG level presets.
//
// Counts as per the FIG Code of Points 2025-2028 (also listed for Junior
// and Senior in the Gymnastics Victoria 2026 Technical Information and Event
// Handbook, p.60; confirmed by the user to match the CoP). Only maximums are
// set: more elements may be performed, but only these many count.
//
// Body groups: at least 1 jump/leap, balance and rotation anywhere in the
// exercise (not necessarily counted); 0.30 penalty for each missing group
// (CoP #1.5, #2.3.2-2.3.3; Junior annex #3.3).
//
// FIG levels have no freehand routines, so `freehandRequirements` is null.

const _allBodyGroups = {
  DbElementGroup.jump,
  DbElementGroup.balance,
  DbElementGroup.rotation,
};

const _missingBodyGroupPenalty = Score.hundredths(30);

const figSenior = CompetitionLevel(
  id: 'fig-senior',
  label: 'FIG Senior',
  isFig: true,
  requirements: LevelRequirements(
    db: CountLimit(max: 8),
    risk: CountLimit(max: 4),
    da: CountLimit(max: 15),
    requiredBodyGroups: _allBodyGroups,
    missingBodyGroupPenalty: _missingBodyGroupPenalty,
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
    requiredBodyGroups: _allBodyGroups,
    missingBodyGroupPenalty: _missingBodyGroupPenalty,
  ),
);

const figLevels = <CompetitionLevel>[figSenior, figJunior];
