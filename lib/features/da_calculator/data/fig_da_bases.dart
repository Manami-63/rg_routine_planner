// FIG Apparatus Difficulty (DA) bases, transcribed from the tables of the
// FIG Rhythmic Gymnastics Code of Points 2025-2028 (valid from 1 April
// 2025): Part 1 #5.8 Hoop (p.65), #5.9 Ball (p.66), #5.10 Clubs (pp.67-68),
// #5.11 Ribbon (p.69), and Junior #7.3 Rope (pp.131-132).
//
// Each base lists its criteria as a pattern in the column order of the
// tables (#5.4.3), "v" for available and "-" for "N/A":
//   outside the visual field, without hands, under the leg, rotation,
//   position on the floor, full body wave, DB
// Rope adds its specific criteria after those: double rotation, rope
// turning backward, crossed arms (blank in the table = not available).
//
// "Catch from a high throw" bases can start a DA with 2 bases (#5.1.3.2):
// the bases marked with the plain arrow, and also the thin arrow (Ball, Clubs)
// and double arrow (Clubs). Only 1 base related to the catch from a high throw is valid in one DA
// (#5.9, #5.10 notes), so those are never offered as the 2nd base.

import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/fig_ruleset.dart';
import '../../../core/scoring/score.dart';
import '../domain/da_base.dart';
import '../domain/da_criterion.dart';

/// The criteria columns of the tables, which are not in the order of
/// [DaCriterion] (#5.4.3).
const _columns = [
  DaCriterion.outsideVisualField,
  DaCriterion.withoutHands,
  DaCriterion.underLeg,
  DaCriterion.rotation,
  DaCriterion.positionOnFloor,
  DaCriterion.fullBodyWave,
  DaCriterion.db,
  DaCriterion.ropeDoubleRotation,
  DaCriterion.ropeBackward,
  DaCriterion.ropeCrossedArms,
];

DaBase _base(
  Apparatus apparatus,
  String slug,
  String name,
  int hundredths,
  String criteria, {
  bool startsCombination = false,
  bool isCatchFromHighThrow = false,
  String? note,
}) {
  assert(criteria.length == 7 || criteria.length == 10, name);
  return DaBase(
    id: 'fig-da-${apparatus.name}-$slug',
    name: name,
    apparatus: apparatus,
    value: Score.hundredths(hundredths),
    rulesetId: figRulesetId,
    criteria: {
      for (final (i, mark) in criteria.split('').indexed)
        if (mark == 'v') _columns[i],
    },
    startsCombination: startsCombination,
    isCatchFromHighThrow: isCatchFromHighThrow,
    note: note,
  );
}

const _all = 'vvvvvvv';

/// Small throws and thrusts/pushes/rebounds have the same criteria on every
/// apparatus.
const _smallThrow = 'vvvv-vv';
const _thrust = 'vvvv-v-';

final _hoop = [
  _base(
    Apparatus.hoop,
    'large-roll',
    'Large roll over min. 2 large body segments',
    30,
    'vv-vvvv',
  ),
  _base(
    Apparatus.hoop,
    'free-rotation-axis',
    'Free rotation around its axis, around or on a part of the body',
    30,
    'vv-vvvv',
    note: 'Except hands; not valid on the open palm.',
  ),
  _base(
    Apparatus.hoop,
    'rotation-body',
    'Rotation (min. 1) around a part of the body',
    20,
    'v--vvvv',
    note: 'Not the hands and not on the straight arm.',
  ),
  _base(
    Apparatus.hoop,
    'passing-through',
    'Passing through the Hoop with the whole body or part of it',
    20,
    _all,
    note: '2 large body segments.',
  ),
  _base(Apparatus.hoop, 'roll-floor', 'Roll on the floor', 20, 'vv-v-vv'),
  _base(
    Apparatus.hoop,
    'rotation-floor',
    'Rotation (min. 1) on the floor around the axis',
    20,
    'vv-v-vv',
  ),
  _base(
    Apparatus.hoop,
    'transmission',
    'Transmission without the help of the hands',
    20,
    'v--vvvv',
    note: 'Between at least 2 body parts (not the hands).',
  ),
  _base(
    Apparatus.hoop,
    'sliding',
    'Sliding over min. 2 large body segments',
    20,
    'vv-vvvv',
  ),
  _base(
    Apparatus.hoop,
    'small-throw',
    'Small throw/catch (incl. free fall)',
    20,
    _smallThrow,
  ),
  _base(
    Apparatus.hoop,
    'thrust',
    'Thrust, push, rebound',
    20,
    _thrust,
    note: 'Using different parts of the body except hands/arms.',
  ),
  _base(Apparatus.hoop, 'high-throw', 'High throw', 20, _all),
  _base(
    Apparatus.hoop,
    'high-throw-rotation',
    'High throw with rotation around the axis',
    30,
    _all,
  ),
  _base(
    Apparatus.hoop,
    'catch-high-throw',
    'Catch from the flight of a high throw',
    30,
    _all,
    startsCombination: true,
    isCatchFromHighThrow: true,
  ),
];

