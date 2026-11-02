import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/database/app_database.dart';
import 'package:rg_routine_planner/core/floor/floor_cell.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';
import 'package:rg_routine_planner/features/routines/data/drift_routine_repository.dart';

import '../../features/da_calculator/test_data.dart';
import '../../features/db_calculator/test_data.dart';

// The v1 schema as shipped (commit 1105d9d), with one saved routine.
const _v1Schema = [
  'CREATE TABLE routines (id TEXT NOT NULL, name TEXT NOT NULL, '
      'ruleset_id TEXT NOT NULL, level_id TEXT NULL, '
      'custom_db_min INTEGER NULL, custom_db_max INTEGER NULL, '
      'custom_da_min INTEGER NULL, custom_da_max INTEGER NULL, '
      'created_at TEXT NOT NULL, updated_at TEXT NOT NULL, PRIMARY KEY (id))',
  'CREATE TABLE routine_body_elements (id INTEGER NOT NULL PRIMARY KEY '
      'AUTOINCREMENT, routine_id TEXT NOT NULL REFERENCES routines (id) '
      'ON DELETE CASCADE, element_id TEXT NOT NULL, position INTEGER NOT NULL)',
  'CREATE TABLE routine_risks (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'routine_id TEXT NOT NULL REFERENCES routines (id) ON DELETE CASCADE, '
      'rotation_option_id TEXT NOT NULL, position INTEGER NOT NULL)',
  'CREATE TABLE routine_risk_criteria (id INTEGER NOT NULL PRIMARY KEY '
      'AUTOINCREMENT, routine_risk_id INTEGER NOT NULL REFERENCES '
      'routine_risks (id) ON DELETE CASCADE, criterion_id TEXT NOT NULL, '
      'position INTEGER NOT NULL)',
  "INSERT INTO routines VALUES ('r1', 'Old hoop', 'test-v1', 'custom', "
      "1, 4, NULL, 3, '2026-10-26T09:00:00.000Z', '2026-10-26T09:00:00.000Z')",
  "INSERT INTO routine_body_elements (routine_id, element_id, position) "
      "VALUES ('r1', 'jump', 0)",
  'PRAGMA user_version = 1',
];

