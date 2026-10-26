// SAMPLE DATA ONLY.
//
// Placeholder risk building blocks for development and testing. The labels
// and values are NOT official FIG values and must not be used for
// competition planning.

import '../../../core/scoring/score.dart';
import '../domain/risk.dart';
import 'sample_ruleset.dart';

const sampleRiskRotationOptions = <RiskRotationOption>[
  RiskRotationOption(
    id: 'sample-rotations-2',
    label: '2 rotations (sample)',
    rotations: 2,
    value: Score.hundredths(20),
    rulesetId: sampleRulesetId,
  ),
  RiskRotationOption(
    id: 'sample-rotations-3',
    label: '3 rotations (sample)',
    rotations: 3,
    value: Score.hundredths(30),
    rulesetId: sampleRulesetId,
  ),
  RiskRotationOption(
    id: 'sample-rotations-4',
    label: '4 rotations (sample)',
    rotations: 4,
    value: Score.hundredths(40),
    rulesetId: sampleRulesetId,
  ),
];

const sampleRiskCriteria = <RiskCriterion>[
  RiskCriterion(
    id: 'sample-criterion-a',
    name: 'Sample Criterion A',
    value: Score.hundredths(10),
    rulesetId: sampleRulesetId,
  ),
  RiskCriterion(
    id: 'sample-criterion-b',
    name: 'Sample Criterion B',
    value: Score.hundredths(10),
    rulesetId: sampleRulesetId,
  ),
  RiskCriterion(
    id: 'sample-criterion-c',
    name: 'Sample Criterion C',
    value: Score.hundredths(20),
    rulesetId: sampleRulesetId,
  ),
];
