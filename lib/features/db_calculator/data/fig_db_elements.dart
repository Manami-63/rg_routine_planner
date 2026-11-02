// FIG Difficulty of Body (DB) elements, transcribed from the tables of the
// FIG Rhythmic Gymnastics Code of Points 2025-2028 (valid from 1 April
// 2025), Part 1, B.9 (jumps/leaps, pp.76-81), B.11 (balances, pp.88-90)
// and B.13 (rotations, pp.98-101).
//
// The Code has no element names: each name is the element's code plus a
// short description from its table row and drawing. Values are the table
// column (the last digit of each code repeats it, which a test checks).
//
// Option flags follow the rules for each kind of element:
// - Balances executed on the foot (rows 1-12) may be on flat foot (#10.3)
//   and with slow turn (#10.9; not "Cossack", not dynamic balances).
// - Additional rotations (#12.2.5-12.2.8): + 0.10 each for pivots of base
//   0.10, Fouetté, Sakura (3.1105) and rotations on other body parts;
//   + 0.20 each for pivots of 0.20 or more; none for 3.2101/3.2202
//   ("no extra value") and Illusion (performed in series instead).
// - Series (#2.4.3, #8.10, #12.8): jumps/leaps with take-off and landing on
//   1 leg, and pivots/illusions. Offered for every jump except those
//   defined with take-off from 2 feet only (1.101, 1.301, 1.303), and for
//   rotations on 1 leg except Fouetté (a Fouetté series counts as 1 DB,
//   #12.11). The user decides whether a series is possible.

import '../../../core/scoring/score.dart';
import '../domain/db_element.dart';
import '../../../core/scoring/fig_ruleset.dart';
import 'fig_db_symbols.dart';

DbElement _element(
  String code,
  DbElementGroup group,
  int hundredths,
  String description, {
  bool balanceOnFoot = false,
  bool slowTurn = false,
  int? extraRotation,
  bool series = false,
}) => DbElement(
  id: 'fig-$code',
  name: '$code · $description',
  group: group,
  value: Score.hundredths(hundredths),
  rulesetId: figRulesetId,
  canBeOnFlatFoot: balanceOnFoot,
  canSlowTurn: slowTurn,
  extraRotationValue: extraRotation == null
      ? null
      : Score.hundredths(extraRotation),
  canBeInSeries: series,
  family: _familyOf(code),
  baseRotationDegrees: _halfTurnBase.contains(code) ? 180 : 360,
  symbolPath: figDbSymbolPaths[code],
);

/// Rotations with a minimum basic rotation of 180° (#12.1.2).
const _halfTurnBase = {'3.505', '3.804', '3.805', '3.1405', '3.2003'};

/// "23 · Switch split leap, straight legs" for code 1.2305: the table row
/// is the code without its group prefix and its last two digits.
String _familyOf(String code) {
  final digits = code.substring(2);
  final row = int.parse(digits.substring(0, digits.length - 2));
  final title = switch (code[0]) {
    '1' => _jumpRows[row],
    '2' => _balanceRows[row],
    _ => _rotationRows[row],
  };
  return '$row · $title';
}

// Table row titles, shortened from the "Types of ..." column.
const _jumpRows = [
  '', // Rows start at 1.
  'Tuck jump, 360° turn',
  'Cat leap',
  'Vertical jump, straight legs, with turn',
  'Vertical jump, passé, with turn',
  'Vertical jump, free leg forward, with turn',
  'Vertical jump, free leg side, with turn',
  'Vertical jump, free leg backward, with turn',
  'Vertical jump, attitude, with turn',
  'Cabriole forward',
  'Cabriole to the side',
  'Cabriole backward',
  'Scissors leap forward',
  'Scissors leap backward',
  'Pike jump',
  'Cossack jump, leg forward horizontal',
  'Cossack jump, leg forward high, with help',
  'Cossack jump, leg forward high, without help',
  'Cossack jump, leg side high, with help (Zhukova)',
  'Cossack jump, leg side high, without help',
  'Ring jump (Kabaeva)',
  'Split leap (also ring/back bend, Zaripova)',
  '2 or 3 consecutive split leaps',
  'Switch split leap, straight legs',
  'Switch split leap, bent leg',
  'Side split leap',
  'Switch side split leap',
  'Stag leap',
  'Stag leap with turn (Bessonova)',
  'Switch stag leap',
  'Fouetté leap',
  'Fouetté with cabriole, stag or ring',
  'Entrelacé',
  'Turning stag leap',
  'Turning stag leap with switch',
  'Turning split leap (Agiurgiuculese)',
  'Turning split leap with switch',
  'Butterfly jump',
];

