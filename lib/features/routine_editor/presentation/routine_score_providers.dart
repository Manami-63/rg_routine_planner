import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../da_calculator/presentation/da_calculator_providers.dart';
import '../../db_calculator/presentation/db_calculator_providers.dart';
import '../../routines/presentation/routine_providers.dart';
import '../domain/routine_score.dart';

/// The score of a saved routine for My routines, keyed by its id and
/// `updatedAt` so it is recalculated after every change. `null` when the
/// routine is gone or uses a ruleset this version of the app does not have.
final savedRoutineScoreProvider = FutureProvider.autoDispose
    .family<RoutineScore?, (String, DateTime)>((ref, key) async {
      final dbEngine = ref.watch(dbScoringEngineProvider);
      final daEngine = ref.watch(daScoringEngineProvider);
      final routine = await ref
          .watch(routineRepositoryProvider)
          .fetchRoutine(key.$1);
      if (routine == null ||
          routine.rulesetId != dbEngine.ruleset.id ||
          routine.rulesetId != daEngine.ruleset.id) {
        return null;
      }
      return RoutineScore.of(routine, dbEngine: dbEngine, daEngine: daEngine);
    });
