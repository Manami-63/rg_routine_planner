import 'package:drift/drift.dart';

// Routine storage. Table and column names (snake_case in SQL) mirror what a
// future Laravel/MySQL schema would use, so syncing later is a 1:1 mapping.
//
// Rows store catalogue ids (e.g. `sample-jump-a`), never values: values are
// looked up from the current catalogue when a routine is loaded.

@DataClassName('RoutineRow')
class Routines extends Table {
  /// UUID, generated on the device.
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get rulesetId => text()();

  /// Preset level id (e.g. `fig-senior`), `custom`, or null for no level.
  TextColumn get levelId => text().nullable()();

  // Requirements of a custom (non-FIG) level. Null otherwise.
  IntColumn get customDbMin => integer().nullable()();
  IntColumn get customDbMax => integer().nullable()();
  IntColumn get customDaMin => integer().nullable()();
  IntColumn get customDaMax => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RoutineBodyElementRow')
class RoutineBodyElements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get elementId => text()();
  IntColumn get position => integer()();
}

@DataClassName('RoutineRiskRow')
class RoutineRisks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get rotationOptionId => text()();
  IntColumn get position => integer()();
}

@DataClassName('RoutineRiskCriterionRow')
class RoutineRiskCriteria extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineRiskId =>
      integer().references(RoutineRisks, #id, onDelete: KeyAction.cascade)();
  TextColumn get criterionId => text()();
  IntColumn get position => integer()();
}
