import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/floor/floor_cell.dart';
import '../../../core/scoring/apparatus.dart';
import '../../da_calculator/domain/da_base.dart';
import '../../da_calculator/presentation/da_calculator_providers.dart';
import '../../da_calculator/presentation/widgets/da_builder_sheet.dart';
import '../../db_calculator/presentation/db_calculator_providers.dart';
import '../../db_calculator/presentation/element_picker_screen.dart';
import '../../db_calculator/presentation/widgets/risk_builder_sheet.dart';
import '../../music/presentation/music_player.dart';
import '../../music/presentation/music_providers.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/routine_timeline.dart';
import 'dance_step_conflicts.dart';
import 'floor_mat.dart';
import 'floor_notices.dart';
import 'play_mode_screen.dart';
import 'timeline_colours.dart';
import 'timeline_editing.dart';

/// Shown below the music player: buttons that mark the next DB, R, DA or S
/// at the music's position (dragged onto the floor mat to also mark where),
/// the mat with use-of-space notices, and the marked items by time with
/// −/+ nudges and a button to open Play mode.
///
/// A drop on the mat pauses the music. Marking a DA right after dropping a
/// DB (or the other way round), before playing on, marks it at the same
/// time: performed together, in the same moment.
class TimelineSection extends ConsumerStatefulWidget {
  const TimelineSection({super.key, required this.routineId});

  /// How far −/+ move a time.
  static const nudge = Duration(milliseconds: 100);

  final String routineId;

  @override
  ConsumerState<TimelineSection> createState() => _TimelineSectionState();
}

class _TimelineSectionState extends ConsumerState<TimelineSection> {
  /// The item last dropped on the mat, its time, and where the music was
  /// paused after it. Cleared once used for a pair.
  ({TimelineKind kind, Duration time, Duration pausedAt})? _dropped;

  String get routineId => widget.routineId;

  /// Whether the picker for a new item is open (or opening).
  bool _adding = false;

  /// Marks the next item of [kind] at [time] (and [cell]), or adds a new
  /// one when all are marked. Pauses the music after a drop on the mat, so
  /// the DB or DA done with it can be marked at the same time.
  Future<void> _mark(
    TimelineKind kind,
    Duration time, {
    FloorCell? cell,
    bool dropped = false,
  }) async {
    final controller = ref.read(routineControllerProvider(routineId).notifier);
    final player = ref.read(musicPlayerProvider(routineId));
    final routine = ref.read(routineProvider(routineId));
    if (routine.nextUnmarked(kind) == null) {
      if (kind != TimelineKind.danceStep) {
        return _addAndMark(kind, time, cell);
      }
      // An S has nothing to choose, so the music can play on.
      controller.updateRoutine(
        (routine) => routine.withDanceStepCount(routine.danceStepCount + 1),
      );
    }
    final together = _togetherTime(kind, player);
    if (together != null) {
      _dropped = null;
      controller.markNext(kind, together, cell);
      return;
    }
    controller.markNext(kind, time, cell);
    if (!dropped) return;
    await player.pause();
    if (!mounted) return;
    _dropped = (kind: kind, time: time, pausedAt: player.position);
  }

  /// Pauses the music, asks which item of [kind] to add, and marks it at
  /// [time] (the moment of the tap) and [cell]. The music stays paused, so
  /// the DB or DA done with it can be added at the same time. Nothing
  /// changes when the user closes the picker without choosing.
  Future<void> _addAndMark(
    TimelineKind kind,
    Duration time,
    FloorCell? cell,
  ) async {
    if (_adding) return;
    _adding = true;
    try {
      final player = ref.read(musicPlayerProvider(routineId));
      await player.pause();
      if (!mounted) return;
      final pausedAt = player.position;
      await _showPicker(kind);
      if (!mounted) return;
      final controller = ref.read(
        routineControllerProvider(routineId).notifier,
      );
      if (ref.read(routineProvider(routineId)).nextUnmarked(kind) == null) {
        return;
      }
      final together = _togetherTime(kind, player);
      controller.markNext(kind, together ?? time, cell);
      _dropped = together != null
          ? null
          : (kind: kind, time: time, pausedAt: pausedAt);
    } finally {
      _adding = false;
    }
  }

