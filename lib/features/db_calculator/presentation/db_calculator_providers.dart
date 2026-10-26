import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db_element_repository.dart';
import '../data/sample_db_element_repository.dart';
import '../domain/db_element.dart';
import '../domain/db_routine.dart';
import '../domain/db_scoring_engine.dart';

// This file is the feature's wiring: the only place that decides which
// concrete repository and engine are used. Tests override
// `dbElementRepositoryProvider` to supply their own data.

final dbElementRepositoryProvider = Provider<DbElementRepository>(
  (ref) => const SampleDbElementRepository(),
);

/// The engine always matches the repository's ruleset, so catalogue values
/// and calculation rules cannot drift apart.
final dbScoringEngineProvider = Provider<DbScoringEngine>(
  (ref) => ProvisionalDbScoringEngine(
    ruleset: ref.watch(dbElementRepositoryProvider).ruleset,
  ),
);

final dbCatalogueProvider = FutureProvider<List<DbElement>>(
  (ref) => ref.watch(dbElementRepositoryProvider).fetchElements(),
  // Local data will not fix itself on a retry; the user can retry manually.
  retry: (_, _) => null,
);

final dbRoutineControllerProvider =
    NotifierProvider<DbRoutineController, DbRoutine>(DbRoutineController.new);

/// Derived state: recalculated automatically whenever the routine changes.
final dbScoreResultProvider = Provider<DbScoreResult>(
  (ref) => ref
      .watch(dbScoringEngineProvider)
      .calculate(ref.watch(dbRoutineControllerProvider)),
);

/// Holds the routine being edited. In-memory for now; a later milestone can
/// load the initial state from, and save changes to, a routine repository.
class DbRoutineController extends Notifier<DbRoutine> {
  @override
  DbRoutine build() => DbRoutine(
    name: '',
    rulesetId: ref.watch(dbScoringEngineProvider).ruleset.id,
  );

  void rename(String name) => state = state.rename(name);

  void add(DbElement element) => state = state.withElementAdded(element);

  void removeAt(int index) => state = state.withElementRemovedAt(index);

  void clear() => state = state.cleared();
}
