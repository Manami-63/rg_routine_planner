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

  /// `Apparatus.name` (e.g. `hoop`), or null if none chosen. Added in v2.
  TextColumn get apparatus => text().nullable()();

  /// Preset level id (e.g. `fig-senior`), `custom`, or null for no level.
  TextColumn get levelId => text().nullable()();

  // Requirements of a custom (non-FIG) level. Null otherwise.
  IntColumn get customDbMin => integer().nullable()();
  IntColumn get customDbMax => integer().nullable()();
  IntColumn get customRiskMin => integer().nullable()(); // v2
  IntColumn get customRiskMax => integer().nullable()(); // v2
  IntColumn get customDaMin => integer().nullable()();
  IntColumn get customDaMax => integer().nullable()();

  /// Required body groups, as comma-separated `DbElementGroup.name`s (e.g.
  /// `jump,balance`). Null or empty for none. Added in v2.
  TextColumn get customRequiredBodyGroups => text().nullable()();

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

  /// Catalogue id, or `custom` for an element the user entered.
  TextColumn get elementId => text()();
  IntColumn get position => integer()();

  // How the element is performed. Added in v3.
  BoolColumn get flatFoot => boolean().withDefault(const Constant(false))();
  BoolColumn get slowTurn => boolean().withDefault(const Constant(false))();
  IntColumn get extraRotations => integer().withDefault(const Constant(0))();

  /// A value entered by the user, in hundredths. Null when not set.
  IntColumn get manualValue => integer().nullable()();

  // Name and `DbElementGroup.name` of a custom element. Null otherwise.
  TextColumn get customName => text().nullable()();
  TextColumn get customGroup => text().nullable()();
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
