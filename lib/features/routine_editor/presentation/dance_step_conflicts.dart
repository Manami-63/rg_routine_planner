import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dance_steps/domain/dance_step_checks.dart';
import '../../db_calculator/presentation/db_routine_providers.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/routine_timeline.dart';

/// For each timeline item marked during an S that it may not include
/// (#5.2.5), the position of that S.
///
/// Read in a widget's build rather than through a provider combining the
/// routine and its DB results (see `RoutineTotalBar`).
Map<(TimelineKind, int), int> watchDanceStepConflicts(
  WidgetRef ref,
  String routineId,
) {
  final conflicts = danceStepConflicts(
    ref.watch(routineProvider(routineId)),
    dbValues: ref.watch(
      dbScoreResultProvider(routineId).select((r) => r.elementValues),
    ),
  );
  return {
    for (final conflict in conflicts)
      (_kindOf(conflict.kind), conflict.index): conflict.danceStepIndex,
  };
}

TimelineKind _kindOf(DanceStepConflictKind kind) => switch (kind) {
  DanceStepConflictKind.risk => TimelineKind.risk,
  DanceStepConflictKind.da => TimelineKind.da,
  DanceStepConflictKind.db => TimelineKind.db,
};

/// e.g. "Not allowed during S 1".
String danceStepConflictText(int danceStepIndex) =>
    'Not allowed during S ${danceStepIndex + 1}';
