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
  tables: [Routines, RoutineBodyElements, RoutineRisks, RoutineRiskCriteria],
)
class AppDatabase extends _$AppDatabase {
  /// Pass an [executor] in tests (e.g. `NativeDatabase.memory()`).
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'rg_routine_planner'));

  @override
  int get schemaVersion => 3;

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
    },
    // SQLite does not enforce foreign keys (and cascades) unless asked.
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
