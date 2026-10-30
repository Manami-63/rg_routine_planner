import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/scoring/score.dart';
import '../../db_calculator/presentation/db_routine_providers.dart';
import '../../levels/presentation/count_limit_notice.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/dance_step_checks.dart';

/// The routine's number of dance steps combinations (S), with a −/+
/// stepper, a notice comparing it with the level's minimum, and alerts for
/// items marked during an S that it may not include (#5.2.5).
///
/// S are only counted (no details) and are not difficulty, so they never
/// change the difficulty total. A missing one is only a reminder.
class DanceStepsCard extends ConsumerWidget {
  const DanceStepsCard({super.key, required this.routineId});

  static const maxCount = 20;

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      routineProvider(routineId).select((r) => r.danceStepCount),
    );
    final (min, penalty) = ref.watch(
      routineRequirementsProvider(routineId)
          .select((r) => (r?.minDanceSteps, r?.missingDanceStepPenalty)),
    );
    // Computed here rather than in a provider combining the routine and
    // its DB results (see `RoutineTotalBar`).
    final conflicts = danceStepConflicts(
      ref.watch(routineProvider(routineId)),
      dbValues: ref.watch(
        dbScoreResultProvider(routineId).select((r) => r.elementValues),
      ),
    );
    final controller = ref.read(routineControllerProvider(routineId).notifier);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Dance steps combinations (S)',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove a dance steps combination',
                  icon: const Icon(Icons.remove),
                  onPressed: count == 0
                      ? null
                      : () => controller.setDanceStepCount(count - 1),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '$count',
                    key: const ValueKey('dance-step-count'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Add a dance steps combination',
                  icon: const Icon(Icons.add),
                  onPressed: count >= maxCount
                      ? null
                      : () => controller.setDanceStepCount(count + 1),
                ),
              ],
            ),
            if (min != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
                child: _DanceStepsNotice(
                  count: count,
                  min: min,
                  penalty: penalty,
                ),
              ),
            for (final (s, items) in _byDanceStep(conflicts))
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
                child: _ConflictNotice(danceStepIndex: s, conflicts: items),
              ),
          ],
        ),
      ),
    );
  }

  /// The conflicts grouped by S, in S order.
  static List<(int, List<DanceStepConflict>)> _byDanceStep(
    List<DanceStepConflict> conflicts,
  ) {
    final groups = <int, List<DanceStepConflict>>{};
    for (final conflict in conflicts) {
      (groups[conflict.danceStepIndex] ??= []).add(conflict);
    }
    return [for (final MapEntry(:key, :value) in groups.entries) (key, value)];
  }
}

class _DanceStepsNotice extends StatelessWidget {
  const _DanceStepsNotice({
    required this.count,
    required this.min,
    required this.penalty,
  });

  final int count;
  final int min;

  /// The penalty for each missing S, when known.
  final Score? penalty;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (count >= min) {
      return LevelNotice(
        key: const ValueKey('dance-steps-notice'),
        icon: Icons.check_circle_outline,
        background: colors.primaryContainer,
        foreground: colors.onPrimaryContainer,
        message: '$count S · meets the level (at least $min)',
      );
    }
    // Missing S are an artistry fault, so like missing body groups only a
    // reminder: no penalty is calculated.
    final consequence = switch (penalty) {
      null => 'you may get a penalty',
      final penalty => 'you may get a ${penalty.format()} penalty for each',
    };
    return LevelNotice(
      key: const ValueKey('dance-steps-notice'),
      icon: Icons.warning_amber_rounded,
      background: colors.errorContainer,
      foreground: colors.onErrorContainer,
      message:
          '$count S · ${min - count} more needed (at least $min): '
          '$consequence.',
    );
  }
}

/// Items marked during one S that it may not include.
class _ConflictNotice extends StatelessWidget {
  const _ConflictNotice({
    required this.danceStepIndex,
    required this.conflicts,
  });

  final int danceStepIndex;
  final List<DanceStepConflict> conflicts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = conflicts.map((c) => c.itemLabel).join(', ');
    return LevelNotice(
      key: ValueKey('dance-step-conflict-$danceStepIndex'),
      icon: Icons.warning_amber_rounded,
      background: colors.errorContainer,
      foreground: colors.onErrorContainer,
      message:
          'S ${danceStepIndex + 1} may not be valid: $items '
          '${conflicts.length == 1 ? 'is' : 'are'} marked during it. Risks, '
          'DA and DB worth ${danceStepDbValueLimit.format()} or more are not '
          'allowed in an S (CoP #5.2.5).',
    );
  }
}
