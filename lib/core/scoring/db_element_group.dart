/// The body-difficulty families an element can belong to.
///
/// Lives in `core` because levels (required groups) and the DB calculator
/// (elements) both use it.
enum DbElementGroup {
  jump('Jumps / Leaps', 'leap'),
  balance('Balances', 'balance'),
  rotation('Rotations', 'rotation'),

  /// Only for unknown elements; never used in a catalogue or requirement.
  unknown('Unknown', 'unknown element');

  const DbElementGroup(this.label, this.singular);

  /// Plural heading, e.g. "Balances".
  final String label;

  /// One element of the group in a sentence, e.g. "a balance" → "balance".
  final String singular;

  /// Groups a level can require, i.e. every group except [unknown].
  static const requirable = [jump, balance, rotation];
}
