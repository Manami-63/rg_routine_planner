import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/scoring/apparatus.dart';
import '../../music/presentation/music_providers.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/routine_timeline.dart';
import 'play_mode_screen.dart';
import 'timeline_editing.dart';

/// Shown below the music player: buttons that mark the next DB, R, DA or S
/// at the music's position, and the marked items by time with −/+ nudges
/// and a button to open Play mode.
class TimelineSection extends ConsumerWidget {
  const TimelineSection({super.key, required this.routineId});

  /// How far −/+ move a time.
  static const nudge = Duration(milliseconds: 100);

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routine = ref.watch(routineProvider(routineId));
    final controller = ref.read(routineControllerProvider(routineId).notifier);
    final player = ref.watch(musicPlayerProvider(routineId));
    final entries = routine.timelineEntries;
    final theme = Theme.of(context);

    // Freehand routines have no risks or DA to mark.
    final kinds = routine.apparatus == Apparatus.freehand
        ? const [TimelineKind.db, TimelineKind.danceStep]
        : TimelineKind.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text('Mark times', style: theme.textTheme.titleMedium),
        Text(
          'Play the music and tap when each one starts.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final kind in kinds)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _MarkButton(
                    kind: kind,
                    times: routine.timesOf(kind),
                    onPressed: () => controller.markNext(kind, player.position),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text('Timeline', style: theme.textTheme.titleMedium),
            ),
            if (entries.isNotEmpty)
              TextButton(
                onPressed: () => _confirmClear(context, controller),
                child: const Text('Clear all'),
              ),
          ],
        ),
        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: FilledButton.icon(
              onPressed: () =>
                  PlayModeScreen.show(context, routineId: routineId),
              icon: const Icon(Icons.slideshow),
              label: const Text('Play mode'),
            ),
          ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Nothing marked yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final entry in entries)
            _TimelineRow(
              key: ValueKey('timeline-${entry.kind.name}-${entry.index}'),
              entry: entry,
              onTap: () => player.seek(entry.time),
              onNudge: (offset) => controller.setTime(
                entry.kind,
                entry.index,
                entry.time + offset,
              ),
              onClear: () => controller.setTime(entry.kind, entry.index, null),
            ),
      ],
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    RoutineController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all times?'),
        content: const Text(
          'The DB, risks, DA and S stay in the routine, in their current '
          'order.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) controller.clearTimes();
  }
}

/// "Next DB" with how many are marked, e.g. "2 of 5". Disabled when all
/// are marked or there are none.
class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.kind,
    required this.times,
    required this.onPressed,
  });

  final TimelineKind kind;
  final List<Duration?> times;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final marked = times.where((time) => time != null).length;
    final done = marked == times.length;
    return FilledButton.tonal(
      key: ValueKey('mark-${kind.name}'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: done ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Next ${kind.label}'),
          Text(
            times.isEmpty ? 'none' : '$marked of ${times.length}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onNudge,
    required this.onClear,
  });

  final TimelineEntry entry;
  final VoidCallback onTap;
  final ValueChanged<Duration> onNudge;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = '${entry.kind.label} ${entry.index + 1}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Text(
        formatTimelineTime(entry.time),
        style: theme.textTheme.titleSmall?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      title: Text(item),
      subtitle: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Move $item earlier',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
            onPressed: entry.time == Duration.zero
                ? null
                : () => onNudge(-TimelineSection.nudge),
          ),
          IconButton(
            tooltip: 'Move $item later',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add),
            onPressed: () => onNudge(TimelineSection.nudge),
          ),
          IconButton(
            tooltip: 'Clear the time of $item',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

/// e.g. "1:05.3": minutes, seconds and tenths.
String formatTimelineTime(Duration time) {
  final tenths = time.inMilliseconds ~/ 100;
  final seconds = tenths ~/ 10;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'
      '.${tenths % 10}';
}
