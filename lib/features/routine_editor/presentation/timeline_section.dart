import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/floor/floor_cell.dart';
import '../../../core/scoring/apparatus.dart';
import '../../music/presentation/music_providers.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/routine_timeline.dart';
import 'dance_step_conflicts.dart';
import 'floor_mat.dart';
import 'floor_notices.dart';
import 'play_mode_screen.dart';
import 'timeline_editing.dart';

/// Shown below the music player: buttons that mark the next DB, R, DA or S
/// at the music's position (dragged onto the floor mat to also mark where),
/// the mat with use-of-space notices, and the marked items by time with
/// −/+ nudges and a button to open Play mode.
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
    final conflicts = watchDanceStepConflicts(ref, routineId);
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
          'Play the music and tap when each one starts. Drag onto the mat '
          'to also mark where.',
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
                    position: () => player.position,
                    onMark: (time) => controller.markNext(kind, time),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: FloorMat<_PendingMark>(
              entries: entries,
              onDrop: (mark, cell) =>
                  controller.markNext(mark.kind, mark.time, cell),
            ),
          ),
        ),
        FloorNotices(routine: routine),
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
              conflictWith: conflicts[(entry.kind, entry.index)],
              onTap: () => player.seek(entry.time),
              onNudge: (offset) => controller.setTime(
                entry.kind,
                entry.index,
                entry.time + offset,
              ),
              onClear: () => controller.setTime(entry.kind, entry.index, null),
              onPickCell: () async {
                final cell = await _pickCell(context, entry);
                if (cell == null) return;
                controller.setCell(entry.kind, entry.index, cell.cell);
              },
            ),
      ],
    );
  }

  /// Asks where [entry] starts. `null` when dismissed.
  Future<({FloorCell? cell})?> _pickCell(
    BuildContext context,
    TimelineEntry entry,
  ) => showModalBottomSheet<({FloorCell? cell})>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Where does ${entry.kind.label} ${entry.index + 1} start?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: FloorMat<Object>(
                  highlighted: entry.cell,
                  onTap: (cell) => Navigator.of(context).pop((cell: cell)),
                ),
              ),
            ),
            if (entry.cell != null)
              TextButton(
                onPressed: () => Navigator.of(context).pop((cell: null)),
                child: const Text('No location'),
              ),
          ],
        ),
      ),
    ),
  );

  Future<void> _confirmClear(
    BuildContext context,
    RoutineController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all times?'),
        content: const Text(
          'Times and floor locations are cleared. The DB, risks, DA and S '
          'stay in the routine, in their current order.',
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
/// The data of a "Next" button being dragged: what it marks, and the
/// music time when the finger went down.
class _PendingMark {
  _PendingMark(this.kind);

  final TimelineKind kind;
  Duration time = Duration.zero;
}

/// "Next DB" with how many are marked, e.g. "2 of 5". Tap to mark the time;
/// drag onto the floor mat to mark the time and where (dropped elsewhere,
/// only the time). Disabled when all are marked or there are none.
class _MarkButton extends StatefulWidget {
  const _MarkButton({
    required this.kind,
    required this.times,
    required this.position,
    required this.onMark,
  });

  final TimelineKind kind;
  final List<Duration?> times;

  /// The music position now.
  final Duration Function() position;

  /// Marks the time only.
  final ValueChanged<Duration> onMark;

  @override
  State<_MarkButton> createState() => _MarkButtonState();
}

class _MarkButtonState extends State<_MarkButton> {
  late final _mark = _PendingMark(widget.kind);

  @override
  Widget build(BuildContext context) {
    final marked = widget.times.where((time) => time != null).length;
    final done = marked == widget.times.length;
    final button = FilledButton.tonal(
      key: ValueKey('mark-${widget.kind.name}'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: done ? null : () => widget.onMark(_mark.time),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Next ${widget.kind.label}'),
          Text(
            widget.times.isEmpty ? 'none' : '$marked of ${widget.times.length}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
    if (done) return button;
    // The time is taken when the finger goes down, so a drag is as exact
    // as a tap.
    return Listener(
      onPointerDown: (_) => _mark.time = widget.position(),
      child: Draggable<_PendingMark>(
        data: _mark,
        onDraggableCanceled: (_, _) => widget.onMark(_mark.time),
        feedback: Material(
          color: Theme.of(context).colorScheme.primary,
          shape: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.kind.label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        child: button,
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    super.key,
    required this.entry,
    required this.conflictWith,
    required this.onTap,
    required this.onNudge,
    required this.onClear,
    required this.onPickCell,
  });

  final TimelineEntry entry;

  /// The S this item may not be performed during, or `null`.
  final int? conflictWith;
  final VoidCallback onTap;
  final ValueChanged<Duration> onNudge;
  final VoidCallback onClear;
  final VoidCallback onPickCell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = '${entry.kind.label} ${entry.index + 1}';
    final conflictWith = this.conflictWith;
    final error = theme.colorScheme.error;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Text(
        formatTimelineTime(entry.time),
        style: theme.textTheme.titleSmall?.copyWith(
          color: conflictWith == null ? null : error,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      title: Text(item),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (conflictWith != null)
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    danceStepConflictText(conflictWith),
                    style: TextStyle(color: error),
                  ),
                ),
              ],
            ),
        ],
      ),
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
            tooltip: 'Set where $item starts',
            visualDensity: VisualDensity.compact,
            icon: switch (entry.cell) {
              null => const Icon(Icons.grid_on),
              final cell => CircleAvatar(
                radius: 12,
                child: Text(
                  '${cell.number}',
                  key: ValueKey('cell-${entry.kind.name}-${entry.index}'),
                  style: theme.textTheme.labelMedium,
                ),
              ),
            },
            onPressed: onPickCell,
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