const _balanceRows = [
  '',
  'Passé forward or side',
  'Free leg forward',
  'Front split',
  'Front split, trunk backward at the horizontal',
  'Front split, trunk backward below horizontal',
  'Free leg to the side',
  'Side split',
  'Side split, trunk to the side',
  'Arabesque',
  'Back split with help, foot above head',
  'Back split, trunk forward, ring without help',
  'Attitude, ring',
  'Cossack, free leg horizontal',
  'Cossack, foot higher than head',
  'Lying, Kabaeva on the chest',
  'Passing from lying to the chest',
  'Dynamic balance, kneeling to standing',
  'Fouetté balance',
  'Utyascheva',
];

const _rotationRows = [
  '',
  'Passé',
  'Spiral turn (Tonneau)',
  'Free leg forward',
  'Front split',
  'Elkatib',
  'Free leg to the side',
  'Side split',
  'Side split, trunk to the side (Raffaeli)',
  'Arabesque',
  'Back split with help, foot above head',
  'Back split, trunk forward (Sakura)',
  'Attitude, ring without help',
  'Ring with help, leg on the shoulder',
  'Front split, trunk backward (Kabaeva, Kramarenko)',
  'Cossack',
  'Fouetté',
  'Illusion backward',
  'Ralenkova: on the back',
  'On the stomach, legs to ring',
  'Ashram, Kanaeva',
  'Rotation in split, trunk forward',
  'Rotation in split, trunk backward',
];

/// Take-off from 2 feet only: cannot be performed in series.
const _twoFootJumps = {'1.101', '1.301', '1.303'};

DbElement _jump(String code, int hundredths, String description) => _element(
  code,
  DbElementGroup.jump,
  hundredths,
  description,
  series: !_twoFootJumps.contains(code),
);

/// A balance executed on the foot: flat foot and slow turn possible.
DbElement _footBalance(String code, int hundredths, String description) =>
    _element(
      code,
      DbElementGroup.balance,
      hundredths,
      description,
      balanceOnFoot: true,
      slowTurn: true,
    );

DbElement _otherBalance(String code, int hundredths, String description) =>
    _element(code, DbElementGroup.balance, hundredths, description);

DbElement _rotation(
  String code,
  int hundredths,
  String description, {
  required int? extra,
  bool series = true,
}) => _element(
  code,
  DbElementGroup.rotation,
  hundredths,
  description,
  extraRotation: extra,
  series: series,
);

