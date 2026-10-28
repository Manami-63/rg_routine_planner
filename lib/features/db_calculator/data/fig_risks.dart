// FIG risk (R) building blocks, transcribed from the FIG Rhythmic
// Gymnastics Code of Points 2025-2028 (valid from 1 April 2025), Part 1,
// B.4 "Dynamic elements with rotation (R)" and Annex E.6 (Junior Rope).
//

import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/score.dart';
import '../domain/risk.dart';
import '../../../core/scoring/fig_ruleset.dart';

/// Highest number of rotations offered in the builder.
const _maxRotations = 10;

/// #4.2.1: 2 base rotations are worth 0.20; #4.8.1: + 0.10 for each
/// additional complete 360° rotation.
final figRiskRotationOptions = <RiskRotationOption>[
  for (var rotations = 2; rotations <= _maxRotations; rotations++)
    RiskRotationOption(
      id: 'fig-r-rotations-$rotations',
      label: '$rotations rotations',
      rotations: rotations,
      value: Score.hundredths(20 + (rotations - 2) * 10),
      rulesetId: figRulesetId,
    ),
];

const figRiskCriteria = <RiskCriterion>[
  // #4.9: general criteria for all apparatus, during the throw.
  RiskCriterion(
    id: 'fig-r-throw-outside-visual-field',
    name: 'Outside the visual field',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.throwing,
  ),
  RiskCriterion(
    id: 'fig-r-throw-without-hands',
    name: 'Without the help of the hands',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.throwing,
  ),
  // #4.10.1: specific criteria of the throw.
  RiskCriterion(
    id: 'fig-r-throw-after-rolling-on-floor',
    name: 'Throw after rolling on the floor',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.throwing,
    apparatus: {Apparatus.hoop},
    note: 'Only valid together with "Without the help of the hands"',
  ),
  RiskCriterion(
    id: 'fig-r-throw-two-unlocked-clubs',
    name: 'Throw of 2 unlocked Clubs',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.throwing,
    apparatus: {Apparatus.clubs},
    note: 'Simultaneous, asymmetric or cascade',
  ),
  // Annex E.6.4: Junior Rope, specific criteria of the throw.
  RiskCriterion(
    id: 'fig-r-throw-passing-through-rope',
    name: 'Passing through the Rope',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.throwing,
    apparatus: {Apparatus.rope},
    note: 'Minimum 2 large body segments',
  ),
  RiskCriterion(
    id: 'fig-r-throw-open-rope-by-end',
    name: 'High throw of open Rope held by the end',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.throwing,
    apparatus: {Apparatus.rope},
  ),
  RiskCriterion(
    id: 'fig-r-throw-open-rope-by-middle',
    name: 'High throw of open Rope held by the middle',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.throwing,
    apparatus: {Apparatus.rope},
  ),
  // #4.8.1: criteria during the rotations.
  RiskCriterion(
    id: 'fig-r-change-of-axis-or-level',
    name: 'Change of rotation axis or level',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.rotations,
    note: 'Only 1 per risk: change of axis or change of level, not both',
  ),
  RiskCriterion(
    id: 'fig-r-series',
    name: 'Series',
    value: Score.hundredths(20),
    rulesetId: figRulesetId,
    phase: RiskPhase.rotations,
    note:
        '3 or more identical pre-acrobatic elements under the flight, or 3 '
        'turning leaps with throw and catch',
  ),
  // #4.9: general criteria for all apparatus, during the catch.
  RiskCriterion(
    id: 'fig-r-catch-outside-visual-field',
    name: 'Outside the visual field',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.catching,
  ),
  RiskCriterion(
    id: 'fig-r-catch-without-hands',
    name: 'Without the help of the hands',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.catching,
  ),
  // #4.10.1: specific criteria of the catch.
  RiskCriterion(
    id: 'fig-r-catch-passing-through-hoop',
    name: 'Passing through the Hoop',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.catching,
    apparatus: {Apparatus.hoop},
    note: 'Minimum 2 large body segments',
  ),
  RiskCriterion(
    id: 'fig-r-catch-direct-rebound',
    name: 'Direct rebound on the body',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.catching,
    apparatus: {Apparatus.hoop, Apparatus.ball},
    note: 'Without stops, without arm(s) or hand(s)',
  ),
  // The Code gives no apparatus for this criterion, so it is offered for
  // every apparatus.
  RiskCriterion(
    id: 'fig-r-catch-rolling-over-body',
    name: 'Direct catch with rolling over the body',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.catching,
    note: 'Minimum 2 large body segments; not on the arm/hand',
  ),
  RiskCriterion(
    id: 'fig-r-catch-two-unlocked-clubs',
    name: 'Simultaneous catch of 2 unlocked Clubs',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.catching,
    apparatus: {Apparatus.clubs},
  ),
  RiskCriterion(
    id: 'fig-r-catch-ball-one-hand',
    name: 'Catch with 1 hand',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.catching,
    apparatus: {Apparatus.ball},
    note: 'Without support of the body or the other hand',
  ),
  RiskCriterion(
    id: 'fig-r-catch-hoop-rotation-around-body',
    name: 'Direct catch with rotation around a body part',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.catching,
    apparatus: {Apparatus.hoop},
    note: 'Without hands; not on the straight arm',
  ),
  // Annex E.6.4: Junior Rope, specific criterion of the catch.
  RiskCriterion(
    id: 'fig-r-catch-rope-end-in-each-hand',
    name: 'Catch with 1 end in each hand',
    value: Score.hundredths(10),
    rulesetId: figRulesetId,
    phase: RiskPhase.catching,
    apparatus: {Apparatus.rope},
  ),
];