final _ball = [
  _base(
    Apparatus.ball,
    'large-roll',
    'Large roll over min. 2 large body segments',
    30,
    'vv-vvvv',
  ),
  _base(
    Apparatus.ball,
    'catch-one-hand',
    'Catch with 1 hand from a high throw',
    30,
    'v-vvvvv',
    startsCombination: true,
    isCatchFromHighThrow: true,
    note: 'Valid only when caught in 1 hand.',
  ),
  _base(
    Apparatus.ball,
    'high-bounce',
    '1 high bounce from the floor (knee level or higher)',
    20,
    'vv-vvvv',
  ),
  _base(
    Apparatus.ball,
    'small-bounces',
    'Series (min. 3) of small bounces from the floor',
    20,
    'vv-vvvv',
    note: 'The 2 criteria must be in the same bounce.',
  ),
  _base(
    Apparatus.ball,
    'free-rotations',
    'Free rotations on a part of the body',
    20,
    'v--vvvv',
  ),
  _base(
    Apparatus.ball,
    'transmission',
    'Transmission without the help of the hands',
    20,
    'v--vvvv',
    note: 'Between at least 2 body parts (not the hands).',
  ),
  _base(
    Apparatus.ball,
    'small-throw',
    'Small throw/catch (incl. free fall)',
    20,
    _smallThrow,
  ),
  _base(
    Apparatus.ball,
    'thrust',
    'Thrust, push, rebound',
    20,
    _thrust,
    note: 'Using different parts of the body except hands/arms.',
  ),
  _base(Apparatus.ball, 'high-throw', 'High throw', 20, _all),
  _base(
    Apparatus.ball,
    'catch-high-throw',
    'Catch from the flight of a high throw',
    30,
    _all,
    startsCombination: true,
    isCatchFromHighThrow: true,
  ),
  _base(
    Apparatus.ball,
    'rebound-floor-high-throw',
    'Rebound on the floor after a high throw and direct retrieval',
    30,
    'vv-vvvv',
    isCatchFromHighThrow: true,
    note: 'Any height, not with hands/arms.',
  ),
];

final _clubs = [
  _base(Apparatus.clubs, 'mills', 'Mills (min. 4/6 circles)', 30, 'v-vvvvv'),
  _base(
    Apparatus.clubs,
    'small-throw-unlocked',
    'Small throw of 2 unlocked Clubs/catch',
    30,
    _smallThrow,
    note: 'Min. 2 criteria on the same action (e.g. the catch).',
  ),
  _base(
    Apparatus.clubs,
    'small-circles',
    'Small circles with 2 Clubs',
    20,
    'v-vvvvv',
  ),
  _base(
    Apparatus.clubs,
    'large-roll',
    'Large roll over min. 2 large body segments',
    30,
    'vv-vvvv',
  ),
  _base(
    Apparatus.clubs,
    'free-rotations',
    'Free rotations of 1 or 2 Clubs on or around a part of the body or '
        'around the other Club',
    20,
    'vv-vvvv',
  ),
  _base(
    Apparatus.clubs,
    'transmission',
    'Transmission without the help of the hands',
    20,
    'v--vvvv',
    note: 'Between at least 2 body parts (not the hands).',
  ),
  _base(
    Apparatus.clubs,
    'sliding',
    'Sliding over min. 2 large body segments',
    20,
    'vv-vvvv',
  ),
  _base(
    Apparatus.clubs,
    'small-throw-locked',
    'Small throw of 2 locked Clubs/catch',
    20,
    _smallThrow,
  ),
  _base(
    Apparatus.clubs,
    'small-throw',
    'Small throw/catch (incl. free fall), rebound from the floor',
    20,
    _smallThrow,
  ),
  _base(
    Apparatus.clubs,
    'thrust',
    'Thrust, push, rebound',
    20,
    _thrust,
    note: 'Using different parts of the body except hands/arms.',
  ),
  _base(Apparatus.clubs, 'high-throw', 'High throw', 20, _all),
  _base(
    Apparatus.clubs,
    'high-throw-unlocked',
    'High throw of 2 unlocked Clubs',
    30,
    _all,
    note: 'Simultaneous, asymmetric or cascade.',
  ),
  _base(
    Apparatus.clubs,
    'catch-high-throw',
    'Catch from the flight of a high throw',
    30,
    _all,
    startsCombination: true,
    isCatchFromHighThrow: true,
  ),
  _base(
    Apparatus.clubs,
    'catch-one-hand',
    'Catch of 1 Club from a high throw in 1 hand, the other Club already '
        'held in the same hand',
    30,
    'v-vvvvv',
    startsCombination: true,
    isCatchFromHighThrow: true,
  ),
  _base(
    Apparatus.clubs,
    'catch-simultaneous',
    'Simultaneous catch of 2 unlocked Clubs from a high throw',
    30,
    _all,
    startsCombination: true,
    isCatchFromHighThrow: true,
  ),
];