  /// Opens the screen that adds one DB, risk or DA.
  Future<void> _showPicker(TimelineKind kind) => switch (kind) {
    TimelineKind.db => ElementPickerScreen.show(
      context,
      routineId: routineId,
      addOne: true,
    ),
    TimelineKind.risk => RiskBuilderSheet.show(
      context,
      routineId: routineId,
      catalogue: ref.read(riskCatalogueProvider).requireValue,
    ),
    TimelineKind.da => DaBuilderSheet.show(
      context,
      routineId: routineId,
      bases: _daBases,
    ),
    // S are added directly, with nothing to choose.
    TimelineKind.danceStep => Future.value(),
  };

  /// The DA bases of the routine's apparatus.
  List<DaBase> get _daBases {
    final apparatus = ref.read(routineProvider(routineId)).apparatus;
    return [
      for (final base in ref.read(daBasesProvider).value ?? const <DaBase>[])
        if (base.apparatus == apparatus) base,
    ];
  }

  /// Whether a new item of [kind] can be added: risks and DA need their
  /// catalogues, and DA an apparatus.
  bool _canAdd(TimelineKind kind) => switch (kind) {
    TimelineKind.db || TimelineKind.danceStep => true,
    TimelineKind.risk =>
      !(ref.watch(riskCatalogueProvider).value?.isEmpty ?? true),
    TimelineKind.da =>
      ref.watch(daBasesProvider).hasValue && _daBases.isNotEmpty,
  };

  /// The time of the dropped DB or DA that an item of [kind] is performed
  /// together with, or `null`: only while the music is still paused where
  /// it stopped after the drop.
  Duration? _togetherTime(TimelineKind kind, MusicPlayer player) {
    final dropped = _dropped;
    if (dropped == null ||
        kind.partnerKind != dropped.kind ||
        player.playing ||
        (player.position - dropped.pausedAt).abs() >
            const Duration(milliseconds: 50)) {
      return null;
    }
    // The dropped item may have been cleared, moved or paired since.
    final routine = ref.read(routineProvider(routineId));
    final stillThere =
        routine.timesOf(dropped.kind).contains(dropped.time) &&
        !routine.timesOf(kind).contains(dropped.time);
    return stillThere ? dropped.time : null;
  }

