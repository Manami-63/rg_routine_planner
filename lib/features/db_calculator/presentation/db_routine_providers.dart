import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routines/presentation/routine_controller.dart';
import '../domain/db_counting.dart';
import '../../../core/scoring/score.dart';
import '../domain/db_element.dart';
import '../domain/db_element_options.dart';
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
      return DbCountLimits.of(
        ref.watch(routineRequirementsProvider(id)),
        ref.watch(routineProvider(id).select((r) => r.apparatus)),
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

  /// Replaces the element at [index], keeping its place, time and cell.
  void replaceElementAt(
    int index,
    DbElement element, [
    DbElementOptions options = DbElementOptions.none,
  ]) => updateDb((db) => db.withElementReplacedAt(index, element, options));

  void removeElementAt(int index) =>
      updateDb((db) => db.withElementRemovedAt(index));

  /// Moves an element to another place in the performance order.
  void moveElement(int from, int to) =>
      updateDb((db) => db.withElementMoved(from, to));

  void setElementOptionsAt(int index, DbElementOptions options) =>
      updateDb((db) => db.withElementOptionsAt(index, options));

  /// Adds an element the user entered, valued at [value].
  void addCustomElement(DbElement element, Score value) => updateDb(
    (db) => db.withElementAdded(element, DbElementOptions(manualValue: value)),
  );

  void addRisk(RiskElement risk) => updateDb((db) => db.withRiskAdded(risk));

  /// Replaces the risk at [index], keeping its place, time and cell.
  void replaceRiskAt(int index, RiskElement risk) =>
      updateDb((db) => db.withRiskReplacedAt(index, risk));

  void removeRiskAt(int index) => updateDb((db) => db.withRiskRemovedAt(index));

  /// Moves a risk to another place in the performance order. Which risks
  /// count can change, because the first N count.
  void moveRisk(int from, int to) =>
      updateDb((db) => db.withRiskMoved(from, to));

  /// Removes all DB content; the routine's name and level are kept.
  void clearDb() => updateDb((db) => db.cleared());
}
