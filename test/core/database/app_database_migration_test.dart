import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/database/app_database.dart';
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

  test('upgraded databases can save DA and notes', () async {
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
        .withNotes('New music');

    await repository.saveRoutine(withDa);

    expect(await repository.fetchRoutine('r1'), withDa);
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
