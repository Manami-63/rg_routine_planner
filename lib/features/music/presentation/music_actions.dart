import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../routines/presentation/routine_controller.dart';
import '../data/music_library.dart';
import '../domain/routine_music.dart';
import 'music_providers.dart';

/// Lets the user choose a music file and makes it the routine's music,
/// replacing (and deleting the app's copy of) any previous one.
Future<void> chooseMusic(
  BuildContext context,
  WidgetRef ref,
  String routineId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final library = ref.read(musicLibraryProvider);
  final controller = ref.read(routineControllerProvider(routineId).notifier);
  final previous = ref.read(routineProvider(routineId)).music;

  final picked = await ref.read(musicPickerProvider).pick();
  if (picked == null || !context.mounted) return;
  if (!RoutineMusic.accepts(picked.name)) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Choose an MP3, M4A, AAC or WAV file.')),
    );
    return;
  }
  try {
    final music = await library.add(
      picked.path,
      title: p.basenameWithoutExtension(picked.name),
    );
    if (!context.mounted) {
      await library.delete(music);
      return;
    }
    controller.setMusic(music);
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not add the music.')),
    );
    return;
  }
  if (previous != null) await _deleteQuietly(library, previous);
}

/// Asks, then removes the routine's music and deletes the app's copy.
Future<void> removeMusic(
  BuildContext context,
  WidgetRef ref,
  String routineId,
) async {
  final music = ref.read(routineProvider(routineId)).music;
  if (music == null) return;
  final library = ref.read(musicLibraryProvider);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove the music?'),
      content: const Text(
        "The app's copy is deleted. The file you chose is not affected.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (!(confirmed ?? false) || !context.mounted) return;
  ref.read(routineControllerProvider(routineId).notifier).setMusic(null);
  await _deleteQuietly(library, music);
}

/// A leftover file only wastes space, so failures are ignored.
Future<void> _deleteQuietly(MusicLibrary library, RoutineMusic music) async {
  try {
    await library.delete(music);
  } on Object {
    // Ignored.
  }
}
