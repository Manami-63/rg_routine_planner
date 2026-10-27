import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/scoring/apparatus.dart';
import '../../db_calculator/data/db_catalogue_repository.dart';
import '../../db_calculator/domain/db_element.dart';
import '../../db_calculator/domain/db_routine.dart';
import '../../db_calculator/domain/risk.dart';
import '../../levels/domain/competition_level.dart';
import '../../levels/domain/count_limit.dart';
import '../domain/routine.dart';
import 'routine_repository.dart';

/// [RoutineRepository] backed by the local SQLite database.
///
/// Saved rows hold catalogue ids. On load they are resolved against the
/// current [catalogue] and [presetLevels]; ids that no longer exist become
/// "unknown" placeholders, which keep their id so re-saving loses nothing.
class DriftRoutineRepository implements RoutineRepository {
  DriftRoutineRepository(
    this._db, {
    required this.catalogue,
    required this.presetLevels,
  });

  final AppDatabase _db;
  final DbCatalogueRepository catalogue;
  final List<CompetitionLevel> presetLevels;

  @override
  Stream<List<RoutineSummary>> watchRoutineSummaries() {
    final query = _db.customSelect(
      'SELECT r.*, '
      '(SELECT COUNT(*) FROM routine_body_elements e '
      'WHERE e.routine_id = r.id) AS element_count, '
      '(SELECT COUNT(*) FROM routine_risks k '
      'WHERE k.routine_id = r.id) AS risk_count '
      'FROM routines r ORDER BY r.updated_at DESC',
      readsFrom: {_db.routines, _db.routineBodyElements, _db.routineRisks},
    );
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          _toSummary(
            _db.routines.map(row.data),
            elementCount: row.read<int>('element_count'),
            riskCount: row.read<int>('risk_count'),
          ),
      ],
    );
  }

  RoutineSummary _toSummary(
    RoutineRow row, {
    required int elementCount,
    required int riskCount,
  }) => RoutineSummary(
    id: row.id,
    name: row.name,
    apparatus: Apparatus.fromName(row.apparatus),
    level: _resolveLevel(row),
    elementCount: elementCount,
    riskCount: riskCount,
    updatedAt: row.updatedAt,
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

    return Routine(
      id: row.id,
      name: row.name,
      apparatus: Apparatus.fromName(row.apparatus),
      level: _resolveLevel(row),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      db: DbRoutine(
        rulesetId: row.rulesetId,
        elements: [
          for (final e in elementRows)
            elements[e.elementId] ??
                DbElement.unknown(id: e.elementId, rulesetId: row.rulesetId),
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
      ),
    );
  }

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
        ),
      );
    }
    for (final level in presetLevels) {
      if (level.id == levelId) return level;
    }
    // A preset that no longer exists: keep the id so it is not lost.
    return CompetitionLevel(id: levelId, label: 'Unknown level', isFig: false);
  }

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
            // Always stored in UTC (shown in local time by the UI), so data
            // from devices in different time zones sorts and syncs cleanly.
            createdAt: routine.createdAt.toUtc(),
            updatedAt: routine.updatedAt.toUtc(),
          ),
        );

    // Replace the children wholesale; routines are small, and this keeps
    // positions consistent. Deleting risks cascades to their criteria.
    await (_db.delete(
      _db.routineBodyElements,
    )..where((t) => t.routineId.equals(routine.id))).go();
    await (_db.delete(
      _db.routineRisks,
    )..where((t) => t.routineId.equals(routine.id))).go();

    await _db.batch((batch) {
      batch.insertAll(_db.routineBodyElements, [
        for (final (i, element) in routine.db.elements.indexed)
          RoutineBodyElementsCompanion.insert(
            routineId: routine.id,
            elementId: element.id,
            position: i,
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

  @override
  Future<void> deleteRoutine(String id) =>
      (_db.delete(_db.routines)..where((t) => t.id.equals(id))).go();
}
