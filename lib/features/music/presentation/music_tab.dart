import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/message_view.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/routine_music.dart';
import 'music_actions.dart';
import 'music_player.dart';
import 'music_providers.dart';

/// The routine's music: add, replace or remove it, and play it.
class MusicTab extends ConsumerWidget {
  const MusicTab({super.key, required this.routineId, this.footer});

  final String routineId;

  /// Shown below the player once the music has loaded (e.g. marking
  /// times, which needs the player).
  final Widget? footer;

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

    final loaded = ref.watch(loadedMusicProvider(routineId));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MusicHeader(routineId: routineId, music: music),
        const SizedBox(height: 8),
        loaded.when(
          skipLoadingOnRefresh: false,
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading music'),
            ),
          ),
          error: (error, _) => MessageView(
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
          data: (duration) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PlayerControls(
                player: ref.watch(musicPlayerProvider(routineId)),
                duration: duration ?? Duration.zero,
              ),
              ?footer,
            ],
          ),
        ),
      ],
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

/// Seek bar with times, and back / play-pause / forward buttons.
class _PlayerControls extends StatelessWidget {
  const _PlayerControls({required this.player, required this.duration});

  final MusicPlayer player;
  final Duration duration;

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
    final textTheme = Theme.of(context).textTheme;
    final timeStyle = textTheme.bodySmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Column(
      children: [
        StreamBuilder<Duration>(
          stream: player.positionStream,
          initialData: player.position,
          builder: (context, snapshot) {
            final position = snapshot.data! > duration
                ? duration
                : snapshot.data!;
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
        ),
        const SizedBox(height: 8),
        StreamBuilder<bool>(
          stream: player.playingStream,
          initialData: player.playing,
          builder: (context, snapshot) {
            final playing = snapshot.data!;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Back 5 seconds',
                  iconSize: 32,
                  icon: const Icon(Icons.replay_5),
                  onPressed: () => _seekBy(-_skip),
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  tooltip: playing ? 'Pause' : 'Play',
                  iconSize: 48,
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                  onPressed: playing ? player.pause : player.play,
                ),
                const SizedBox(width: 16),
                IconButton(
                  tooltip: 'Forward 5 seconds',
                  iconSize: 32,
                  icon: const Icon(Icons.forward_5),
                  onPressed: () => _seekBy(_skip),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// e.g. "1:05" or "0:07".
String formatMusicTime(Duration time) {
  final seconds = time.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}
