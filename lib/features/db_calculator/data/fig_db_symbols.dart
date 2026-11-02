// FIG symbols of the DB tables, redrawn from the Code of Points 2025-2028
// (Part 1, #11 balances, pp.88-90; #13 rotations, pp.98-101) in the path
// format of `SymbolPath`. Jumps/leaps (#9) are still to come.
//
// Balances share a stance: a bar for the arms and a stem for the supporting
// leg. A small "x" or "+" marks "with help"; a small arc marks "to the side";
// a ring is the head, where the trunk moves away from upright.
//
// Rotations are the same shapes on a pivot: a stem ending in a circle at the
// foot, or in a small cup for those with a minimum of 180°. A tick across the
// stem or a small "x" marks "with help"; a dot is the head.

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

const figDbSymbolPaths = <String, String>{
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
