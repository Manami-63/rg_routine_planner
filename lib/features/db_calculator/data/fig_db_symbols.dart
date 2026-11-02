// FIG symbols of the DB tables, redrawn from the Code of Points 2025-2028
// (Part 1, #9 jumps/leaps, pp.76-81; #11 balances, pp.88-90; #13 rotations,
// pp.98-101) in the path format of `SymbolPath`.
//
// Balances share a stance: a bar for the arms and a stem for the supporting
// leg. A small "x" or "+" marks "with help"; a small arc marks "to the side";
// a ring is the head, where the trunk moves away from upright.
//
// Rotations are the same shapes on a pivot: a stem ending in a circle at the
// foot, or in a small cup for those with a minimum of 180°. A tick across the
// stem or a small "x" marks "with help"; a dot is the head.
//
// Jumps: a ring is the head for a 360° turn, a small cup a 180° turn. A line
// is a split, a line with a slanted end a stag, a zigzag a switch of legs.

const _stance = 'M30 14L90 14M60 14L60 90';
const _legForward = 'M60 46L90 46';
const _legBackward = 'M60 46L30 46';
const _splitForward = 'M60 56L92 14';
const _splitBackward = 'M60 56L26 14';
const _helpForward = 'M80 8L94 22M94 8L80 22';
const _helpBackward = 'M18 8L32 22M32 8L18 22';
const _side = 'M100 4Q110 10 107 22';
const _headBackward = 'M60 50L32 50O26 50 6';
const _headForward = 'M60 50L82 50O88 50 6';
const _plus = 'M78 4L78 24M68 14L88 14';
const _cossack = 'M30 10L84 10M54 10L54 40L72 56L50 84';

const _pivot = 'M54 8L54 74O54 83 9';
const _halfPivot = 'M54 8L54 90M36 72Q38 92 54 92Q70 92 72 72';
const _pivotArc = 'M86 10Q98 16 94 30';
const _pivotHelpForward = 'M74 6L88 20M88 6L74 20';
const _pivotHelpBackward = 'M20 6L34 20M34 6L20 20';
const _pivotHeadForward = 'M54 44L84 44D90 44 6';
const _helpTick = 'M38 14L70 20';

const _digit2 = 'M84 72Q90 64 96 72Q98 78 86 92L100 92';
const _digit2Left = 'M10 42Q18 34 24 42Q26 50 12 68L28 68';
const _digit3Left = 'M10 40Q20 34 24 44Q24 52 16 54Q28 56 26 66Q18 74 10 68';
const _cup44 = 'M42 8Q44 24 56 24Q68 24 70 8';
const _legFront = 'M44 34L44 90M44 34L92 34';
const _legBack = 'M76 34L76 90M30 34L76 34';
const _cossackJump = 'M54 40L18 66L78 66M54 40L54 92';
const _cossackCup = 'M40 20Q42 36 54 38Q66 36 68 20';
const _jumpHelp = 'M80 16L96 32M96 16L80 32';
const _jumpArc = 'M102 12Q112 18 108 30';
const _ring = 'M24 84L46 30Q92 24 92 58Q90 90 62 70L24 84';
const _split = 'M14 54L106 54';
const _splitUp = 'M22 56L34 18M22 56L100 24M42 94L42 70M30 80L42 68L54 80';
const _stag = 'M14 40L96 40L70 72';
const _entrelace = 'M56 84Q84 78 88 44M76 52L90 38L98 56M50 74L62 90L70 76';

