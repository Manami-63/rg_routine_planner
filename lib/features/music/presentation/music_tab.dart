import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/message_view.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/routine_music.dart';
import 'music_actions.dart';
import 'music_player.dart';
import 'music_providers.dart';

/// The parts of the Music tab handed to [MusicTab.marking] once the music
/// has loaded: what goes at the top of its scroll view (the title and the
/// seek bar), and the player for its own play buttons.
class MusicTabParts {
  const MusicTabParts({
    required this.top,
    required this.player,
    required this.duration,
  });

  final List<Widget> top;
  final MusicPlayer player;
  final Duration duration;
}

/// The routine's music: add, replace or remove it, and play it.
class MusicTab extends ConsumerWidget {
  const MusicTab({super.key, required this.routineId, this.marking});

  final String routineId;

  /// Builds the whole tab once the music has loaded (e.g. marking times,
  /// with the play buttons beside the mark buttons). Without it the tab is
  /// the title and the full player.
  final Widget Function(BuildContext context, MusicTabParts parts)? marking;

  static const _padding = EdgeInsets.all(16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(routineProvider(routineId).select((r) => r.music));
    if (music == null) {
      return ListView(
        children: [
          MessageView(
            icon: Icons.music_note_outlined,
            title: 'No music yet',
            message:
                'Add the music for this routine (MP3, M4A, AAC or WAV). '
                'The app keeps its own copy on this device.',
            action: FilledButton.icon(
              onPressed: () => chooseMusic(context, ref, routineId),
              icon: const Icon(Icons.add),
              label: const Text('Add music'),
            ),
          ),
        ],
      );
    }

    final header = [
      _MusicHeader(routineId: routineId, music: music),
      const SizedBox(height: 8),
    ];
    final loaded = ref.watch(loadedMusicProvider(routineId));
    return loaded.when(
      skipLoadingOnRefresh: false,
      loading: () => ListView(
        padding: _padding,
        children: [
          ...header,
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading music'),
            ),
          ),
        ],
      ),
      error: (error, _) => ListView(
        padding: _padding,
        children: [
          ...header,
          MessageView(
            icon: Icons.error_outline,
            isError: true,
            title: error is MusicFileMissingException
                ? 'The music file is missing'
                : 'Could not play the music',
            message: 'Choose the music file again.',
            action: FilledButton.tonalIcon(
              onPressed: () => chooseMusic(context, ref, routineId),
              icon: const Icon(Icons.library_music_outlined),
              label: const Text('Choose music'),
            ),
          ),
        ],
      ),
      data: (duration) {
        final player = ref.watch(musicPlayerProvider(routineId));
        final length = duration ?? Duration.zero;
        final marking = this.marking;
        if (marking == null) {
          return ListView(
            padding: _padding,
            children: [
              ...header,
              MusicPlayerControls(player: player, duration: length),
            ],
          );
        }
        return marking(
          context,
          MusicTabParts(
            top: [
              ...header,
              MusicSeekBar(player: player, duration: length),
            ],
            player: player,
            duration: length,
          ),
        );
      },
    );
  }
}

enum _MusicAction { replace, remove }

class _MusicHeader extends ConsumerWidget {
  const _MusicHeader({required this.routineId, required this.music});

  final String routineId;
  final RoutineMusic music;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(music.title, key: const ValueKey('music-title')),
      trailing: PopupMenuButton<_MusicAction>(
        tooltip: 'Music options',
        onSelected: (action) => switch (action) {
          _MusicAction.replace => chooseMusic(context, ref, routineId),
          _MusicAction.remove => removeMusic(context, ref, routineId),
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _MusicAction.replace,
            child: ListTile(
              leading: Icon(Icons.library_music_outlined),
              title: Text('Replace music'),
            ),
          ),
          PopupMenuItem(
            value: _MusicAction.remove,
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Remove music'),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Seek bar with times and the playback speed, and back / play-pause /
/// forward buttons.
class MusicPlayerControls extends StatelessWidget {
  const MusicPlayerControls({
    super.key,
    required this.player,
    required this.duration,
  });

  final MusicPlayer player;
  final Duration duration;

  /// The speeds to choose from: slower ones for learning a routine.
  static const speeds = [0.5, 0.75, 0.9, 1.0];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      MusicSeekBar(player: player, duration: duration),
      const SizedBox(height: 8),
      MusicTransportButtons(player: player, duration: duration),
    ],
  );
}

/// The seek bar, with the position, the playback speed and the length.
class MusicSeekBar extends StatelessWidget {
  const MusicSeekBar({super.key, required this.player, required this.duration});

