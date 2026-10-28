import 'ruleset.dart';

/// Kept as a separate constant because a field of a const object cannot be
/// used in other const expressions.
const figRulesetId = 'fig-2025';

/// The DB and risk catalogues transcribed from the FIG Code of Points
/// 2025-2028. Official: the user has checked the transcription against the
/// Code.
const figRuleset = RulesetVersion(
  id: figRulesetId,
  label: 'FIG Code of Points 2025-2028',
  isOfficial: true,
);
