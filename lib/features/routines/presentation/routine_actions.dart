import 'dart:async';

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
import 'routine_backup.dart';
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
        if (include) shared = await sharedMusicOf(library, music);
      }
    }
    await transfer.share(
      fileName: RoutineFile.fileNameFor(routineDisplayName(routine.name)),
      lines: Stream.value(RoutineFile.encode(routine, music: shared)),
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

/// The app's copy of [music], to go in a routine file.
Future<SharedMusic> sharedMusicOf(
  MusicLibrary library,
  RoutineMusic music,
) async => SharedMusic(
  title: music.title,
  extension: p.extension(music.fileName).replaceFirst('.', ''),
  bytes: await library.readBytes(music),
);

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

/// Lets the user choose a routine file or a backup and imports it.
Future<void> importRoutine(BuildContext context, WidgetRef ref) =>
    importRoutineFile(
      ref,
      ref.read(routineFileTransferProvider).pick,
      messenger: ScaffoldMessenger.of(context),
      router: GoRouter.maybeOf(context),
    );

/// Imports the file whose lines come from [read] (`null`: cancelled). A
/// routine file is saved as a new routine, with its own copy of any music
/// in it, then offered to open; a backup is restored ([restoreBackup]).
Future<void> importRoutineFile(
  WidgetRef ref,
  Future<Stream<String>?> Function() read, {
  required ScaffoldMessengerState messenger,
  required GoRouter? router,
}) async {
  final Routine routine;
  StreamIterator<String>? lines;
  try {
    final stream = await read();
    if (stream == null) return;
    lines = StreamIterator(stream);
    if (!await lines.moveNext()) throw const InvalidRoutineFileException();
    final first = lines.current;
    if (RoutineFile.backupCount(first) case final count?) {
      await restoreBackup(ref, lines, count: count, messenger: messenger);
      return;
    }
    // Our files are one line; others may have been reformatted.
    final text = StringBuffer(first);
    while (await lines.moveNext()) {
      text
        ..write('\n')
        ..write(lines.current);
    }
    routine = await _saveImported(ref, text.toString());
  } on NewerRoutineFileException {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'This file needs a newer version of the app. Update it and '
          'try again.',
        ),
      ),
    );
    return;
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not import this file.')),
    );
    return;
  } finally {
    // Closes a file not read to the end; nothing to wait for.
    if (lines != null) unawaited(lines.cancel());
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

/// Saves the routine file [text] as a new routine. Nothing is left behind
/// if it fails.
Future<Routine> _saveImported(WidgetRef ref, String text) async {
  final repository = ref.read(routineRepositoryProvider);
  final library = ref.read(musicLibraryProvider);
  final decoded = RoutineFile.decode(
    text,
    id: const Uuid().v4(),
    now: DateTime.now().toUtc(),
  );
  RoutineMusic? stored;
  try {
    if (decoded.music case final music?) {
      stored = await library.addBytes(
        music.bytes,
        extension: music.extension,
        title: music.title,
      );
    }
    final routine = decoded.routine.withMusic(stored);
    await repository.saveRoutine(routine);
    return routine;
  } on Object {
    if (stored != null) await deleteMusicQuietly(library, stored);
    rethrow;
  }
}

/// Deletes the routine with [id] and the app's copy of its music.
Future<void> deleteRoutine(WidgetRef ref, String id) async {
  final repository = ref.read(routineRepositoryProvider);
  final library = ref.read(musicLibraryProvider);
  final music = (await repository.fetchRoutine(id))?.music;
  await repository.deleteRoutine(id);
  if (music != null) await deleteMusicQuietly(library, music);
}

/// A leftover file only wastes space, so failures are ignored.
Future<void> deleteMusicQuietly(
  MusicLibrary library,
  RoutineMusic music,
) async {
  try {
    await library.delete(music);
  } on Object {
    // Ignored.
  }
}
