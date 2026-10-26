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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // SQLite does not enforce foreign keys (and cascades) unless asked.
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