const figDbSymbolPaths = <String, String>{
  '1.101': 'O60 14 9M60 23L46 56L62 46L50 90',
  '1.201': 'O44 14 9M44 23L36 56L56 44L44 88M56 44L78 44L78 88',
  '1.301': 'O60 18 11M60 29L60 90',
  '1.303': 'O54 18 11M54 29L54 90 $_digit2',
  '1.401': 'O52 16 10M52 26L52 90M52 44L80 58L52 72',
  '1.403': 'O52 16 10M52 26L52 90M52 44L80 58L52 72 $_digit2',
  '1.502': '$_cup44 $_legFront',
  '1.503': 'O56 16 10 $_legFront',
  '1.602': '$_cup44 $_legFront M92 12L92 28',
  '1.603': 'O56 16 10 $_legFront M92 12L92 28',
  '1.702': 'M58 6Q60 24 72 24Q84 24 86 6 $_legBack',
  '1.704': 'O72 16 10 $_legBack',
  '1.802': 'M54 8Q56 26 66 26Q78 26 80 8M66 26L66 90M66 52L44 52L28 34',
  '1.804': 'O66 16 10M66 38L66 90M66 62L46 62L30 44',
  '1.901': 'M36 8L36 90M60 50L60 90M76 50L76 90',
  '1.1001': 'M36 8L36 90M60 50L60 90M76 50L76 90M58 34Q72 36 76 48',
  '1.1101': 'M30 8L30 80M50 40L50 80M68 40L68 80M30 90L70 90M42 83L30 90L42 96',
  '1.1201': 'M90 20L30 52L90 84',
  '1.1301': 'M30 20L90 52L30 84',
  '1.1302': 'M34 20L92 52L34 84M36 52Q60 30 88 50M36 52Q60 74 88 54',
  '1.1403': 'M24 80L92 78L66 30L24 80',
  '1.1501': 'M68 24L22 62L100 62M68 24L68 92',
  '1.1503': 'M68 24L22 62L100 62M68 24L68 92M54 8Q56 22 68 24Q80 22 82 8',
  '1.1602': '$_cossackJump M54 70L88 26 $_jumpHelp',
  '1.1604': '$_cossackJump M54 70L88 26 $_jumpHelp $_cossackCup',
  '1.1703': '$_cossackJump M54 70L94 16',
  '1.1705': '$_cossackJump M54 70L94 16 $_cossackCup',
  '1.1802': '$_cossackJump M54 70L88 26 $_jumpHelp $_jumpArc',
  '1.1804': '$_cossackJump M54 70L88 26 $_jumpHelp $_cossackCup $_jumpArc',
  '1.1805': '$_cossackJump M54 70L88 26 $_jumpHelp O52 28 10 $_jumpArc',
  '1.1903': '$_cossackJump M54 70L94 16 $_jumpArc',
  '1.1905': '$_cossackJump M54 70L94 16 $_cossackCup $_jumpArc',
  '1.2002': _ring,
  '1.2003': '$_ring M56 52Q62 44 68 52Q70 58 58 68L72 68',
  '1.2103': _split,
  '1.2104': _splitUp,
  '1.2105': 'M14 62L106 62M46 62Q46 44 60 44Q76 44 76 60',
  '1.2205': '$_digit2Left M36 54L106 54',
  '1.2207': '$_digit3Left M36 54L106 54',
  '1.2305': 'M24 26L96 26L24 78L96 78',
  '1.2307': 'M24 44L96 44L24 86L96 86M44 44Q40 16 62 16Q84 18 74 44',
  '1.2404': 'M18 34L104 34M18 34L62 60L18 84L70 84',
  '1.2406':
      'M18 34L104 34M18 34L62 60L18 84L70 84M40 34Q42 12 58 12Q76 14 70 34',
  '1.2503': 'M14 54L92 54M100 44Q110 50 106 62',
  '1.2505': 'M14 54L92 54M100 44Q110 50 106 62M44 34Q46 52 58 54Q72 52 74 34',
  '1.2604':
      'M18 40L92 40M18 40L58 62L18 84L66 84M60 20L60 40M102 28Q112 34 108 46',
  '1.2605': 'M24 46L86 46L24 86L86 86M56 24L56 46M98 30Q108 36 104 48',
  '1.2702': _stag,
  '1.2704': '$_stag M40 40Q42 16 58 16Q76 18 70 40',
  '1.2804': '$_stag M46 20Q48 40 60 40Q74 38 74 20',
  '1.2806':
      '$_stag M30 40Q32 18 48 18Q64 20 58 40M68 20Q70 38 80 38Q92 36 92 20',
  '1.2904': 'M26 28L94 28L30 56L96 56L70 88',
  '1.2906': 'M26 44L94 44L30 66L96 66L72 92M44 44Q40 18 62 18Q86 20 76 44',
  '1.3002': 'M36 14L36 90M36 30Q60 30 66 8',
  '1.3003': 'M20 14L20 88M20 16Q34 46 50 16Q84 34 92 58Q86 84 60 72L20 88',
  '1.3102': 'M36 10L36 78M36 22Q56 22 60 6M56 44L56 78M72 44L72 78M36 88L76 88M48 81L36 88L48 94',
  '1.3103': 'M60 12L60 90M60 26Q80 26 86 8M60 38L26 64L60 78',
  '1.3105': 'M46 10L46 88M46 24Q62 24 68 8M46 40L18 66L50 86L104 48',
  '1.3203': 'M30 12L30 86M30 26Q50 26 56 8 $_entrelace',
  '1.3205': 'M30 10L30 66M30 14Q50 14 58 6M30 30L60 30M30 46L56 30 $_entrelace',
  '1.3303': '$_stag O46 30 9',
  '1.3305': '$_stag O46 32 7 M26 40Q26 14 46 14Q66 14 66 40',
  '1.3405': 'O56 18 9M22 30L98 30L30 56L98 56L72 88',
  '1.3407':
      'M26 44L94 44L30 66L96 66L72 92M40 44Q38 12 60 12Q84 14 80 44O60 32 7',
  '1.3504': 'M14 62L106 62O60 50 10',
  '1.3505': '$_splitUp O62 26 9',
  '1.3506': 'M14 62L106 62O60 50 7M40 62Q40 32 60 32Q80 32 80 62',
  '1.3606': 'O60 18 9M22 30L98 30L22 72L98 72',
  '1.3608': 'M22 44L98 44L22 86L98 86O60 32 7M38 44Q38 12 60 12Q82 12 82 44',
  '1.3705': 'M26 22L26 80L94 22L94 80L26 22',

  '2.101': '$_stance M60 36L84 36L60 58',
  '2.201': '$_stance M60 40L84 40L84 62',
  '2.202': '$_stance $_legForward',
  '2.203': 'M32 14L90 14M60 14L60 90O26 14 6',
  '2.303': '$_stance M60 56L87 15 $_helpForward',
  '2.305': '$_stance $_splitForward',
  '2.404': '$_stance $_headBackward $_plus',
  '2.406': '$_stance $_headBackward',
  '2.506': '$_stance M60 28Q36 28 32 66O30 74 6',
  '2.602': '$_stance $_legForward $_side',
  '2.603': 'M30 14L86 14M60 14L60 90O92 14 6 $_side',
  '2.703': '$_stance M60 56L87 15 $_helpForward $_side',
  '2.705': '$_stance $_splitForward $_side',
  '2.804': '$_stance $_headForward $_plus $_side',
  '2.806': '$_stance $_headForward M104 8L104 32',
  '2.902': '$_stance $_legBackward',
  '2.903': 'M30 14L86 14M60 14L60 90O92 14 6',
  '2.904': '$_stance $_legBackward M36 46Q40 28 60 28',
  '2.1003': '$_stance M60 56L31 21 $_helpBackward',
  '2.1005': '$_stance $_splitBackward',
  '2.1104': '$_stance $_headForward $_plus',
  '2.1106': '$_stance $_headForward',
  '2.1202': '$_stance M60 52L30 52L44 24',
  '2.1203': '$_stance M60 26L38 26L38 46L60 46M38 26L22 20',
  '2.1204': 'M28 14L90 14M60 14L60 90M28 14L28 46L60 46',
  '2.1301': '$_cossack M64 49L98 49',
  '2.1402': '$_cossack M66 51L92 24M86 16L100 30M100 16L86 30',
  '2.1403': '$_cossack M66 51L98 16',
  '2.1501': 'M14 60L78 60Q98 58 92 44Q84 34 76 44',
  '2.1503': 'M72 6Q42 50 52 78Q62 96 74 78Q78 62 56 60M46 34L78 30',
  '2.1504': 'M72 6Q42 50 52 78Q62 96 74 78Q78 62 56 60',
  '2.1604': 'M14 88L96 88M78 14Q50 50 58 72Q66 90 80 74Q84 58 62 56',
  '2.1703': 'M46 94L46 8M30 28L46 8L62 28M46 94Q106 50 46 8',
  '2.1803': '$_stance M42 46L78 46M42 62L78 62',
  '2.1805': 'M30 10L90 10M30 24L90 24M60 24L60 90',
  '2.1904':
      'M14 88L106 88M46 88L46 58L22 28M16 20L30 34M30 20L16 34'
      'M84 88L84 28M84 44Q66 46 66 62O66 68 5',

  '3.101': '$_pivot M54 30L80 30L56 54',
  '3.203':
      'M74 26Q60 6 44 18Q30 34 50 46Q72 52 70 36M48 44Q34 58 44 72O52 84 8',
  '3.301': '$_pivot M54 40L74 40L88 52',
  '3.303': '$_pivot M54 44L86 44',
  '3.403': '$_pivot M54 46L81 13 $_pivotHelpForward',
  '3.405': '$_pivot M54 62L88 8',
  '3.505': '$_halfPivot M54 30L34 30D28 30 6',
  '3.603': '$_pivot M54 44L86 44 $_pivotArc',
  '3.604': 'M26 30L86 30M56 30L56 76O56 84 6D92 30 5M102 12Q112 18 108 30',
  '3.703': '$_pivot M54 46L81 13 $_pivotHelpForward M96 10Q106 16 102 30',
  '3.705': '$_pivot M54 46L84 12 $_pivotArc',
  '3.804': '$_halfPivot $_helpTick $_pivotHeadForward M74 8Q84 12 82 24',
  '3.805': '$_halfPivot $_pivotHeadForward M74 12Q84 16 82 28',
  '3.903': '$_pivot M54 40L26 40',
  '3.904': 'M30 20L86 20M56 20L56 74O56 82 7D92 20 6',
  '3.905': 'M54 46L54 74O54 83 9M24 46L74 46M34 46Q34 16 54 16Q74 16 74 46',
  '3.1003': '$_pivot M54 50L27 13 $_pivotHelpBackward',
  '3.1005': '$_pivot M54 74L22 8',
  '3.1104': '$_pivot $_helpTick $_pivotHeadForward',
  '3.1105': '$_pivot M54 36L84 36D90 36 6',
  '3.1203': '$_pivot M54 44L32 44L26 24',
  '3.1205': '$_pivot M54 20L26 38L54 50',
  '3.1303': '$_pivot M54 22L26 42L54 50M32 12L60 40',
  '3.1405': '$_halfPivot M54 30Q34 34 36 60',
  '3.1501': 'M62 8L34 42L64 36L42 68O37 80 9M50 38L92 38',
  '3.1601': '$_pivot M32 36L78 36L56 60',
  '3.1602': '$_pivot M30 36L80 36',
  '3.1704':
      'M28 74L28 32Q30 8 52 8Q76 12 76 44Q74 76 50 88L50 30M16 56L28 76L40 56',
  '3.1801': 'M12 36L84 72L32 72O44 36 7',
  '3.1902': 'M14 50L60 74Q84 78 78 56Q68 46 64 42O66 30 11',
  '3.2003': 'O60 24 9 M26 50L94 50M46 62Q60 78 74 62',
  '3.2101': 'M16 52L104 52O60 52 9',
  '3.2202': 'M16 66L104 38O60 52 9',
};