  final MusicPlayer player;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final timeStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      initialData: player.position,
      builder: (context, snapshot) {
        final position = snapshot.data! > duration ? duration : snapshot.data!;
        return Column(
          children: [
            Slider(
              value: position.inMilliseconds.toDouble(),
              max: duration.inMilliseconds.toDouble().clamp(1, 1e9),
              semanticFormatterCallback: (_) => formatMusicTime(position),
              onChanged: (value) =>
                  player.seek(Duration(milliseconds: value.round())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatMusicTime(position),
                    key: const ValueKey('music-position'),
                    style: timeStyle,
                  ),
                  _SpeedButton(player: player),
                  Text(
                    formatMusicTime(duration),
                    key: const ValueKey('music-duration'),
                    style: timeStyle,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Back 5 seconds, play / pause and forward 5 seconds. [compact] makes them
/// smaller, for a bar with other buttons.
class MusicTransportButtons extends StatelessWidget {
  const MusicTransportButtons({
    super.key,
    required this.player,
    required this.duration,
    this.compact = false,
  });

  final MusicPlayer player;
  final Duration duration;
  final bool compact;

  static const _skip = Duration(seconds: 5);

  void _seekBy(Duration offset) {
    final target = player.position + offset;
    player.seek(
      target < Duration.zero
          ? Duration.zero
          : (target > duration ? duration : target),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skipSize = compact ? 28.0 : 32.0;
    final gap = SizedBox(width: compact ? 8 : 16);
    return StreamBuilder<bool>(
      stream: player.playingStream,
      initialData: player.playing,
      builder: (context, snapshot) {
        final playing = snapshot.data!;
        return Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Back 5 seconds',
              iconSize: skipSize,
              icon: const Icon(Icons.replay_5),
              onPressed: () => _seekBy(-_skip),
            ),
            gap,
            IconButton.filled(
              tooltip: playing ? 'Pause' : 'Play',
              iconSize: compact ? 36 : 48,
              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              onPressed: playing ? player.pause : player.play,
            ),
            gap,
            IconButton(
              tooltip: 'Forward 5 seconds',
              iconSize: skipSize,
              icon: const Icon(Icons.forward_5),
              onPressed: () => _seekBy(_skip),
            ),
          ],
        );
      },
    );
  }
}

/// The playback speed, e.g. "0.75×", which opens the choice of speeds.
/// Stands out when not normal, so slow music is not mistaken for normal.
class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.player});

  final MusicPlayer player;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StreamBuilder<double>(
      stream: player.speedStream,
      initialData: player.speed,
      builder: (context, snapshot) {
        final speed = snapshot.data!;
        final slow = speed != 1;
        return PopupMenuButton<double>(
          tooltip: 'Playback speed',
          initialValue: speed,
          onSelected: player.setSpeed,
          itemBuilder: (context) => [
            for (final option in MusicPlayerControls.speeds)
              PopupMenuItem(
                value: option,
                child: Text(option == 1 ? 'Normal (1×)' : formatSpeed(option)),
              ),
          ],
          child: Container(
            key: const ValueKey('music-speed'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: slow ? colors.tertiaryContainer : null,
              border: Border.all(
                color: slow ? colors.tertiaryContainer : colors.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.speed,
                  size: 16,
                  color: slow
                      ? colors.onTertiaryContainer
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  formatSpeed(speed),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: slow ? colors.onTertiaryContainer : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// e.g. "0.75×" or "1×".
String formatSpeed(double speed) {
  final text = speed.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  return '$text×';
}

/// e.g. "1:05" or "0:07".
String formatMusicTime(Duration time) {
  final seconds = time.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}
