import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/database/app_database.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_base.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_criterion.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_element.dart';
import 'package:rg_routine_planner/features/da_calculator/domain/da_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element_options.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_routine.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';
import 'package:rg_routine_planner/features/routines/data/drift_routine_repository.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

import '../../da_calculator/test_data.dart';
import '../../db_calculator/test_data.dart';

void main() {
  late AppDatabase db;
  late DriftRoutineRepository repository;
  final created = DateTime.utc(2026, 10, 26, 9, 0, 0, 123);

  setUp(() {
    // Each test gets a fresh in-memory SQLite database.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftRoutineRepository(
      db,
      catalogue: FakeDbCatalogueRepository(),
      daCatalogue: FakeDaCatalogueRepository(),
      presetLevels: figLevels,
    );
  });

  tearDown(() => db.close());

  Routine routine({
    String id = 'r1',
    String name = 'Hoop',
    Apparatus? apparatus,
    CompetitionLevel? level,
    List<DbElement> elements = const [],
    List<RiskElement> risks = const [],
    List<DaElement> das = const [],
    DateTime? updatedAt,
  }) => Routine(
    id: id,
    name: name,
    apparatus: apparatus,
    level: level,
    db: DbRoutine(rulesetId: 'test-v1', elements: elements, risks: risks),
    da: DaRoutine(rulesetId: 'test-v1', elements: das),
    createdAt: created,
    updatedAt: updatedAt ?? created,
  );

  test('returns null for a missing routine', () async {
    expect(await repository.fetchRoutine('missing'), isNull);
  });

  test('round-trips a full routine', () async {
    final original = routine(
      apparatus: Apparatus.ribbon,
      level: figSenior,
      elements: const [testJump, testBalance, testJump],
      risks: [
        RiskElement(
          rotation: testThreeRotations,
          criteria: const [testCriterionA, testCriterionB],
        ),
        RiskElement(rotation: testTwoRotations),
      ],
    );

    await repository.saveRoutine(original);

    expect(await repository.fetchRoutine('r1'), original);
  });

  test('round-trips notes, including line breaks', () async {
    final original = routine().withNotes('Music: Bolero\nStart facing judges');

    await repository.saveRoutine(original);

    expect((await repository.fetchRoutine('r1'))!.notes, original.notes);
  });

  test('round-trips element options and custom elements', () async {
    const custom = DbElement.custom(
      name: 'New pivot',
      group: DbElementGroup.rotation,
      rulesetId: 'test-v1',
    );
    final original = Routine(
      id: 'r1',
      name: 'Options',
      db: DbRoutine(
        rulesetId: 'test-v1',
        elements: const [testBalance, testRotation, testJump, custom],
        elementOptions: const [
          DbElementOptions(flatFoot: true, slowTurn: true),
          DbElementOptions(extraRotations: 2),
          DbElementOptions(manualValue: Score.hundredths(45), seriesCount: 2),
          DbElementOptions(manualValue: Score.hundredths(60)),
        ],
      ),
      createdAt: created,
      updatedAt: created,
    );

    await repository.saveRoutine(original);

    expect(await repository.fetchRoutine('r1'), original);
  });

  test('round-trips DA in order, with all their details', () async {
    final original = routine(
      apparatus: Apparatus.hoop,
      das: [
        DaElement(
          base: testRoll,
          criteria: const {DaCriterion.outsideVisualField, DaCriterion.db},
        ),
        DaElement(
          base: testCatch,
          secondBase: testRoll,
          criteria: const {DaCriterion.rotation},
          preAcrobatic: true,
        ),
        DaElement(base: testThrow, manualValue: const Score.hundredths(50)),
        DaElement(
          base: const DaBase.custom(name: 'National DA', rulesetId: 'test-v1'),
          manualValue: const Score.hundredths(10),
        ),
      ],
    );

    await repository.saveRoutine(original);

    expect(await repository.fetchRoutine('r1'), original);
    final rows = await db.select(db.routineApparatusDifficulties).get();
    expect(rows.first.baseId, 'hoop-roll');
    expect(rows.first.criteria, 'outsideVisualField,db');
  });

  test('unknown DA bases load as unknown and survive a re-save', () async {
    await repository.saveRoutine(
      routine(
        das: [
          DaElement(
            base: const DaBase.unknown(id: 'removed', rulesetId: 'test-v1'),
          ),
        ],
      ),
    );

    final loaded = await repository.fetchRoutine('r1');
    expect(loaded!.da.elements.single.base.isUnknown, isTrue);

    await repository.saveRoutine(loaded);
    final rows = await db.select(db.routineApparatusDifficulties).get();
    expect(rows.single.baseId, 'removed');
  });

  test('keeps millisecond timestamps in UTC', () async {
    await repository.saveRoutine(routine());

    final loaded = await repository.fetchRoutine('r1');
    expect(loaded!.createdAt.isAtSameMomentAs(created), isTrue);
    expect(loaded.createdAt.millisecond, 123);
  });

  test('stores times as UTC even when given local times', () async {
    // 9:00 at UTC+11 (e.g. Sydney summer) is 22:00 UTC the previous day.
    final local = DateTime.parse('2026-10-27T09:00:00+11:00').toLocal();
    await repository.saveRoutine(routine().withUpdatedAt(local));

    final raw = await db
        .customSelect('SELECT updated_at FROM routines')
        .getSingle();
    expect(raw.read<String>('updated_at'), '2026-10-26T22:00:00.000Z');

    final loaded = await repository.fetchRoutine('r1');
    expect(loaded!.updatedAt.isUtc, isTrue);
    expect(loaded.updatedAt.isAtSameMomentAs(local), isTrue);
  });

  test('round-trips a custom level', () async {
    const custom = CompetitionLevel.custom(
      LevelRequirements(
        db: CountLimit(min: 1, max: 4),
        risk: CountLimit(min: 1, max: 2),
        da: CountLimit(max: 3),
        requiredBodyGroups: {DbElementGroup.rotation, DbElementGroup.jump},
      ),
    );

    await repository.saveRoutine(routine(level: custom));

    expect((await repository.fetchRoutine('r1'))!.level, custom);
  });

  test('saving again replaces content instead of appending', () async {
    await repository.saveRoutine(
      routine(
        elements: const [testJump, testBalance],
        risks: [
          RiskElement(rotation: testTwoRotations, criteria: [testCriterionA]),
        ],
      ),
    );
    final updated = routine(
      name: 'Renamed',
      elements: const [testRotation],
      risks: [RiskElement(rotation: testThreeRotations)],
    );

    await repository.saveRoutine(updated);

    expect(await repository.fetchRoutine('r1'), updated);
    expect(await db.select(db.routineRiskCriteria).get(), isEmpty);
  });

  test('deleting removes the routine and all its rows', () async {
    await repository.saveRoutine(
      routine(
        elements: const [testJump],
        risks: [
          RiskElement(rotation: testTwoRotations, criteria: [testCriterionA]),
        ],
        das: [DaElement(base: testThrow)],
      ),
    );

    await repository.deleteRoutine('r1');

    expect(await repository.fetchRoutine('r1'), isNull);
    expect(await db.select(db.routineBodyElements).get(), isEmpty);
    expect(await db.select(db.routineRisks).get(), isEmpty);
    expect(await db.select(db.routineRiskCriteria).get(), isEmpty);
    expect(await db.select(db.routineApparatusDifficulties).get(), isEmpty);
  });

  test('stores catalogue ids, not values', () async {
    await repository.saveRoutine(routine(elements: const [testJump]));

    final rows = await db.select(db.routineBodyElements).get();
    expect(rows.single.elementId, 'jump');
  });

  test(
    'ids missing from the catalogue load as unknown and survive a re-save',
    () async {
      // Simulate a catalogue change by writing ids it does not contain.
      await repository.saveRoutine(
        routine(
          elements: const [
            DbElement.unknown(id: 'removed-element', rulesetId: 'test-v1'),
          ],
          risks: [
            RiskElement(
              rotation: const RiskRotationOption.unknown(
                id: 'removed-rotation',
                rulesetId: 'test-v1',
              ),
              criteria: const [
                RiskCriterion.unknown(
                  id: 'removed-criterion',
                  rulesetId: 'test-v1',
                ),
              ],
            ),
          ],
        ),
      );

      final loaded = await repository.fetchRoutine('r1');
      expect(loaded!.db.elements.single.isUnknown, isTrue);
      expect(loaded.db.risks.single.rotation.isUnknown, isTrue);
      expect(loaded.db.risks.single.criteria.single.isUnknown, isTrue);

      await repository.saveRoutine(loaded);
      final rows = await db.select(db.routineBodyElements).get();
      expect(rows.single.elementId, 'removed-element');
    },
  );

  test('a routine from another ruleset loads with unknown elements', () async {
    await repository.saveRoutine(
      Routine(
        id: 'old',
        name: 'Old',
        db: DbRoutine(
          rulesetId: 'old-ruleset',
          elements: const [
            DbElement.unknown(id: 'jump', rulesetId: 'old-ruleset'),
          ],
        ),
        createdAt: created,
        updatedAt: created,
      ),
    );

    final loaded = await repository.fetchRoutine('old');
    // Same id as a current element, but values from another ruleset must
    // not be mixed in.
    expect(loaded!.db.elements.single.isUnknown, isTrue);
    expect(loaded.rulesetId, 'old-ruleset');
  });

  test('unknown apparatus loads as none', () async {
    await repository.saveRoutine(routine());
    await db.customStatement("UPDATE routines SET apparatus = 'trampoline'");

    expect((await repository.fetchRoutine('r1'))!.apparatus, isNull);
  });

  test('unknown preset level id is kept', () async {
    await repository.saveRoutine(
      routine(
        level: const CompetitionLevel(
          id: 'retired-level',
          label: 'Retired',
          isFig: true,
        ),
      ),
    );

    final level = (await repository.fetchRoutine('r1'))!.level;
    expect(level!.id, 'retired-level');
    expect(level.label, 'Unknown level');
  });

  test('summaries list newest first with counts and level', () async {
    await repository.saveRoutine(
      routine(id: 'older', name: 'Older', elements: const [testJump]),
    );
    await repository.saveRoutine(
      routine(
        id: 'newer',
        name: 'Newer',
        apparatus: Apparatus.clubs,
        level: figJunior,
        elements: const [testJump, testBalance],
        risks: [RiskElement(rotation: testTwoRotations)],
        das: [
          DaElement(base: testThrow),
          DaElement(base: testRoll),
        ],
        updatedAt: created.add(const Duration(hours: 1)),
      ),
    );

    final summaries = await repository.watchRoutineSummaries().first;

    expect(summaries.map((s) => s.name), ['Newer', 'Older']);
    expect(summaries.first.elementCount, 2);
    expect(summaries.first.riskCount, 1);
    expect(summaries.first.daCount, 2);
    expect(summaries.first.level, figJunior);
    expect(summaries.first.apparatus, Apparatus.clubs);
    expect(summaries.last.elementCount, 1);
    expect(summaries.last.apparatus, isNull);
    expect(summaries.last.level, isNull);
  });

  test('summaries emit again after changes', () async {
    final emissions = repository.watchRoutineSummaries().map(
      (list) => list.length,
    );
    final expectation = expectLater(emissions, emitsInOrder([0, 1, 0]));

    await pumpEventQueue();
    await repository.saveRoutine(routine());
    await pumpEventQueue();
    await repository.deleteRoutine('r1');

    await expectation;
  });
}
