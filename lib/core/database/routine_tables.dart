import 'package:drift/drift.dart';

// Routine storage. Table and column names (snake_case in SQL) mirror what a
// future Laravel/MySQL schema would use, so syncing later is a 1:1 mapping.
//
// Rows store catalogue ids (e.g. `fig-2.203`), never values: values are
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

  /// Minimum dance steps combinations (S) of a custom level. Added in v9.
  IntColumn get customDanceStepsMin => integer().nullable()();

  /// Free text from the user. Empty for none. Added in v7.
  TextColumn get notes => text().withDefault(const Constant(''))();

  // The routine's music: the app's copy and the name the user chose. Null
  // for none. Added in v8.
  TextColumn get musicFileName => text().nullable()();
  TextColumn get musicTitle => text().nullable()();

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

  /// Identical elements performed in a series (1 = none). Added in v5.
  IntColumn get seriesCount => integer().withDefault(const Constant(1))();

  /// A value entered by the user, in hundredths. Null when not set.
  IntColumn get manualValue => integer().nullable()();

  // Name and `DbElementGroup.name` of a custom element. Null otherwise.
  TextColumn get customName => text().nullable()();
  TextColumn get customGroup => text().nullable()();

  /// When the element starts in the music, in milliseconds. Null when not
  /// marked. Added in v10.
  IntColumn get timeMs => integer().nullable()();

  /// Where on the floor it starts: `FloorCell.number` (1-9), or null.
  /// Added in v11.
  IntColumn get floorCell => integer().nullable()();
}

@DataClassName('RoutineRiskRow')
class RoutineRisks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get rotationOptionId => text()();
  IntColumn get position => integer()();

  /// Music time in milliseconds, or null. Added in v10.
  IntColumn get timeMs => integer().nullable()();

  /// Where on the floor it starts: `FloorCell.number` (1-9), or null.
  /// Added in v11.
  IntColumn get floorCell => integer().nullable()();
}

@DataClassName('RoutineRiskCriterionRow')
class RoutineRiskCriteria extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineRiskId =>
      integer().references(RoutineRisks, #id, onDelete: KeyAction.cascade)();
  TextColumn get criterionId => text()();
  IntColumn get position => integer()();
}

/// One DA of a routine, in performance order. Added in v6.
@DataClassName('RoutineApparatusDifficultyRow')
class RoutineApparatusDifficulties extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  /// Catalogue id of the base, or `custom` for a DA the user entered.
  TextColumn get baseId => text()();

  /// Catalogue id of a 2nd base after a catch from a high throw, or null.
  TextColumn get secondBaseId => text().nullable()();

  /// Criteria performed, as comma-separated `DaCriterion.name`s (e.g.
  /// `outsideVisualField,rotation`). Empty for none.
  TextColumn get criteria => text().withDefault(const Constant(''))();

  /// The "rotation" criterion is a pre-acrobatic element.
  BoolColumn get preAcrobatic => boolean().withDefault(const Constant(false))();

  /// A value entered by the user, in hundredths. Null when not set.
  IntColumn get manualValue => integer().nullable()();

  /// Name of a custom DA. Null otherwise.
  TextColumn get customName => text().nullable()();

  /// Music time in milliseconds, or null. Added in v10.
  IntColumn get timeMs => integer().nullable()();

  /// Where on the floor it starts: `FloorCell.number` (1-9), or null.
  /// Added in v11.
  IntColumn get floorCell => integer().nullable()();
}

/// One dance steps combination (S) of a routine. S have no details, only
/// an optional music time. Added in v10 (v9 stored only a count).
@DataClassName('RoutineDanceStepRow')
class RoutineDanceSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  /// Music time in milliseconds, or null.
  IntColumn get timeMs => integer().nullable()();

  /// Where on the floor it starts: `FloorCell.number` (1-9), or null.
  /// Added in v11.
  IntColumn get floorCell => integer().nullable()();
}
