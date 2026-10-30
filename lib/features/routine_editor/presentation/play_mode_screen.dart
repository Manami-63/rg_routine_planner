import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/device/screen_awake.dart';
import '../../music/presentation/music_providers.dart';
import '../../music/presentation/music_tab.dart';
import '../../routines/presentation/routine_details_form.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/play_mode.dart';
import '../domain/routine_timeline.dart';
import 'dance_step_conflicts.dart';
import 'floor_mat.dart';

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

/// The current item (or what comes next), any running S countdown, and
/// the next item.
class _FrameView extends StatelessWidget {
  const _FrameView({required this.frame, required this.conflicts});

  final PlayModeFrame frame;

  /// Items marked during an S they may not be in, and that S.
  final Map<(TimelineKind, int), int> conflicts;

  @override
  Widget build(BuildContext context) {
    final current = frame.current;
    final danceStep = frame.danceStep;
    final next = frame.next;
    return Column(
      children: [
        // Another item started during an S: keep its countdown visible.
        SizedBox(
          height: 48,
          child: danceStep != null && current != danceStep
              ? Center(
                  child: Chip(
                    key: const ValueKey('dance-step-chip'),
                    avatar: const Icon(Icons.timer_outlined),
                    label: Text(
                      'S · ${_seconds(frame.danceStepRemaining!)} s left',
                    ),
                  ),
                )
              : null,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween(begin: 0.85, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: switch (current) {
              null => _WaitingView(
                key: const ValueKey('waiting'),
                next: next,
                untilNext: frame.untilNext,
              ),
              TimelineEntry(kind: TimelineKind.danceStep) => _DanceStepView(
                key: ValueKey(current),
                entry: current,
                remaining: frame.danceStepRemaining!,
              ),
              _ => _ItemView(
                key: ValueKey(current),
                entry: current,
                conflictWith: conflicts[(current.kind, current.index)],
              ),
            },
          ),
        ),
        SizedBox(
          height: 56,
          child: current != null && next != null
              ? Center(
                  child: Text(
                    'Next: ${_itemLabel(next)} · ${next.name} in '
                    '${_seconds(frame.untilNext!)} s',
                    key: const ValueKey('next-line'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

/// A DB, R or DA that has just started.
class _ItemView extends StatelessWidget {
  const _ItemView({super.key, required this.entry, this.conflictWith});

  final TimelineEntry entry;

  /// The S this item may not be performed during, or `null`.
  final int? conflictWith;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, foreground) = _colorsOf(entry.kind, theme.colorScheme);
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _itemLabel(entry),
              key: const ValueKey('current-item'),
              style: theme.textTheme.displayLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              entry.name,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(color: foreground),
            ),
            if (entry.cell != null) ...[
              const SizedBox(height: 12),
              _MiniMat(entry: entry),
            ],
            if (conflictWith case final s?) ...[
              const SizedBox(height: 12),
              Chip(
                key: const ValueKey('play-conflict'),
                avatar: Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.onErrorContainer,
                ),
                backgroundColor: theme.colorScheme.errorContainer,
                label: Text(
                  danceStepConflictText(s),
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A dance steps combination, with its countdown.
class _DanceStepView extends StatelessWidget {
  const _DanceStepView({
    super.key,
    required this.entry,
    required this.remaining,
  });

  final TimelineEntry entry;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, foreground) = _colorsOf(entry.kind, theme.colorScheme);
    final progress =
        remaining.inMilliseconds / danceStepCountdown.inMilliseconds;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _itemLabel(entry),
            key: const ValueKey('current-item'),
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          SizedBox.square(
            dimension: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress.clamp(0, 1),
                  strokeWidth: 12,
                  color: foreground,
                  backgroundColor: background,
                ),
                Center(
                  child: Text(
                    '${_seconds(remaining)}',
                    key: const ValueKey('dance-step-countdown'),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Dance steps', style: theme.textTheme.titleLarge),
          if (entry.cell != null) ...[
            const SizedBox(height: 12),
            _MiniMat(entry: entry),
          ],
        ],
      ),
    );
  }
}

/// Nothing on screen: what comes next and when, or the end.
class _WaitingView extends StatelessWidget {
  const _WaitingView({super.key, required this.next, required this.untilNext});

  final TimelineEntry? next;
  final Duration? untilNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final next = this.next;
    if (next == null) {
      return Center(
        child: Text(
          'No more marked items',
          style: theme.textTheme.headlineSmall?.copyWith(color: muted),
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Next',
            style: theme.textTheme.titleLarge?.copyWith(color: muted),
          ),
          Text(
            _itemLabel(next),
            key: const ValueKey('waiting-next'),
            style: theme.textTheme.displayMedium?.copyWith(color: muted),
          ),
          Text(
            next.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 8),
          Text(
            'in ${_seconds(untilNext!)} s',
            style: theme.textTheme.headlineSmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

/// Where the item starts, on a small floor mat.
class _MiniMat extends StatelessWidget {
  const _MiniMat({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('play-mini-mat'),
    width: 96,
    child: FloorMat<Object>(highlighted: entry.cell),
  );
}

/// e.g. "DB 3".
String _itemLabel(TimelineEntry entry) =>
    '${entry.kind.label} ${entry.index + 1}';

/// Whole seconds, rounded up, so a countdown shows 1 until it ends.
int _seconds(Duration time) => (time.inMilliseconds / 1000).ceil();

(Color, Color) _colorsOf(
  TimelineKind kind,
  ColorScheme colors,
) => switch (kind) {
  TimelineKind.db => (colors.primaryContainer, colors.onPrimaryContainer),
  TimelineKind.risk => (colors.tertiaryContainer, colors.onTertiaryContainer),
  TimelineKind.da => (colors.secondaryContainer, colors.onSecondaryContainer),
  TimelineKind.danceStep => (colors.surfaceContainerHighest, colors.primary),
};
