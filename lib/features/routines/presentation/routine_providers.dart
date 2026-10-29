import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../da_calculator/presentation/da_calculator_providers.dart';
import '../../db_calculator/presentation/db_calculator_providers.dart';
import '../../levels/presentation/level_providers.dart';
import '../data/drift_routine_repository.dart';
import '../data/routine_repository.dart';

// Wiring for the routines feature. Widget tests override
// `routineRepositoryProvider` with an in-memory fake.

final routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => DriftRoutineRepository(
    ref.watch(appDatabaseProvider),
    catalogue: ref.watch(dbCatalogueRepositoryProvider),
    daCatalogue: ref.watch(daCatalogueRepositoryProvider),
    presetLevels: ref.watch(presetLevelsProvider),
  ),
);

/// Live list for the "My routines" screen; updates on every save/delete.
final routineSummariesProvider = StreamProvider<List<RoutineSummary>>(
  (ref) => ref.watch(routineRepositoryProvider).watchRoutineSummaries(),
  retry: (_, _) => null,
);
