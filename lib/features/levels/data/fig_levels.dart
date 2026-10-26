import '../domain/competition_level.dart';

// FIG level presets.
//
// Requirements are deliberately left null: the official DB/DA counts must be
// taken from the current FIG Code of Points and verified before they are
// added here. Until then the UI tells users they are not available.

const figSenior = CompetitionLevel(
  id: 'fig-senior',
  label: 'FIG Senior',
  isFig: true,
);

const figJunior = CompetitionLevel(
  id: 'fig-junior',
  label: 'FIG Junior',
  isFig: true,
);

const figLevels = <CompetitionLevel>[figSenior, figJunior];
