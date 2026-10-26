import 'db_element.dart';

/// An immutable DB routine: a name plus an ordered list of elements.
///
/// Every change returns a new instance. This keeps state updates
/// predictable in Riverpod and makes the class trivial to serialise when
/// local persistence is added.
class DbRoutine {
  DbRoutine({
    required this.name,
    required this.rulesetId,
    List<DbElement> elements = const [],
  }) : elements = List.unmodifiable(elements);

  final String name;

  /// The [RulesetVersion.id] this routine is planned against.
  final String rulesetId;

  /// Elements in performance order. The same element may appear twice.
  final List<DbElement> elements;

  bool get isEmpty => elements.isEmpty;

  DbRoutine rename(String newName) =>
      DbRoutine(name: newName, rulesetId: rulesetId, elements: elements);

  DbRoutine withElementAdded(DbElement element) => DbRoutine(
    name: name,
    rulesetId: rulesetId,
    elements: [...elements, element],
  );

  /// Removes by position rather than by id, because a routine can contain
  /// the same element more than once.
  DbRoutine withElementRemovedAt(int index) => DbRoutine(
    name: name,
    rulesetId: rulesetId,
    elements: [...elements]..removeAt(index),
  );

  /// Removes all elements but keeps the name and ruleset.
  DbRoutine cleared() => DbRoutine(name: name, rulesetId: rulesetId);

  @override
  bool operator ==(Object other) {
    if (other is! DbRoutine ||
        other.name != name ||
        other.rulesetId != rulesetId ||
        other.elements.length != elements.length) {
      return false;
    }
    for (var i = 0; i < elements.length; i++) {
      if (other.elements[i] != elements[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(name, rulesetId, Object.hashAll(elements));
}
