import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../routines/presentation/routine_controller.dart';
import '../data/music_library.dart';
import '../data/music_picker.dart';
import 'music_player.dart';

// Wiring for routine music. Widget tests override the library, picker and
// player with fakes.

final musicLibraryProvider = Provider<MusicLibrary>(
  (ref) => FileMusicLibrary(
    () async => Directory(
      p.join((await getApplicationSupportDirectory()).path, 'music'),
    ),
  ),
);

final musicPickerProvider = Provider<MusicPicker>(
  (ref) => const FilePickerMusicPicker(),
);

/// The player of an open routine. Released (and the music stopped) when
/// nothing shows the music any more.
final musicPlayerProvider = Provider.autoDispose.family<MusicPlayer, String>((
  ref,
  routineId,
) {
  final player = JustAudioMusicPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Thrown when a routine's music file is no longer in the library.
class MusicFileMissingException implements Exception {
  const MusicFileMissingException();
}

/// Loads the routine's music into its player and gives its duration
/// (`null` if unknown). Only watch this when the routine has music.
final loadedMusicProvider = FutureProvider.autoDispose
    .family<Duration?, String>((ref, routineId) async {
      final music = ref.watch(
        routineProvider(routineId).select((r) => r.music),
      );
      final player = ref.watch(musicPlayerProvider(routineId));
      if (music == null) return null;
      final path = await ref.read(musicLibraryProvider).pathOf(music);
      if (path == null) throw const MusicFileMissingException();
      return player.load(path);
    }, retry: (_, _) => null);
