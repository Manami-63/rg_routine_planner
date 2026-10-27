import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/scoring/apparatus.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/db_counting.dart';
import '../domain/db_element.dart';
import '../domain/db_routine.dart';
import '../domain/db_scoring_engine.dart';
import '../domain/risk.dart';
import 'db_calculator_providers.dart';

/// The DB content of the routine with the given id.
final dbRoutineProvider = Provider.autoDispose.family<DbRoutine, String>(
  (ref, id) => ref.watch(routineProvider(id).select((r) => r.db)),
);

/// How many DB and risks count, from the routine's level and apparatus.
final dbCountLimitsProvider = Provider.autoDispose
    .family<DbCountLimits, String>((ref, id) {
      final requirements = ref.watch(routineRequirementsProvider(id));
      final apparatus = ref.watch(
        routineProvider(id).select((r) => r.apparatus),
      );
      return DbCountLimits(
        maxElements: requirements?.db.max,
        // Freehand routines have no throws, so no risk can count.
        maxRisks: apparatus == Apparatus.freehand ? 0 : requirements?.risk.max,
      );
    });

/// Derived state: recalculated automatically whenever the DB content or the
/// level's limits change.
final dbScoreResultProvider = Provider.autoDispose
    .family<DbScoreResult, String>(
      (ref, id) => ref
          .watch(dbScoringEngineProvider)
          .calculate(
            ref.watch(dbRoutineProvider(id)),
            limits: ref.watch(dbCountLimitsProvider(id)),
          ),
    );

/// DB editing actions, kept in the DB feature so the routines feature does
/// not need to know DB vocabulary.
extension DbRoutineEditing on RoutineController {
  void addElement(DbElement element) =>
      updateDb((db) => db.withElementAdded(element));

  void removeElementAt(int index) =>
      updateDb((db) => db.withElementRemovedAt(index));

  void addRisk(RiskElement risk) => updateDb((db) => db.withRiskAdded(risk));

  void removeRiskAt(int index) => updateDb((db) => db.withRiskRemovedAt(index));

  /// Removes all DB content; the routine's name and level are kept.
  void clearDb() => updateDb((db) => db.cleared());
}
