import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/floor/floor_cell.dart';
import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/score.dart';
import '../../da_calculator/data/da_catalogue_repository.dart';
import '../../da_calculator/domain/da_base.dart';
import '../../da_calculator/domain/da_criterion.dart';
import '../../da_calculator/domain/da_element.dart';
import '../../da_calculator/domain/da_routine.dart';
import '../../db_calculator/data/db_catalogue_repository.dart';
import '../../db_calculator/domain/db_element.dart';
import '../../db_calculator/domain/db_element_options.dart';
import '../../db_calculator/domain/db_routine.dart';
import '../../db_calculator/domain/risk.dart';
import '../../levels/domain/competition_level.dart';
import '../../levels/domain/count_limit.dart';
import '../../music/domain/routine_music.dart';
import '../domain/routine.dart';
import 'routine_repository.dart';

/// [RoutineRepository] backed by the local SQLite database.
///
/// Saved rows hold catalogue ids. On load they are resolved against the
/// current [catalogue], [daCatalogue] and [presetLevels]; ids that no
/// longer exist become "unknown" placeholders, which keep their id so
/// re-saving loses nothing.
class DriftRoutineRepository implements RoutineRepository {
  DriftRoutineRepository(
    this._db, {
    required this.catalogue,
    required this.daCatalogue,
    required this.presetLevels,
  });

  final AppDatabase _db;
  final DbCatalogueRepository catalogue;
  final DaCatalogueRepository daCatalogue;
  final List<CompetitionLevel> presetLevels;

