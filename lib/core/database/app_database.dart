import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'routine_tables.dart';

part 'app_database.g.dart';

/// The app's local SQLite database.
///
/// After changing tables, run
/// `dart run build_runner build --delete-conflicting-outputs`, bump
/// [schemaVersion] and add a migration step.
@DriftDatabase(
  tables: [
    Routines,
    RoutineBodyElements,
    RoutineRisks,
    RoutineRiskCriteria,
    RoutineApparatusDifficulties,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Pass an [executor] in tests (e.g. `NativeDatabase.memory()`).
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'rg_routine_planner'));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Apparatus, custom risk limits and required body groups.
        await m.addColumn(routines, routines.apparatus);
        await m.addColumn(routines, routines.customRiskMin);
        await m.addColumn(routines, routines.customRiskMax);
        await m.addColumn(routines, routines.customRequiredBodyGroups);
      }
      if (from < 3) {
        // Element options (flat foot, slow turn, ...) and custom elements.
        final elements = routineBodyElements;
        await m.addColumn(elements, elements.flatFoot);
        await m.addColumn(elements, elements.slowTurn);
        await m.addColumn(elements, elements.extraRotations);
        await m.addColumn(elements, elements.manualValue);
        await m.addColumn(elements, elements.customName);
        await m.addColumn(elements, elements.customGroup);
      }
      if (from < 4) {
        // The sample catalogue was replaced by the FIG one; routines planned
        // with sample data are deleted (agreed: they were only test data).
        // Children are deleted explicitly because foreign keys (and their
        // cascades) are only switched on in `beforeOpen`.
        const sample = "SELECT id FROM routines WHERE ruleset_id = 'sample-v0'";
        await customStatement(
          'DELETE FROM routine_risk_criteria WHERE routine_risk_id IN '
          '(SELECT id FROM routine_risks WHERE routine_id IN ($sample))',
        );
        await customStatement(
          'DELETE FROM routine_risks WHERE routine_id IN ($sample)',
        );
        await customStatement(
          'DELETE FROM routine_body_elements WHERE routine_id IN ($sample)',
        );
        await customStatement(
          "DELETE FROM routines WHERE ruleset_id = 'sample-v0'",
        );
      }
      if (from < 5) {
        await m.addColumn(routineBodyElements, routineBodyElements.seriesCount);
      }
      if (from < 6) {
        await m.createTable(routineApparatusDifficulties);
      }
      if (from < 7) {
        await m.addColumn(routines, routines.notes);
      }
    },
    // SQLite does not enforce foreign keys (and cascades) unless asked.
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