// The v9 schema (commit 2c4423e): S stored as a count, no music times.
const _v9Schema = [
  'CREATE TABLE routines (id TEXT NOT NULL, name TEXT NOT NULL, '
      'ruleset_id TEXT NOT NULL, apparatus TEXT NULL, level_id TEXT NULL, '
      'custom_db_min INTEGER NULL, custom_db_max INTEGER NULL, '
      'custom_risk_min INTEGER NULL, custom_risk_max INTEGER NULL, '
      'custom_da_min INTEGER NULL, custom_da_max INTEGER NULL, '
      'custom_required_body_groups TEXT NULL, '
      'custom_dance_steps_min INTEGER NULL, '
      "notes TEXT NOT NULL DEFAULT '', music_file_name TEXT NULL, "
      'music_title TEXT NULL, '
      'dance_step_count INTEGER NOT NULL DEFAULT 0, '
      'created_at TEXT NOT NULL, updated_at TEXT NOT NULL, PRIMARY KEY (id))',
  'CREATE TABLE routine_body_elements (id INTEGER NOT NULL PRIMARY KEY '
      'AUTOINCREMENT, routine_id TEXT NOT NULL REFERENCES routines (id) '
      'ON DELETE CASCADE, element_id TEXT NOT NULL, position INTEGER NOT NULL, '
      'flat_foot INTEGER NOT NULL DEFAULT 0, '
      'slow_turn INTEGER NOT NULL DEFAULT 0, '
      'extra_rotations INTEGER NOT NULL DEFAULT 0, '
      'series_count INTEGER NOT NULL DEFAULT 1, manual_value INTEGER NULL, '
      'custom_name TEXT NULL, custom_group TEXT NULL)',
  'CREATE TABLE routine_risks (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'routine_id TEXT NOT NULL REFERENCES routines (id) ON DELETE CASCADE, '
      'rotation_option_id TEXT NOT NULL, position INTEGER NOT NULL)',
  'CREATE TABLE routine_risk_criteria (id INTEGER NOT NULL PRIMARY KEY '
      'AUTOINCREMENT, routine_risk_id INTEGER NOT NULL REFERENCES '
      'routine_risks (id) ON DELETE CASCADE, criterion_id TEXT NOT NULL, '
      'position INTEGER NOT NULL)',
  'CREATE TABLE routine_apparatus_difficulties (id INTEGER NOT NULL PRIMARY '
      'KEY AUTOINCREMENT, routine_id TEXT NOT NULL REFERENCES routines (id) '
      'ON DELETE CASCADE, position INTEGER NOT NULL, base_id TEXT NOT NULL, '
      'second_base_id TEXT NULL, criteria TEXT NOT NULL DEFAULT \'\', '
      'pre_acrobatic INTEGER NOT NULL DEFAULT 0, manual_value INTEGER NULL, '
      'custom_name TEXT NULL)',
  "INSERT INTO routines (id, name, ruleset_id, apparatus, level_id, "
      "custom_dance_steps_min, notes, dance_step_count, created_at, "
      "updated_at) VALUES ('r1', 'Ball', 'test-v1', 'ball', 'custom', 2, "
      "'Keep', 3, '2026-10-30T09:00:00.000Z', '2026-10-30T09:00:00.000Z')",
  "INSERT INTO routines (id, name, ruleset_id, created_at, updated_at) "
      "VALUES ('r2', 'No S', 'test-v1', '2026-10-30T09:00:00.000Z', "
      "'2026-10-30T09:00:00.000Z')",
  "INSERT INTO routine_body_elements (routine_id, element_id, position) "
      "VALUES ('r1', 'jump', 0)",
  "INSERT INTO routine_apparatus_difficulties (routine_id, position, "
      "base_id) VALUES ('r1', 0, 'roll')",
  'PRAGMA user_version = 9',
];

AppDatabase _v1Database(List<String> extra) {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(
    NativeDatabase.memory(
      setup: (raw) {
        for (final statement in [..._v1Schema, ...extra]) {
          raw.execute(statement);
        }
      },
    ),
  );
}