  @override
  Widget build(BuildContext context) {
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
          'Play the music and tap when each one starts. "Next" marks what '
          'is already in the routine; "Add" pauses the music so you can '
          'choose a new one. Drag onto the mat to also mark where. While '
          'paused, you can add the DB or DA done in the same moment.',
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
                    canAdd: _canAdd(kind),
                    position: () => player.position,
                    onMark: (time) => _mark(kind, time),
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
                  _mark(mark.kind, mark.time, cell: cell, dropped: true),
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
              partner: switch (routine.partnerOf(entry.kind, entry.index)) {
                null => null,
                final i => '${entry.kind.partnerKind!.label} ${i + 1}',
              },
              conflictWith: conflicts[(entry.kind, entry.index)],
              onTap: () => player.seek(entry.time),
              onNudge: (offset) =>
                  controller.moveTime(entry.kind, entry.index, offset),
              onPair:
                  routine.apparatus == Apparatus.freehand ||
                      entry.kind.partnerKind == null
                  ? null
                  : () async {
                      if (routine.partnerOf(entry.kind, entry.index) != null) {
                        // Split: only this item moves.
                        controller.setTime(
                          entry.kind,
                          entry.index,
                          entry.time + TimelineSection.nudge,
                        );
                        return;
                      }
                      final partner = await _pickPartner(
                        context,
                        entry,
                        entries,
                      );
                      if (partner == null) return;
                      controller.pairWith(entry.kind, entry.index, partner);
                    },
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

  /// Asks which marked item of the other kind [entry] (a DB or DA) is
  /// performed together with, the nearest in time first. Returns its
  /// index, or `null` when dismissed.
  Future<int?> _pickPartner(
    BuildContext context,
    TimelineEntry entry,
    List<TimelineEntry> entries,
  ) {
    final routine = ref.read(routineProvider(routineId));
    final partnerKind = entry.kind.partnerKind!;
    final candidates =
        [
          for (final e in entries)
            if (e.kind == partnerKind &&
                routine.partnerOf(e.kind, e.index) == null)
              e,
        ]..sort(
          (a, b) => (a.time - entry.time).abs().compareTo(
            (b.time - entry.time).abs(),
          ),
        );
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  '${entry.kind.label} ${entry.index + 1} is done together '
                  'with…',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (candidates.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Text('No marked ${partnerKind.label} to pair with.'),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final c in candidates)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          leading: Text(formatTimelineTime(c.time)),
                          title: Text('${c.kind.label} ${c.index + 1}'),
                          subtitle: Text(
                            c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).pop(c.index),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
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

/// The data of a "Next" or "Add" button being dragged: what it marks, and the
/// music time when the finger went down.
class _PendingMark {
  _PendingMark(this.kind);

  final TimelineKind kind;
  Duration time = Duration.zero;
}

/// "Next DB" with how many are marked, e.g. "2 of 5", or "Add DB" when all
/// are marked (or there are none). Tap to mark the time; drag onto the floor
/// mat to mark the time and where (dropped elsewhere, only the time).
/// Disabled when there is nothing to mark and nothing can be added.
class _MarkButton extends StatefulWidget {
  const _MarkButton({
    required this.kind,
    required this.times,
    required this.canAdd,
    required this.position,
    required this.onMark,
  });

  final TimelineKind kind;
  final List<Duration?> times;

  /// Whether a new item can be added once all are marked.
  final bool canAdd;

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
    final allMarked = marked == widget.times.length;
    final enabled = !allMarked || widget.canAdd;
    final colours = ItemColours.of(widget.kind, Theme.of(context).colorScheme);
    final button = FilledButton.tonal(
      key: ValueKey('mark-${widget.kind.name}'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: colours.container,
        foregroundColor: colours.onContainer,
      ),
      onPressed: enabled ? () => widget.onMark(_mark.time) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${allMarked ? 'Add' : 'Next'} ${widget.kind.label}'),
          Text(
            widget.times.isEmpty ? 'none' : '$marked of ${widget.times.length}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
    if (!enabled) return button;
    // The time is taken when the finger goes down, so a drag is as exact
    // as a tap.
    return Listener(
      onPointerDown: (_) => _mark.time = widget.position(),
      child: Draggable<_PendingMark>(
        data: _mark,
        onDraggableCanceled: (_, _) => widget.onMark(_mark.time),
        feedback: Material(
          color: colours.colour,
          shape: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.kind.label,
              style: TextStyle(
                color: colours.onColour,
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
    required this.partner,
    required this.onPair,
    required this.conflictWith,
    required this.onTap,
    required this.onNudge,
    required this.onClear,
    required this.onPickCell,
  });

  final TimelineEntry entry;

  /// The item performed together with this one, e.g. "DA 3", or `null`.
  final String? partner;

  /// Pairs with, or splits from, the DB or DA done together. `null` for
  /// items that cannot be paired.
  final VoidCallback? onPair;

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
    final muted = theme.colorScheme.onSurfaceVariant;
    // Two lines, so the name gets the full width on a phone: time, item and
    // name on top; together / S notes and the buttons below.
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    formatTimelineTime(entry.time),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: conflictWith == null ? null : error,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Text(
                  item,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ItemColours.of(entry.kind, theme.colorScheme).colour,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 64),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (partner case final partner?)
                        _RowNote(
                          icon: Icons.link,
                          text: 'With $partner',
                          color: muted,
                        ),
                      if (conflictWith != null)
                        _RowNote(
                          icon: Icons.warning_amber_rounded,
                          text: danceStepConflictText(conflictWith),
                          color: error,
                        ),
                    ],
                  ),
                ),
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
                if (onPair case final onPair?)
                  IconButton(
                    tooltip: partner == null
                        ? 'Pair $item with a ${entry.kind.partnerKind!.label}'
                        : 'Split $item from $partner',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(partner == null ? Icons.link : Icons.link_off),
                    onPressed: onPair,
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
          ],
        ),
      ),
    );
  }
}

/// A short note under a timeline row, e.g. "With DA 1".
class _RowNote extends StatelessWidget {
  const _RowNote({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ),
    ],
  );
}

/// e.g. "1:05.3": minutes, seconds and tenths.
String formatTimelineTime(Duration time) {
  final tenths = time.inMilliseconds ~/ 100;
  final seconds = tenths ~/ 10;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'
      '.${tenths % 10}';
}
