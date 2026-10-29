import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routines/presentation/routine_controller.dart';
import '../domain/da_element.dart';
import '../domain/da_routine.dart';
import '../domain/da_scoring_engine.dart';
import 'da_calculator_providers.dart';

/// The DA content of the routine with the given id.
final daRoutineProvider = Provider.autoDispose.family<DaRoutine, String>(
  (ref, id) => ref.watch(routineProvider(id).select((r) => r.da)),
);

/// How many DA count, from the routine's level and apparatus; `null` for
/// no limit.
final daMaxCountedProvider = Provider.autoDispose.family<int?, String>((
  ref,
  id,
) {
  return daMaxCounted(
    ref.watch(routineRequirementsProvider(id)),
    ref.watch(routineProvider(id).select((r) => r.apparatus)),
  );
});

/// Derived state: recalculated whenever the DA, apparatus or level change.
final daScoreResultProvider = Provider.autoDispose
    .family<DaScoreResult, String>(
      (ref, id) => ref
          .watch(daScoringEngineProvider)
          .calculate(
            ref.watch(daRoutineProvider(id)),
            apparatus: ref.watch(
              routineProvider(id).select((r) => r.apparatus),
            ),
            maxCounted: ref.watch(daMaxCountedProvider(id)),
          ),
    );

/// DA editing actions, kept in the DA feature so the routines feature does
/// not need to know DA vocabulary.
extension DaRoutineEditing on RoutineController {
  void addDa(DaElement element) =>
      updateDa((da) => da.withElementAdded(element));

  void replaceDaAt(int index, DaElement element) =>
      updateDa((da) => da.withElementReplacedAt(index, element));

  void removeDaAt(int index) =>
      updateDa((da) => da.withElementRemovedAt(index));

  /// Moves a DA to another place in the performance order.
  void moveDa(int from, int to) =>
      updateDa((da) => da.withElementMoved(from, to));

  /// Removes all DA; the routine's DB, name and level are kept.
  void clearDa() => updateDa((da) => da.cleared());
}
