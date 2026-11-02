// FIG symbols of the DB tables, redrawn from the Code of Points 2025-2028
// (Part 1, #11 balances, pp.88-90) in the path format of `SymbolPath`.
// Jumps/leaps (#9) and rotations (#13) are still to come.
//
// Balances share a stance: a bar for the arms and a stem for the supporting
// leg. A small "x" or "+" marks "with help"; a small arc marks "to the side";
// a ring is the head, where the trunk moves away from upright.

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
};