final figDbElements = <DbElement>[
  // Jumps/leaps, p.76.
  _jump('1.101', 10, 'Tuck jump, 360° turn'),
  _jump('1.201', 10, 'Cat leap, 360° turn'),
  _jump('1.301', 10, 'Vertical jump, straight legs, 360° turn'),
  _jump('1.303', 30, 'Vertical jump, straight legs, 720° turn'),
  _jump('1.401', 10, 'Vertical jump, passé, 360° turn'),
  _jump('1.403', 30, 'Vertical jump, passé, 720° turn'),
  _jump('1.502', 20, 'Vertical jump, free leg forward, 180° turn'),
  _jump('1.503', 30, 'Vertical jump, free leg forward, 360° turn'),
  _jump('1.602', 20, 'Vertical jump, free leg side, 180° turn'),
  _jump('1.603', 30, 'Vertical jump, free leg side, 360° turn'),
  _jump('1.702', 20, 'Vertical jump, free leg backward, 180° turn'),
  _jump('1.704', 40, 'Vertical jump, free leg backward, 360° turn'),
  // p.77.
  _jump('1.802', 20, 'Vertical jump, attitude, 180° turn'),
  _jump('1.804', 40, 'Vertical jump, attitude, 360° turn'),
  _jump('1.901', 10, 'Cabriole forward'),
  _jump('1.1001', 10, 'Cabriole to the side'),
  _jump('1.1101', 10, 'Cabriole backward'),
  _jump('1.1201', 10, 'Scissors leap forward'),
  _jump('1.1301', 10, 'Scissors leap backward, at 45°'),
  _jump('1.1302', 20, 'Scissors leap backward, with ring'),
  _jump('1.1403', 30, 'Pike jump'),
  _jump('1.1501', 10, 'Cossack jump, leg forward horizontal'),
  _jump('1.1503', 30, 'Cossack jump, leg forward horizontal, 180° turn'),
  // p.78.
  _jump('1.1602', 20, 'Cossack jump, leg forward high, with help'),
  _jump('1.1604', 40, 'Cossack jump, leg forward high, with help, 180° turn'),
  _jump('1.1703', 30, 'Cossack jump, leg forward high, without help'),
  _jump('1.1705', 50, 'Cossack jump, leg forward high, no help, 180° turn'),
  _jump('1.1802', 20, 'Cossack jump, leg side high, with help'),
  _jump('1.1804', 40, 'Cossack jump, leg side high, with help, 180° turn'),
  _jump('1.1805', 50, 'Zhukova: Cossack jump, leg side, 360° turn'),
  _jump('1.1903', 30, 'Cossack jump, leg side high, without help'),
  _jump('1.1905', 50, 'Cossack jump, leg side high, no help, 180° turn'),
  _jump('1.2002', 20, 'Ring jump (Kabaeva)'),
  _jump('1.2003', 30, 'Ring jump (Kabaeva), 2 legs'),
  _jump('1.2103', 30, 'Split leap'),
  _jump('1.2104', 40, 'Split leap, take-off from 2 feet'),
  _jump('1.2105', 50, 'Split leap with ring/back bend'),
  // p.79.
  _jump('1.2205', 50, '2 consecutive split leaps'),
  _jump('1.2207', 70, '3 consecutive split leaps'),
  _jump('1.2305', 50, 'Switch split leap, straight legs'),
  _jump('1.2307', 70, 'Switch split leap, straight legs, ring/back bend'),
  _jump('1.2404', 40, 'Switch split leap, bent leg'),
  _jump('1.2406', 60, 'Switch split leap, bent leg, ring/back bend'),
  _jump('1.2503', 30, 'Side split leap'),
  _jump('1.2505', 50, 'Side split leap, 180° turn'),
  _jump('1.2604', 40, 'Switch side split leap, bent leg'),
  _jump('1.2605', 50, 'Switch side split leap, straight legs'),
  // p.80.
  _jump('1.2702', 20, 'Stag leap'),
  _jump('1.2704', 40, 'Stag leap, ring/back bend'),
  _jump('1.2804', 40, 'Stag leap, 180° turn'),
  _jump('1.2806', 60, 'Stag leap, 180° turn, ring/back bend (Bessonova)'),
  _jump('1.2904', 40, 'Switch stag leap'),
  _jump('1.2906', 60, 'Switch stag leap, ring/back bend'),
  _jump('1.3002', 20, 'Fouetté leap, leg at the horizontal'),
  _jump('1.3003', 30, 'Fouetté leap, ring/back bend'),
  _jump('1.3102', 20, 'Fouetté with cabriole'),
  _jump('1.3103', 30, 'Fouetté with stag'),
  _jump('1.3105', 50, 'Fouetté with ring/back bend'),
  _jump('1.3203', 30, 'Entrelacé'),
  _jump('1.3205', 50, 'Entrelacé, ring/back bend'),
  // p.81.
  _jump('1.3303', 30, 'Turning stag leap'),
  _jump('1.3305', 50, 'Turning stag leap, ring/back bend'),
  _jump('1.3405', 50, 'Turning stag leap, switch of straight leg'),
  _jump('1.3407', 70, 'Turning stag leap, switch, ring/back bend'),
  _jump('1.3504', 40, 'Turning split leap (jeté en tournant)'),
  _jump('1.3505', 50, 'Turning split leap, rear leg bent, back arch'),
  _jump(
    '1.3506',
    60,
    'Turning split leap, rear leg bent then straight, back arch',
  ),
  _jump('1.3606', 60, 'Turning split leap, switch of straight legs'),
  _jump('1.3608', 80, 'Turning split leap, switch, ring/back bend'),
  _jump('1.3705', 50, 'Butterfly jump'),

  // Balances executed on the foot, p.88.
  _footBalance('2.101', 10, 'Passé forward or side'),
  _footBalance('2.201', 10, 'Free leg forward, bent'),
  _footBalance('2.202', 20, 'Free leg forward, straight'),
  _footBalance('2.203', 30, 'Free leg forward, trunk backward horizontal'),
  _footBalance('2.303', 30, 'Front split, with help'),
  _footBalance('2.305', 50, 'Front split, without help'),
  _footBalance('2.404', 40, 'Front split, trunk backward horizontal, help'),
  _footBalance('2.406', 60, 'Front split, trunk backward horizontal'),
  _footBalance('2.506', 60, 'Front split, trunk backward below horizontal'),
  _footBalance('2.602', 20, 'Free leg side horizontal'),
  _footBalance('2.603', 30, 'Free leg side, trunk side horizontal'),
  // p.89.
  _footBalance('2.703', 30, 'Side split, with help'),
  _footBalance('2.705', 50, 'Side split, without help'),
  _footBalance('2.804', 40, 'Side split, trunk side horizontal, with help'),
  _footBalance('2.806', 60, 'Side split, trunk side horizontal, no help'),
  _footBalance('2.902', 20, 'Arabesque'),
  _footBalance('2.903', 30, 'Arabesque, trunk forward horizontal'),
  _footBalance('2.904', 40, 'Arabesque, back bend'),
  _footBalance('2.1003', 30, 'Back split, with help'),
  _footBalance('2.1005', 50, 'Foot above head, without help'),
  _footBalance('2.1104', 40, 'Back split, trunk forward, with help'),
  _footBalance('2.1106', 60, 'Back split, trunk forward or ring, no help'),
  _footBalance('2.1202', 20, 'Attitude'),
  _footBalance('2.1203', 30, 'Ring with help / leg on the shoulder'),
  _footBalance('2.1204', 40, 'Ring without help / attitude with back bend'),
  // "Cossack" balances, p.90: no slow turn (#10.9.1).
  _otherBalance('2.1301', 10, 'Cossack, free leg horizontal'),
  _otherBalance('2.1402', 20, 'Cossack, foot higher than head, with help'),
  _otherBalance('2.1403', 30, 'Cossack, foot higher than head, no help'),
  // Balances executed on other parts of the body, p.90.
  _otherBalance('2.1501', 10, 'Lying on the floor, trunk lifted'),
  _otherBalance('2.1503', 30, 'Kabaeva, on the chest, with help'),
  _otherBalance('2.1504', 40, 'Kabaeva, on the chest, without help'),
  // Balances executed in motion (dynamic), p.90.
  _otherBalance('2.1604', 40, 'Passing from lying to the chest'),
  _otherBalance('2.1703', 30, 'Dynamic balance, kneeling to standing'),
  _otherBalance('2.1803', 30, 'Fouetté balance, leg at the horizontal'),
  _otherBalance('2.1805', 50, 'Fouetté balance, leg above the horizontal'),
  _otherBalance('2.1904', 40, 'Utyascheva'),

  // Rotations on 1 leg, p.98.
  _rotation('3.101', 10, 'Passé pivot', extra: 10),
  _rotation('3.203', 30, 'Spiral turn (Tonneau)', extra: 20),
  _rotation('3.301', 10, 'Free leg forward, bent', extra: 10),
  _rotation('3.303', 30, 'Free leg forward horizontal', extra: 20),
  _rotation('3.403', 30, 'Front split, with help', extra: 20),
  _rotation('3.405', 50, 'Front split, without help', extra: 20),
  _rotation('3.505', 50, 'Elkatib (180°)', extra: 20),
  _rotation('3.603', 30, 'Free leg side horizontal', extra: 20),
  _rotation('3.604', 40, 'Free leg side, trunk side horizontal', extra: 20),
  // p.99.
  _rotation('3.703', 30, 'Side split, with help', extra: 20),
  _rotation('3.705', 50, 'Side split, without help', extra: 20),
  _rotation('3.804', 40, 'Side split, trunk side (180°), with help', extra: 20),
  _rotation('3.805', 50, 'Side split, trunk side (180°) / Raffaeli', extra: 20),
  _rotation('3.903', 30, 'Arabesque', extra: 20),
  _rotation('3.904', 40, 'Arabesque, trunk forward horizontal', extra: 20),
  _rotation('3.905', 50, 'Arabesque, back bend', extra: 20),
  _rotation('3.1003', 30, 'Back split, with help', extra: 20),
  _rotation('3.1005', 50, 'Foot above head, without help', extra: 20),
  _rotation('3.1104', 40, 'Back split, trunk forward, with help', extra: 20),
  _rotation('3.1105', 50, 'Back split without help (Sakura)', extra: 10),
  // p.100.
  _rotation('3.1203', 30, 'Attitude', extra: 20),
  _rotation('3.1205', 50, 'Ring without help / attitude, back bend', extra: 20),
  _rotation('3.1303', 30, 'Ring with help / leg on the shoulder', extra: 20),
  _rotation('3.1405', 50, 'Front split, trunk backward (180°)', extra: 20),
  // p.101.
  _rotation('3.1501', 10, 'Cossack pivot', extra: 10),
  _rotation('3.1601', 10, 'Fouetté, passé', extra: 10, series: false),
  _rotation(
    '3.1602',
    20,
    'Fouetté, straight leg horizontal',
    extra: 10,
    series: false,
  ),
  _rotation('3.1704', 40, 'Illusion backward', extra: null),
  // Rotations on other parts of the body, p.101.
  _rotation(
    '3.1801',
    10,
    'Ralenkova: rotation on the back',
    extra: 10,
    series: false,
  ),
  _rotation(
    '3.1902',
    20,
    'Rotation on the stomach, legs to ring',
    extra: 10,
    series: false,
  ),
  _rotation('3.2003', 30, 'Ashram/Kanaeva (180°)', extra: 10, series: false),
  _rotation(
    '3.2101',
    10,
    'Rotation in split, trunk forward',
    extra: null,
    series: false,
  ),
  _rotation(
    '3.2202',
    20,
    'Rotation in split, trunk backward',
    extra: null,
    series: false,
  ),
];