final _ribbon = [
  _base(
    Apparatus.ribbon,
    'spirals',
    'Spirals',
    30,
    'vv-vvvv',
    note: '"Swordsman" is not valid.',
  ),
  _base(Apparatus.ribbon, 'snakes', 'Snakes', 30, 'vv-vvvv'),
  _base(Apparatus.ribbon, 'boomerang-air', 'Boomerang in the air', 40, _all),
  _base(
    Apparatus.ribbon,
    'boomerang-floor',
    'Boomerang with release and/or pull back along the floor',
    30,
    _all,
  ),
  _base(Apparatus.ribbon, 'echappe', 'Echappé and catch', 20, _all),
  _base(
    Apparatus.ribbon,
    'large-roll',
    'Large roll of the stick over min. 2 large body segments',
    30,
    'vv-vvvv',
  ),
  _base(
    Apparatus.ribbon,
    'passing-pattern',
    'Passing through or over the pattern of the Ribbon',
    20,
    'v-vvvvv',
    note: 'With the whole body or part of the body.',
  ),
  _base(
    Apparatus.ribbon,
    'stick-without-hands',
    'Stick held without hands, full circle pattern around the body',
    20,
    'vv--vvv',
    note:
        'E.g. neck, knee, elbow; during movements or Difficulties with '
        'rotation (not "slow turn").',
  ),
  _base(
    Apparatus.ribbon,
    'transmission',
    'Transmission without the help of the hands',
    20,
    'v--vvvv',
    note: 'Between at least 2 body parts (not the hands).',
  ),
  _base(
    Apparatus.ribbon,
    'small-throw',
    'Small throw/catch (incl. free fall)',
    20,
    _smallThrow,
  ),
  _base(
    Apparatus.ribbon,
    'thrust',
    'Thrust, push, rebound',
    20,
    _thrust,
    note: 'Using different parts of the body except hands/arms.',
  ),
  _base(Apparatus.ribbon, 'high-throw', 'High throw', 20, _all),
  _base(
    Apparatus.ribbon,
    'high-throw-sliding',
    'High throw from sliding on the floor',
    30,
    _all,
  ),
  _base(
    Apparatus.ribbon,
    'catch-high-throw',
    'Catch from the flight of a high throw',
    30,
    _all,
    startsCombination: true,
    isCatchFromHighThrow: true,
  ),
];

/// Rope is a Junior apparatus (#7.2).
final _rope = [
  _base(
    Apparatus.rope,
    'passing-through',
    'Passing through the Rope with the whole body or part of it',
    30,
    'vv-vvvvvvv',
    note: '2 large body segments.',
  ),
  _base(
    Apparatus.rope,
    'passing-skips',
    'Passing through the Rope with a series (min. 3) of skips/hops',
    30,
    'vv-v---vvv',
  ),
  _base(
    Apparatus.rope,
    'catch-open-rope',
    'Catch of the open Rope with 1 end in each hand from a high throw',
    30,
    'v-vvvvv',
    isCatchFromHighThrow: true,
    note: 'Without support on another part of the body.',
  ),
  _base(Apparatus.rope, 'echappe', 'Echappé and catch', 30, 'vv-vvvv'),
  _base(
    Apparatus.rope,
    'spirals',
    'Spirals: rotations of the free end, Rope held by 1 end',
    30,
    'vv-vvvv',
  ),
  _base(
    Apparatus.rope,
    'free-rotation',
    'Free rotation (min. 1) around a part of the body',
    20,
    'v--vvvv',
  ),
  _base(
    Apparatus.rope,
    'rotation-open',
    'Rotation (min. 1) of the open Rope held by its end or middle',
    20,
    _all,
  ),
  _base(Apparatus.rope, 'mills', 'Mills with the open Rope', 20, 'v-vvvvv'),
  _base(
    Apparatus.rope,
    'transmission',
    'Transmission without the help of the hands',
    20,
    'v--vvvv',
    note: 'Between at least 2 body parts (not the hands).',
  ),
  _base(
    Apparatus.rope,
    'small-throw',
    'Small throw/catch (incl. free fall)',
    20,
    _smallThrow,
  ),
  _base(
    Apparatus.rope,
    'thrust',
    'Thrust, push, rebound',
    20,
    _thrust,
    note: 'Using different parts of the body except hands/arms.',
  ),
  _base(Apparatus.rope, 'high-throw', 'High throw', 20, _all),
  _base(
    Apparatus.rope,
    'high-throw-middle',
    'High throw of the open Rope held by the middle',
    20,
    _all,
  ),
  _base(
    Apparatus.rope,
    'high-throw-end',
    'High throw of the open Rope held by the end',
    20,
    _all,
  ),
  _base(
    Apparatus.rope,
    'catch-high-throw',
    'Catch after a high throw',
    30,
    _all,
    startsCombination: true,
    isCatchFromHighThrow: true,
  ),
];

/// All FIG DA bases, by apparatus in table order.
final figDaBases = List<DaBase>.unmodifiable([
  ..._rope,
  ..._hoop,
  ..._ball,
  ..._clubs,
  ..._ribbon,
]);
