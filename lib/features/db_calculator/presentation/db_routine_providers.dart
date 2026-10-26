import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routines/presentation/routine_controller.dart';
import '../domain/db_element.dart';
import '../domain/db_routine.dart';
import '../domain/db_scoring_engine.dart';
import '../domain/risk.dart';
import 'db_calculator_providers.dart';

/// The DB content of the routine being edited.
final dbRoutineProvider = Provider<DbRoutine>(
  (ref) => ref.watch(routineControllerProvider.select((r) => r.db)),
);

/// Derived state: recalculated automatically whenever the DB content changes.
final dbScoreResultProvider = Provider<DbScoreResult>(
  (ref) => ref
      .watch(dbScoringEngineProvider)
      .calculate(ref.watch(dbRoutineProvider)),
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
