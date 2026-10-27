// SAMPLE DATA ONLY.
//
// These names and values are invented placeholders for development and
// testing. They are NOT official FIG element values and must not be used
// for competition planning. Replace them with verified data under a new,
// official RulesetVersion.
//
// The option flags (flat foot, slow turn, extra rotation value) follow the
// FIG CoP rules for each kind of element, so the options can be tried out.

import '../../../core/scoring/score.dart';
import '../domain/db_element.dart';
import 'sample_ruleset.dart';

const sampleDbElements = <DbElement>[
  DbElement(
    id: 'sample-jump-a',
    name: 'Sample Jump A',
    group: DbElementGroup.jump,
    value: Score.hundredths(10),
    rulesetId: sampleRulesetId,
  ),
  DbElement(
    id: 'sample-jump-b',
    name: 'Sample Jump B',
    group: DbElementGroup.jump,
    value: Score.hundredths(30),
    rulesetId: sampleRulesetId,
  ),
  DbElement(
    id: 'sample-jump-c',
    name: 'Sample Jump C',
    group: DbElementGroup.jump,
    value: Score.hundredths(50),
    rulesetId: sampleRulesetId,
  ),
  DbElement(
    id: 'sample-balance-a',
    name: 'Sample Balance A',
    group: DbElementGroup.balance,
    value: Score.hundredths(10),
    rulesetId: sampleRulesetId,
    canBeOnFlatFoot: true,
    canSlowTurn: true,
  ),
  DbElement(
    id: 'sample-balance-b',
    name: 'Sample Balance B',
    group: DbElementGroup.balance,
    value: Score.hundredths(20),
    rulesetId: sampleRulesetId,
    canBeOnFlatFoot: true,
    canSlowTurn: true,
  ),
  DbElement(
    id: 'sample-balance-c',
    name: 'Sample Balance C',
    group: DbElementGroup.balance,
    value: Score.hundredths(40),
    rulesetId: sampleRulesetId,
    canBeOnFlatFoot: true,
    canSlowTurn: true,
  ),
  DbElement(
    id: 'sample-rotation-a',
    name: 'Sample Rotation A',
    group: DbElementGroup.rotation,
    value: Score.hundredths(10),
    rulesetId: sampleRulesetId,
    extraRotationValue: Score.hundredths(10),
  ),
  DbElement(
    id: 'sample-rotation-b',
    name: 'Sample Rotation B',
    group: DbElementGroup.rotation,
    value: Score.hundredths(30),
    rulesetId: sampleRulesetId,
    extraRotationValue: Score.hundredths(20),
  ),
  DbElement(
    id: 'sample-rotation-c',
    name: 'Sample Rotation C',
    group: DbElementGroup.rotation,
    value: Score.hundredths(50),
    rulesetId: sampleRulesetId,
    extraRotationValue: Score.hundredths(20),
  ),
];
