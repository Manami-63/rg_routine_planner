import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/device/screen_awake.dart';
import '../../../core/floor/floor_cell.dart';
import '../../da_calculator/presentation/widgets/da_symbols.dart';
import '../../music/presentation/music_providers.dart';
import '../../music/presentation/music_tab.dart';
import '../../routines/presentation/routine_details_form.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/play_mode.dart';
import '../domain/routine_timeline.dart';
import 'dance_step_conflicts.dart';
import 'timeline_colours.dart';

/// Full-screen rehearsal view: plays the music and pops up each marked DB,
/// R, DA and S at its time, with a countdown during S.
///
/// Uses the routine page's player, so the music keeps its position when
/// switching between the two. Keeps the screen on while open.
class PlayModeScreen extends ConsumerStatefulWidget {
  const PlayModeScreen({super.key, required this.routineId});

  final String routineId;

  static Future<void> show(BuildContext context, {required String routineId}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => PlayModeScreen(routineId: routineId),
      ),
    );
  }

  @override
  ConsumerState<PlayModeScreen> createState() => _PlayModeScreenState();
}

class _PlayModeScreenState extends ConsumerState<PlayModeScreen> {
  // Kept so `dispose` does not need `ref`.
  late final ScreenAwake _screenAwake = ref.read(screenAwakeProvider);

  String get routineId => widget.routineId;

  @override
  void initState() {
    super.initState();
    _screenAwake.enable();
  }

  @override
  void dispose() {
    _screenAwake.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(routineProvider(routineId).select((r) => r.name));
    final entries = ref.watch(
      routineProvider(routineId).select((r) => r.timelineEntries),
    );
    final player = ref.watch(musicPlayerProvider(routineId));
    final duration = ref.watch(loadedMusicProvider(routineId)).value;
    final conflicts = watchDanceStepConflicts(ref, routineId);

    // Dark, so the pop-ups stand out from across a gym.
    final theme = Theme.of(context);
    final dark = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: theme.colorScheme.primary,
        brightness: Brightness.dark,
      ),
    );

    return Theme(
      data: dark,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close Play mode',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(routineDisplayName(name)),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<Duration>(
                    stream: player.positionStream,
                    initialData: player.position,
                    builder: (context, snapshot) => _FrameView(
                      frame: playModeFrameAt(entries, snapshot.data!),
                      conflicts: conflicts,
                    ),
                  ),
                ),
                MusicPlayerControls(
                  player: player,
                  duration: duration ?? Duration.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One fixed layout, so nothing jumps while the music plays: the current
/// item (or what comes next) at the top, the floor mat filling the middle,
/// and the next item below it. During an S, a see-through countdown covers
/// the page.
class _FrameView extends StatelessWidget {
  const _FrameView({required this.frame, required this.conflicts});

  final PlayModeFrame frame;

  /// Items marked during an S they may not be in, and that S.
  final Map<(TimelineKind, int), int> conflicts;

  @override
  Widget build(BuildContext context) {
    final current = frame.current;
    final partner = frame.currentPartner;
    final danceStep = frame.danceStep;
    int? conflictOf(TimelineEntry? entry) =>
        entry == null ? null : conflicts[(entry.kind, entry.index)];

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: 136,
              child: _NowSlot(
                frame: frame,
                conflictWith: conflictOf(current) ?? conflictOf(partner),
              ),
            ),
            Expanded(
              child: _PlayMat(
                current: [?current, ?partner],
                next: [?frame.next, ?frame.nextPartner],
              ),
            ),
            SizedBox(height: 48, child: _NextSlot(frame: frame)),
          ],
        ),
        if (danceStep != null)
          Positioned.fill(
            child: IgnorePointer(
              child: _DanceStepOverlay(
                entry: danceStep,
                remaining: frame.danceStepRemaining!,
              ),
            ),
          ),
      ],
    );
  }
}

/// The current item in its colours (a DB and a DA together: both), its
/// name and any S conflict. With nothing current: what comes next, dimmed,
/// and when.
class _NowSlot extends StatelessWidget {
  const _NowSlot({required this.frame, required this.conflictWith});

  final PlayModeFrame frame;

