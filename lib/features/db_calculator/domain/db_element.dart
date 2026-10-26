import '../../../core/scoring/score.dart';

/// The body-difficulty families an element can belong to.
enum DbElementGroup {
  jump('Jumps / Leaps'),
  balance('Balances'),
  rotation('Rotations');

  const DbElementGroup(this.label);

  final String label;
}

/// A single Difficulty of Body element in a catalogue.
class DbElement {
  const DbElement({
    required this.id,
    required this.name,
    required this.group,
    required this.value,
    required this.rulesetId,
  });

  final String id;
  final String name;
  final DbElementGroup group;
  final Score value;

  /// The [RulesetVersion.id] this element's value belongs to.
  final String rulesetId;

  @override
  bool operator ==(Object other) =>
      other is DbElement &&
      other.id == id &&
      other.name == name &&
      other.group == group &&
      other.value == value &&
      other.rulesetId == rulesetId;

  @override
  int get hashCode => Object.hash(id, name, group, value, rulesetId);

  @override
  String toString() => 'DbElement($id, ${value.format()})';
}