void main() {
  test('v1 routines load after upgrading to the latest schema', () async {
    final db = _v1Database(const []);
    addTearDown(db.close);
    final repository = DriftRoutineRepository(
      db,
      catalogue: FakeDbCatalogueRepository(),
      daCatalogue: FakeDaCatalogueRepository(),
      presetLevels: figLevels,
    );

    final routine = await repository.fetchRoutine('r1');

    expect(routine!.name, 'Old hoop');
    expect(routine.apparatus, isNull);
    expect(routine.db.elements, [testJump]);
    expect(routine.db.elementOptions, [DbElementOptions.none]);
    expect(routine.da.elements, isEmpty);
    expect(routine.notes, isEmpty);
    expect(routine.music, isNull);
    expect(routine.danceStepCount, 0);
    expect(
      routine.level,
      const CompetitionLevel.custom(
        LevelRequirements(
          db: CountLimit(min: 1, max: 4),
          da: CountLimit(max: 3),
        ),
      ),
    );
  });

  test('upgraded databases can save DA, notes and dance steps', () async {
    final db = _v1Database(const []);
    addTearDown(db.close);
    final repository = DriftRoutineRepository(
      db,
      catalogue: FakeDbCatalogueRepository(),
      daCatalogue: FakeDaCatalogueRepository(),
      presetLevels: figLevels,
    );
    final routine = (await repository.fetchRoutine('r1'))!;
    final withDa = routine
        .withDa(routine.da.withElementAdded(DaElement(base: testThrow)))
        .withNotes('New music')
        .withDanceStepCount(2)
        .withLevel(
          const CompetitionLevel.custom(LevelRequirements(minDanceSteps: 2)),
        );

    await repository.saveRoutine(withDa);

    expect(await repository.fetchRoutine('r1'), withDa);
  });

  test('upgraded databases can save Fouetté cycles', () async {
    final db = _v1Database(const []);
    addTearDown(db.close);
    final repository = DriftRoutineRepository(
      db,
      catalogue: FakeDbCatalogueRepository(),
      daCatalogue: FakeDaCatalogueRepository(),
      presetLevels: figLevels,
    );
    final routine = (await repository.fetchRoutine('r1'))!;
    expect(routine.db.elementOptions.single.rotationCycles, isNull);
    final withCycles = routine.withDb(
      routine.db.withElementOptionsAt(
        0,
        const DbElementOptions(extraRotations: 5, rotationCycles: '2121'),
      ),
    );

    await repository.saveRoutine(withCycles);

    expect(await repository.fetchRoutine('r1'), withCycles);
  });

  test('v9 S counts become S rows without times or cells', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          for (final statement in _v9Schema) {
            raw.execute(statement);
          }
        },
      ),
    );
    addTearDown(db.close);
    final repository = DriftRoutineRepository(
      db,
      catalogue: FakeDbCatalogueRepository(),
      daCatalogue: FakeDaCatalogueRepository(),
      presetLevels: figLevels,
    );

    final routine = (await repository.fetchRoutine('r1'))!;

    expect(routine.danceStepTimes, [null, null, null]);
    expect(routine.notes, 'Keep');
    expect(
      routine.level,
      const CompetitionLevel.custom(LevelRequirements(minDanceSteps: 2)),
    );
    expect(routine.db.elementTimes, [null]);
    expect(routine.da.times, [null]);
    expect((await repository.fetchRoutine('r2'))!.danceStepTimes, isEmpty);

    // The upgraded tables take times and cells.
    final timed = routine
        .withDanceStepTimeAt(0, const Duration(seconds: 3))
        .withDanceStepCellAt(0, FloorCell.centre)
        .withDa(routine.da.withElementCellAt(0, FloorCell.back));
    await repository.saveRoutine(timed);
    expect(await repository.fetchRoutine('r1'), timed);
  });

  test('routines planned with sample data are deleted on upgrade', () async {
    final db = _v1Database([
      "INSERT INTO routines VALUES ('s1', 'Sample', 'sample-v0', NULL, NULL, "
          "NULL, NULL, NULL, '2026-10-26T09:00:00.000Z', "
          "'2026-10-26T09:00:00.000Z')",
      "INSERT INTO routine_body_elements (routine_id, element_id, position) "
          "VALUES ('s1', 'sample-jump-a', 0)",
      "INSERT INTO routine_risks (routine_id, rotation_option_id, position) "
          "VALUES ('s1', 'sample-rotations-2', 0)",
      "INSERT INTO routine_risk_criteria (routine_risk_id, criterion_id, "
          "position) VALUES (1, 'sample-criterion-a', 0)",
    ]);
    addTearDown(db.close);
    final repository = DriftRoutineRepository(
      db,
      catalogue: FakeDbCatalogueRepository(),
      daCatalogue: FakeDaCatalogueRepository(),
      presetLevels: figLevels,
    );

    expect(await repository.fetchRoutine('s1'), isNull);
    // The other routine is kept, and no orphan rows remain.
    expect(await repository.fetchRoutine('r1'), isNotNull);
    for (final table in [
      'routine_body_elements',
      'routine_risks',
      'routine_risk_criteria',
    ]) {
      final rows = await db
          .customSelect(
            "SELECT COUNT(*) AS n FROM $table WHERE "
            "${table == 'routine_risk_criteria' ? 'routine_risk_id = 1' : "routine_id = 's1'"}",
          )
          .getSingle();
      expect(rows.read<int>('n'), 0, reason: table);
    }
  });
}