  @override
  Stream<List<RoutineSummary>> watchRoutineSummaries() {
    final query = _db.customSelect(
      'SELECT r.*, '
      '(SELECT COUNT(*) FROM routine_body_elements e '
      'WHERE e.routine_id = r.id) AS element_count, '
      '(SELECT COUNT(*) FROM routine_risks k '
      'WHERE k.routine_id = r.id) AS risk_count, '
      '(SELECT COUNT(*) FROM routine_apparatus_difficulties a '
      'WHERE a.routine_id = r.id) AS da_count '
      'FROM routines r ORDER BY r.updated_at DESC',
      readsFrom: {
        _db.routines,
        _db.routineBodyElements,
        _db.routineRisks,
        _db.routineApparatusDifficulties,
      },
    );
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          _toSummary(
            _db.routines.map(row.data),
            elementCount: row.read<int>('element_count'),
            riskCount: row.read<int>('risk_count'),
            daCount: row.read<int>('da_count'),
          ),
      ],
    );
  }

  RoutineSummary _toSummary(
    RoutineRow row, {
    required int elementCount,
    required int riskCount,
    required int daCount,
  }) => RoutineSummary(
    id: row.id,
    name: row.name,
    apparatus: Apparatus.fromName(row.apparatus),
    level: _resolveLevel(row),
    elementCount: elementCount,
    riskCount: riskCount,
    daCount: daCount,
    updatedAt: row.updatedAt,
    notes: row.notes,
  );

  @override
  Future<Routine?> fetchRoutine(String id) async {
    final row = await (_db.select(
      _db.routines,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;

    final elementRows =
        await (_db.select(_db.routineBodyElements)
              ..where((t) => t.routineId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final riskRows =
        await (_db.select(_db.routineRisks)
              ..where((t) => t.routineId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final criterionRows =
        await (_db.select(_db.routineRiskCriteria)
              ..where((t) => t.routineRiskId.isIn(riskRows.map((r) => r.id)))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();

    final daRows =
        await (_db.select(_db.routineApparatusDifficulties)
              ..where((t) => t.routineId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final danceStepRows =
        await (_db.select(_db.routineDanceSteps)
              ..where((t) => t.routineId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();

    // Catalogue values only apply to routines planned under its ruleset.
    final sameRuleset = row.rulesetId == catalogue.ruleset.id;
    final elements = {
      if (sameRuleset)
        for (final e in await catalogue.fetchElements()) e.id: e,
    };
    final riskCatalogue = sameRuleset
        ? await catalogue.fetchRiskCatalogue()
        : null;
    final rotations = {
      for (final o in riskCatalogue?.rotationOptions ?? <RiskRotationOption>[])
        o.id: o,
    };
    final criteria = {
      for (final c in riskCatalogue?.criteria ?? <RiskCriterion>[]) c.id: c,
    };
    final bases = {
      if (row.rulesetId == daCatalogue.ruleset.id)
        for (final b in await daCatalogue.fetchBases()) b.id: b,
    };
    DaBase base(String id) =>
        bases[id] ?? DaBase.unknown(id: id, rulesetId: row.rulesetId);

    return Routine(
      id: row.id,
      name: row.name,
      apparatus: Apparatus.fromName(row.apparatus),
      level: _resolveLevel(row),
      notes: row.notes,
      danceStepTimes: [for (final s in danceStepRows) _time(s.timeMs)],
      danceStepCells: [
        for (final s in danceStepRows) FloorCell.fromNumber(s.floorCell),
      ],
      music: row.musicFileName == null
          ? null
          : RoutineMusic(
              fileName: row.musicFileName!,
              title: row.musicTitle ?? row.musicFileName!,
            ),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      db: DbRoutine(
        rulesetId: row.rulesetId,
        elements: [
          for (final e in elementRows)
            if (e.elementId == DbElement.customId)
              DbElement.custom(
                name: e.customName ?? '',
                group: _parseGroup(e.customGroup),
                rulesetId: row.rulesetId,
              )
            else
              elements[e.elementId] ??
                  DbElement.unknown(id: e.elementId, rulesetId: row.rulesetId),
        ],
        elementOptions: [
          for (final e in elementRows)
            DbElementOptions(
              flatFoot: e.flatFoot,
              slowTurn: e.slowTurn,
              extraRotations: e.extraRotations,
              seriesCount: e.seriesCount,
              manualValue: switch (e.manualValue) {
                final hundredths? => Score.hundredths(hundredths),
                null => null,
              },
            ),
        ],
        elementTimes: [for (final e in elementRows) _time(e.timeMs)],
        elementCells: [
          for (final e in elementRows) FloorCell.fromNumber(e.floorCell),
        ],
        risks: [
          for (final r in riskRows)
            RiskElement(
              rotation:
                  rotations[r.rotationOptionId] ??
                  RiskRotationOption.unknown(
                    id: r.rotationOptionId,
                    rulesetId: row.rulesetId,
                  ),
              criteria: [
                for (final c in criterionRows.where(
                  (c) => c.routineRiskId == r.id,
                ))
                  criteria[c.criterionId] ??
                      RiskCriterion.unknown(
                        id: c.criterionId,
                        rulesetId: row.rulesetId,
                      ),
              ],
            ),
        ],
        riskTimes: [for (final r in riskRows) _time(r.timeMs)],
        riskCells: [
          for (final r in riskRows) FloorCell.fromNumber(r.floorCell),
        ],
      ),
      da: DaRoutine(
        rulesetId: row.rulesetId,
        elements: [
          for (final a in daRows)
            DaElement(
              base: a.baseId == DaBase.customId
                  ? DaBase.custom(
                      name: a.customName ?? '',
                      rulesetId: row.rulesetId,
                    )
                  : base(a.baseId),
              secondBase: switch (a.secondBaseId) {
                final id? => base(id),
                null => null,
              },
              criteria: DaCriterion.parseAll(a.criteria),
              preAcrobatic: a.preAcrobatic,
              manualValue: switch (a.manualValue) {
                final hundredths? => Score.hundredths(hundredths),
                null => null,
              },
            ),
        ],
        times: [for (final a in daRows) _time(a.timeMs)],
        cells: [for (final a in daRows) FloorCell.fromNumber(a.floorCell)],
      ),
    );
  }

  static Duration? _time(int? ms) =>
      ms == null ? null : Duration(milliseconds: ms);

  CompetitionLevel? _resolveLevel(RoutineRow row) {
    final levelId = row.levelId;
    if (levelId == null) return null;
    if (levelId == CompetitionLevel.customId) {
      return CompetitionLevel.custom(
        LevelRequirements(
          db: CountLimit(min: row.customDbMin, max: row.customDbMax),
          risk: CountLimit(min: row.customRiskMin, max: row.customRiskMax),
          da: CountLimit(min: row.customDaMin, max: row.customDaMax),
          requiredBodyGroups: _parseGroups(row.customRequiredBodyGroups),
          minDanceSteps: row.customDanceStepsMin,
        ),
      );
    }
    for (final level in presetLevels) {
      if (level.id == levelId) return level;
    }
    // A preset that no longer exists: keep the id so it is not lost.
    return CompetitionLevel(id: levelId, label: 'Unknown level', isFig: false);
  }

  static DbElementGroup _parseGroup(String? name) => DbElementGroup.values
      .firstWhere((g) => g.name == name, orElse: () => DbElementGroup.unknown);

  static Set<DbElementGroup> _parseGroups(String? text) => {
    for (final name in (text ?? '').split(','))
      for (final group in DbElementGroup.requirable)
        if (group.name == name) group,
  };

  static String? _formatGroups(Set<DbElementGroup> groups) => groups.isEmpty
      ? null
      : [
          for (final group in DbElementGroup.requirable)
            if (groups.contains(group)) group.name,
        ].join(',');

  @override
  Future<void> saveRoutine(Routine routine) => _db.transaction(() async {
    final level = routine.level;
    final custom = (level?.isCustom ?? false) ? level!.requirements : null;

    await _db
        .into(_db.routines)
        .insertOnConflictUpdate(
          RoutinesCompanion.insert(
            id: routine.id,
            name: routine.name,
            rulesetId: routine.rulesetId,
            apparatus: Value(routine.apparatus?.name),
            levelId: Value(level?.id),
            customDbMin: Value(custom?.db.min),
            customDbMax: Value(custom?.db.max),
            customRiskMin: Value(custom?.risk.min),
            customRiskMax: Value(custom?.risk.max),
            customDaMin: Value(custom?.da.min),
            customDaMax: Value(custom?.da.max),
            customRequiredBodyGroups: Value(
              custom == null ? null : _formatGroups(custom.requiredBodyGroups),
            ),
            customDanceStepsMin: Value(custom?.minDanceSteps),
            notes: Value(routine.notes),
            musicFileName: Value(routine.music?.fileName),
            musicTitle: Value(routine.music?.title),
            // Always stored in UTC (shown in local time by the UI), so data
            // from devices in different time zones sorts and syncs cleanly.
            createdAt: routine.createdAt.toUtc(),
            updatedAt: routine.updatedAt.toUtc(),
          ),
        );

    // Replace the children wholesale; routines are small, and this keeps
    // positions consistent. Deleting risks cascades to their criteria.
    await (_db.delete(
      _db.routineApparatusDifficulties,
    )..where((t) => t.routineId.equals(routine.id))).go();
    await (_db.delete(
      _db.routineBodyElements,
    )..where((t) => t.routineId.equals(routine.id))).go();
    await (_db.delete(
      _db.routineRisks,
    )..where((t) => t.routineId.equals(routine.id))).go();
    await (_db.delete(
      _db.routineDanceSteps,
    )..where((t) => t.routineId.equals(routine.id))).go();

    await _db.batch((batch) {
      batch.insertAll(_db.routineBodyElements, [
        for (final (i, element) in routine.db.elements.indexed)
          _elementRow(
            routine.id,
            i,
            element,
            routine.db.elementOptions[i],
            routine.db.elementTimes[i],
            routine.db.elementCells[i],
          ),
      ]);
      batch.insertAll(_db.routineApparatusDifficulties, [
        for (final (i, element) in routine.da.elements.indexed)
          _daRow(
            routine.id,
            i,
            element,
            routine.da.times[i],
            routine.da.cells[i],
          ),
      ]);
      batch.insertAll(_db.routineDanceSteps, [
        for (final (i, time) in routine.danceStepTimes.indexed)
          RoutineDanceStepsCompanion.insert(
            routineId: routine.id,
            position: i,
            timeMs: Value(time?.inMilliseconds),
            floorCell: Value(routine.danceStepCells[i]?.number),
          ),
      ]);
    });

    for (final (i, risk) in routine.db.risks.indexed) {
      final riskId = await _db
          .into(_db.routineRisks)
          .insert(
            RoutineRisksCompanion.insert(
              routineId: routine.id,
              rotationOptionId: risk.rotation.id,
              position: i,
              timeMs: Value(routine.db.riskTimes[i]?.inMilliseconds),
              floorCell: Value(routine.db.riskCells[i]?.number),
            ),
          );
      await _db.batch((batch) {
        batch.insertAll(_db.routineRiskCriteria, [
          for (final (j, criterion) in risk.criteria.indexed)
            RoutineRiskCriteriaCompanion.insert(
              routineRiskId: riskId,
              criterionId: criterion.id,
              position: j,
            ),
        ]);
      });
    }
  });

  static RoutineBodyElementsCompanion _elementRow(
    String routineId,
    int position,
    DbElement element,
    DbElementOptions options,
    Duration? time,
    FloorCell? cell,
  ) => RoutineBodyElementsCompanion.insert(
    routineId: routineId,
    elementId: element.id,
    position: position,
    flatFoot: Value(options.flatFoot),
    slowTurn: Value(options.slowTurn),
    extraRotations: Value(options.extraRotations),
    seriesCount: Value(options.seriesCount),
    manualValue: Value(options.manualValue?.hundredths),
    customName: Value(element.isCustom ? element.name : null),
    customGroup: Value(element.isCustom ? element.group.name : null),
    timeMs: Value(time?.inMilliseconds),
    floorCell: Value(cell?.number),
  );

  static RoutineApparatusDifficultiesCompanion _daRow(
    String routineId,
    int position,
    DaElement element,
    Duration? time,
    FloorCell? cell,
  ) => RoutineApparatusDifficultiesCompanion.insert(
    routineId: routineId,
    position: position,
    baseId: element.base.id,
    secondBaseId: Value(element.secondBase?.id),
    criteria: Value(DaCriterion.formatAll(element.criteria)),
    preAcrobatic: Value(element.preAcrobatic),
    manualValue: Value(element.manualValue?.hundredths),
    customName: Value(element.isCustom ? element.base.name : null),
    timeMs: Value(time?.inMilliseconds),
    floorCell: Value(cell?.number),
  );

  @override
  Future<void> deleteRoutine(String id) =>
      (_db.delete(_db.routines)..where((t) => t.id.equals(id))).go();
}
