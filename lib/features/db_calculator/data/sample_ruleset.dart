// SAMPLE DATA ONLY. See sample_db_elements.dart.

import '../../../core/scoring/ruleset.dart';

/// Kept as a separate constant because a field of a const object cannot be
/// used in other const expressions.
const sampleRulesetId = 'sample-v0';

const sampleRuleset = RulesetVersion(
  id: sampleRulesetId,
  label: 'Sample data (unofficial)',
  isOfficial: false,
);
