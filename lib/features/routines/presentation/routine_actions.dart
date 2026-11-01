import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../app/router.dart';
import '../../music/data/music_library.dart';
import '../../music/domain/routine_music.dart';
import '../../music/presentation/music_providers.dart';
import '../domain/routine.dart';
import '../domain/routine_file.dart';
import 'routine_details_form.dart';
import 'routine_providers.dart';

/// Saves a copy of the routine from [load] (DB, DA, apparatus, level,
/// notes and music) named "`name` (copy)", then offers to open it. Used
/// from My routines and from the routine page.
Future<void> duplicateRoutine(
  BuildContext context,
  WidgetRef ref,
  Future<Routine?> Function() load,
) async {
  final repository = ref.read(routineRepositoryProvider);
  final library = ref.read(musicLibraryProvider);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.maybeOf(context);
  final Routine copy;
  try {
    final original = await load();
    if (original == null) throw StateError('Routine not found');
    final music = original.music;
    copy = original
        .duplicate(
          id: const Uuid().v4(),
          name: '${routineDisplayName(original.name)} (copy)',
          now: DateTime.now().toUtc(),
        )
        // Its own copy of the music, so deleting one keeps the other's.
        .withMusic(
          music == null || await library.pathOf(music) == null
              ? null
              : await library.copy(music),
        );
    await repository.saveRoutine(copy);
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not duplicate the routine.')),
    );
    return;
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text('Saved as "${copy.name}".'),
      action: router == null
          ? null
          : SnackBarAction(
              label: 'Open',
              onPressed: () => router.go(AppRoutes.routine(copy.id)),
            ),
    ),
  );
}

/// Offers the routine from [load] as a routine file, for sending to
/// someone else, asking first whether its music goes too. Used from My
/// routines and from the routine page.
Future<void> shareRoutine(
  BuildContext context,
  WidgetRef ref,
  Future<Routine?> Function() load,
) async {
  final transfer = ref.read(routineFileTransferProvider);
  final library = ref.read(musicLibraryProvider);
  final messenger = ScaffoldMessenger.of(context);
  final box = context.findRenderObject()! as RenderBox;
  final origin = box.localToGlobal(Offset.zero) & box.size;
  var musicMissing = false;
  try {
    final routine = await load();
    if (routine == null) throw StateError('Routine not found');
    final music = routine.music;
    SharedMusic? shared;
    if (music != null) {
      if (await library.pathOf(music) == null) {
        musicMissing = true;
      } else {
        if (!context.mounted) return;
        final include = await _askIncludeMusic(context, music.title);
        if (include == null) return;
        if (include) {
          shared = SharedMusic(
            title: music.title,
            extension: p.extension(music.fileName).replaceFirst('.', ''),
            bytes: await library.readBytes(music),
          );
        }
      }
    }
    await transfer.share(
      fileName: RoutineFile.fileNameFor(routineDisplayName(routine.name)),
      contents: RoutineFile.encode(routine, music: shared),
      origin: origin,
    );
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not share the routine.')),
    );
    return;
  }
  if (musicMissing) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('The music file is missing, so it was left out.'),
      ),
    );
  }
}

/// `null` if the user dismissed the question.
Future<bool?> _askIncludeMusic(BuildContext context, String title) =>
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Include the music?'),
        content: Text(
          'With "$title", the routine is ready for Play mode, but the file '
          'is bigger. Without it, marked times are kept and work once the '
          'same track is added.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Without music'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Include music'),
          ),
        ],
      ),
    );

/// Lets the user choose a routine file and imports it.
Future<void> importRoutine(BuildContext context, WidgetRef ref) =>
    importRoutineFile(
      ref,
      ref.read(routineFileTransferProvider).pick,
      messenger: ScaffoldMessenger.of(context),
      router: GoRouter.maybeOf(context),
    );

/// Saves the routine file from [read] (`null`: cancelled) as a new routine,
/// with its own copy of any music in the file, then offers to open it.
Future<void> importRoutineFile(
  WidgetRef ref,
  Future<String?> Function() read, {
  required ScaffoldMessengerState messenger,
  required GoRouter? router,
}) async {
  final repository = ref.read(routineRepositoryProvider);
  final library = ref.read(musicLibraryProvider);
  final Routine routine;
  RoutineMusic? stored;
  try {
    final contents = await read();
    if (contents == null) return;
    final decoded = RoutineFile.decode(
      contents,
      id: const Uuid().v4(),
      now: DateTime.now().toUtc(),
    );
    if (decoded.music case final music?) {
      stored = await library.addBytes(
        music.bytes,
        extension: music.extension,
        title: music.title,
      );
    }
    routine = decoded.routine.withMusic(stored);
    await repository.saveRoutine(routine);
  } on NewerRoutineFileException {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'This routine needs a newer version of the app. Update it and '
          'try again.',
        ),
      ),
    );
    return;
  } on Object {
    if (stored != null) await _deleteQuietly(library, stored);
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not import this file.')),
    );
    return;
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text('Imported "${routineDisplayName(routine.name)}".'),
      action: router == null
          ? null
          : SnackBarAction(
              label: 'Open',
              onPressed: () => router.go(AppRoutes.routine(routine.id)),
            ),
    ),
  );
}

/// Deletes the routine with [id] and the app's copy of its music.
Future<void> deleteRoutine(WidgetRef ref, String id) async {
  final repository = ref.read(routineRepositoryProvider);
  final library = ref.read(musicLibraryProvider);
  final music = (await repository.fetchRoutine(id))?.music;
  await repository.deleteRoutine(id);
  if (music != null) await _deleteQuietly(library, music);
}

/// A leftover file only wastes space, so failures are ignored.
Future<void> _deleteQuietly(MusicLibrary library, RoutineMusic music) async {
  try {
    await library.delete(music);
  } on Object {
    // Ignored.
  }
}
