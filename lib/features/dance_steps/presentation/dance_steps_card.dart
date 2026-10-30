import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../levels/presentation/count_limit_notice.dart';
import '../../routines/presentation/routine_controller.dart';

/// The routine's number of dance steps combinations (S), with a −/+
/// stepper and a notice comparing it with the level's minimum.
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
    final min = ref.watch(
      routineRequirementsProvider(routineId).select((r) => r?.minDanceSteps),
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
                child: _DanceStepsNotice(count: count, min: min),
              ),
          ],
        ),
      ),
    );
  }
}

class _DanceStepsNotice extends StatelessWidget {
  const _DanceStepsNotice({required this.count, required this.min});

  final int count;
  final int min;

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
    return LevelNotice(
      key: const ValueKey('dance-steps-notice'),
      icon: Icons.warning_amber_rounded,
      background: colors.errorContainer,
      foreground: colors.onErrorContainer,
      message:
          '$count S · ${min - count} more needed (at least $min): '
          'you may get a penalty.',
    );
  }
}