  /// The S the current item may not be performed during, or `null`.
  final int? conflictWith;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final current = frame.current;
    final next = frame.next;
    final labelStyle = theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
    );

    final List<Widget> children;
    if (current != null) {
      children = [
        _ColouredLabel(
          key: const ValueKey('current-item'),
          entry: current,
          partner: frame.currentPartner,
          style: labelStyle,
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: _nameSpans(current, frame.currentPartner, ' · ', 32),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        if (conflictWith case final s?)
          Row(
            key: const ValueKey('play-conflict'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                danceStepConflictText(s),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
      ];
    } else if (next != null) {
      children = [
        Text(
          'Next',
          style: theme.textTheme.titleMedium?.copyWith(color: muted),
        ),
        Opacity(
          opacity: 0.6,
          child: _ColouredLabel(
            key: const ValueKey('waiting-next'),
            entry: next,
            partner: frame.nextPartner,
            style: labelStyle,
          ),
        ),
        Text(
          'in ${_seconds(frame.untilNext!)} s',
          style: theme.textTheme.titleMedium?.copyWith(color: muted),
        ),
      ];
    } else {
      children = [
        Text(
          'No more marked items',
          style: theme.textTheme.headlineSmall?.copyWith(color: muted),
        ),
      ];
    }
    return ClipRect(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

/// "Next: R 1 · 2 rotations in 4 s" while an item is current; empty
/// otherwise (the top slot already shows what comes next).
class _NextSlot extends StatelessWidget {
  const _NextSlot({required this.frame});

  final PlayModeFrame frame;

  @override
  Widget build(BuildContext context) {
    final next = frame.next;
    if (frame.current == null || next == null) return const SizedBox.shrink();
    final style = Theme.of(context).textTheme.titleMedium;
    return Center(
      child: Text.rich(
        key: const ValueKey('next-line'),
        TextSpan(
          style: style,
          children: [
            const TextSpan(text: 'Next: '),
            ..._labelSpans(context, next, frame.nextPartner),
            const TextSpan(text: ' · '),
            ..._nameSpans(next, frame.nextPartner, ' + ', 22),
            TextSpan(text: ' in ${_seconds(frame.untilNext!)} s'),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// e.g. "DB 2 + DA 3", each label in its kind's colour.
class _ColouredLabel extends StatelessWidget {
  const _ColouredLabel({
    super.key,
    required this.entry,
    required this.partner,
    required this.style,
  });

  final TimelineEntry entry;
  final TimelineEntry? partner;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text.rich(
      TextSpan(style: style, children: _labelSpans(context, entry, partner)),
    ),
  );
}

List<TextSpan> _labelSpans(
  BuildContext context,
  TimelineEntry entry,
  TimelineEntry? partner,
) {
  final scheme = Theme.of(context).colorScheme;
  TextSpan label(TimelineEntry e) => TextSpan(
    text: _itemLabel(e),
    style: TextStyle(color: ItemColours.of(e.kind, scheme).colour),
  );
  return [
    label(entry),
    if (partner != null) ...[const TextSpan(text: ' + '), label(partner)],
  ];
}

/// The floor as large as fits: the current item's cell filled in its
/// colour (purple for a DB and a DA together in one cell), the next item's
/// cell outlined, and a line between them.
class _PlayMat extends StatelessWidget {
  const _PlayMat({required this.current, required this.next});

  /// The current item and its partner, if any.
  final List<TimelineEntry> current;

  /// The next item and its partner, if any.
  final List<TimelineEntry> next;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final nowCells = _byCell(current);
    final nextCells = _byCell(next);
    final from = current.map((e) => e.cell).nonNulls.firstOrNull;
    final to = next.map((e) => e.cell).nonNulls.firstOrNull;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                key: const ValueKey('play-mat'),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Column(
                      children: [
                        for (var row = 0; row < 3; row++)
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var column = 0; column < 3; column++)
                                  Expanded(
                                    child: _cell(
                                      context,
                                      FloorCell.at(row, column),
                                      now: nowCells,
                                      next: nextCells,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (from != null && to != null && from != to)
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _MovePainter(
                            from: from,
                            to: to,
                            color: colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Front · Judges',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  static Map<FloorCell, List<TimelineEntry>> _byCell(
    List<TimelineEntry> entries,
  ) {
    final byCell = <FloorCell, List<TimelineEntry>>{};
    for (final entry in entries) {
      if (entry.cell case final cell?) {
        (byCell[cell] ??= []).add(entry);
      }
    }
    return byCell;
  }

  Widget _cell(
    BuildContext context,
    FloorCell cell, {
    required Map<FloorCell, List<TimelineEntry>> now,
    required Map<FloorCell, List<TimelineEntry>> next,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final here = now[cell];
    final nextHere = next[cell];
    final fill = here == null ? null : _cellColours(here, colors);
    final outline = nextHere == null ? null : _cellColours(nextHere, colors);
    return Container(
      key: ValueKey('play-cell-${cell.number}'),
      decoration: BoxDecoration(
        color:
            fill?.colour ??
            (cell.isZone ? colors.surfaceContainerHighest : colors.surface),
        border: outline == null
            ? Border.all(color: colors.outlineVariant, width: 0.5)
            : Border.all(color: outline.colour, width: 4),
      ),
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          Text(
            '${cell.number}',
            style: theme.textTheme.labelMedium?.copyWith(
              color:
                  fill?.onColour.withValues(alpha: 0.7) ??
                  colors.onSurfaceVariant,
            ),
          ),
          if (here != null)
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  here.map(_itemLabel).join('\n'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: fill!.onColour,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (outline != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Next',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: fill?.onColour ?? outline.colour,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// A kind's colours; purple for a DB and a DA together.
  static ItemColours _cellColours(
    List<TimelineEntry> entries,
    ColorScheme scheme,
  ) => entries.length > 1
      ? ItemColours.pair(scheme)
      : ItemColours.of(entries.first.kind, scheme);
}

/// A straight line from the middle of one cell to the middle of another.
class _MovePainter extends CustomPainter {
  _MovePainter({required this.from, required this.to, required this.color});

  final FloorCell from;
  final FloorCell to;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Offset middle(FloorCell cell) => Offset(
      (cell.column + 0.5) * size.width / 3,
      (cell.row + 0.5) * size.height / 3,
    );
    canvas.drawLine(
      middle(from),
      middle(to),
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MovePainter old) =>
      old.from != from || old.to != to || old.color != color;
}

/// A see-through layer over the page during an S: a large green countdown,
/// with the items and the mat still visible underneath.
class _DanceStepOverlay extends StatelessWidget {
  const _DanceStepOverlay({required this.entry, required this.remaining});

  final TimelineEntry entry;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final green = ItemColours.of(
      TimelineKind.danceStep,
      theme.colorScheme,
    ).colour;
    final progress =
        remaining.inMilliseconds / danceStepCountdown.inMilliseconds;
    return ColoredBox(
      key: const ValueKey('dance-step-overlay'),
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress.clamp(0, 1),
                    strokeWidth: 12,
                    color: green,
                    backgroundColor: green.withValues(alpha: 0.2),
                  ),
                  Center(
                    child: Text(
                      '${_seconds(remaining)}',
                      key: const ValueKey('dance-step-countdown'),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: green,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // On a dark pill, so the mat underneath does not show through.
            DecoratedBox(
              decoration: ShapeDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: const StadiumBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Text(
                  '${_itemLabel(entry)} · Dance steps',
                  style: theme.textTheme.titleLarge?.copyWith(color: green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// e.g. "DB 3".
String _itemLabel(TimelineEntry entry) =>
    '${entry.kind.label} ${entry.index + 1}';

/// [entry] and [partner], joined by [separator]: a DA as its symbols
/// [symbolSize] high when it has them, to save space, otherwise its name.
List<InlineSpan> _nameSpans(
  TimelineEntry entry,
  TimelineEntry? partner,
  String separator,
  double symbolSize,
) {
  InlineSpan span(TimelineEntry e) {
    final da = e.da;
    if (da == null || !DaSymbols.canShow(da)) return TextSpan(text: e.name);
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: DaSymbols(da, size: symbolSize),
    );
  }

  return [
    span(entry),
    if (partner != null) ...[TextSpan(text: separator), span(partner)],
  ];
}

/// Whole seconds, rounded up, so a countdown shows 1 until it ends.
int _seconds(Duration time) => (time.inMilliseconds / 1000).ceil();
