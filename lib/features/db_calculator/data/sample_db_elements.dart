// SAMPLE DATA ONLY.
//
// These names and values are invented placeholders for development and
// testing. They are NOT official FIG element values and must not be used
// for competition planning. Replace them with verified data under a new,
// official RulesetVersion.

import '../../../core/scoring/ruleset.dart';
import '../../../core/scoring/score.dart';
import '../domain/db_element.dart';

const _rulesetId = 'sample-v0';

const sampleRuleset = RulesetVersion(
  id: _rulesetId,
  label: 'Sample data (unofficial)',
  isOfficial: false,
);

const sampleDbElements = <DbElement>[
  DbElement(
    id: 'sample-jump-a',
    name: 'Sample Jump A',
    group: DbElementGroup.jump,
    value: Score.hundredths(10),
    rulesetId: _rulesetId,
  ),
  DbElement(
    id: 'sample-jump-b',
    name: 'Sample Jump B',
    group: DbElementGroup.jump,
    value: Score.hundredths(30),
    rulesetId: _rulesetId,
  ),
  DbElement(
    id: 'sample-jump-c',
    name: 'Sample Jump C',
    group: DbElementGroup.jump,
    value: Score.hundredths(50),
    rulesetId: _rulesetId,
  ),
  DbElement(
    id: 'sample-balance-a',
    name: 'Sample Balance A',
    group: DbElementGroup.balance,
    value: Score.hundredths(10),
    rulesetId: _rulesetId,
  ),
  DbElement(
    id: 'sample-balance-b',
    name: 'Sample Balance B',
    group: DbElementGroup.balance,
    value: Score.hundredths(20),
    rulesetId: _rulesetId,
  ),
  DbElement(
    id: 'sample-balance-c',
    name: 'Sample Balance C',
    group: DbElementGroup.balance,
    value: Score.hundredths(40),
    rulesetId: _rulesetId,
  ),
  DbElement(
    id: 'sample-rotation-a',
    name: 'Sample Rotation A',
    group: DbElementGroup.rotation,
    value: Score.hundredths(10),
    rulesetId: _rulesetId,
  ),
  DbElement(
    id: 'sample-rotation-b',
    name: 'Sample Rotation B',
    group: DbElementGroup.rotation,
    value: Score.hundredths(30),
    rulesetId: _rulesetId,
  ),
  DbElement(
    id: 'sample-rotation-c',
    name: 'Sample Rotation C',
    group: DbElementGroup.rotation,
    value: Score.hundredths(50),
    rulesetId: _rulesetId,
  ),
];
