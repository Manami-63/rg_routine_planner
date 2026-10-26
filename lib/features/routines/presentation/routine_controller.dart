import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../db_calculator/domain/db_routine.dart';
import '../../db_calculator/presentation/db_calculator_providers.dart';
import '../../levels/domain/competition_level.dart';
import '../domain/routine.dart';

/// The routine being edited.
///
/// Still in-memory: the next step loads it from, and saves it to,
/// `RoutineRepository` by id.
final routineControllerProvider = NotifierProvider<RoutineController, Routine>(
  RoutineController.new,
);

class RoutineController extends Notifier<Routine> {
  @override
  Routine build() => Routine.create(
    id: const Uuid().v4(),
    rulesetId: ref.watch(dbScoringEngineProvider).ruleset.id,
    now: DateTime.now(),
  );

  void rename(String name) => state = state.rename(name);

  void selectLevel(CompetitionLevel? level) => state = state.withLevel(level);

  /// Applies a change to the DB content. DB-specific helpers live in the
  /// DB calculator feature (see `DbRoutineEditing`).
  void updateDb(DbRoutine Function(DbRoutine db) change) =>
      state = state.withDb(change(state.db));
}
