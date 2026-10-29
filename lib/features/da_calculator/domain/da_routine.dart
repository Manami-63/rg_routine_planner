import '../../../core/utils/list_equality.dart';
import 'da_element.dart';

/// The DA part of a routine: apparatus difficulties in performance order.
///
/// Order matters, because DA count in chronological order. Name, level and
/// identity belong to the enclosing `Routine`. Every change returns a new
/// instance.
class DaRoutine {
  DaRoutine({required this.rulesetId, List<DaElement> elements = const []})
    : elements = List.unmodifiable(elements);

  /// The [RulesetVersion.id] this content is planned against.
  final String rulesetId;

  final List<DaElement> elements;

  bool get isEmpty => elements.isEmpty;

  DaRoutine _withElements(List<DaElement> elements) =>
      DaRoutine(rulesetId: rulesetId, elements: elements);

  DaRoutine withElementAdded(DaElement element) =>
      _withElements([...elements, element]);

  DaRoutine withElementReplacedAt(int index, DaElement element) =>
      _withElements([...elements]..[index] = element);

  DaRoutine withElementRemovedAt(int index) =>
      _withElements([...elements]..removeAt(index));

  /// Moves the element at [from] so it ends up at position [to].
  DaRoutine withElementMoved(int from, int to) {
    final moved = [...elements];
    moved.insert(to, moved.removeAt(from));
    return _withElements(moved);
  }

  /// Removes all elements but keeps the ruleset.
  DaRoutine cleared() => DaRoutine(rulesetId: rulesetId);

  @override
  bool operator ==(Object other) =>
      other is DaRoutine &&
      other.rulesetId == rulesetId &&
      listEqual(other.elements, elements);

  @override
  int get hashCode => Object.hash(rulesetId, Object.hashAll(elements));
}
