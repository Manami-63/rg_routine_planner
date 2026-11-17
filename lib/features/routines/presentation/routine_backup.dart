import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../music/domain/routine_music.dart';
import '../../music/presentation/music_providers.dart';
import '../domain/routine_file.dart';
import 'routine_actions.dart';
import 'routine_providers.dart';

/// Offers every routine as one backup file ([RoutineFile.backupHeader]),
/// asking first whether the music goes too, with its size. Routines are
/// loaded one at a time while the file is written, so a backup with music
/// never has to fit in memory.
Future<void> backUpAllRoutines(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(routineRepositoryProvider);
  final library = ref.read(musicLibraryProvider);
  final transfer = ref.read(routineFileTransferProvider);
  final messenger = ScaffoldMessenger.of(context);
  final box = context.findRenderObject()! as RenderBox;
  final origin = box.localToGlobal(Offset.zero) & box.size;
  try {
    final summaries = await repository.watchRoutineSummaries().first;
    if (summaries.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('There are no routines to back up.')),
      );
      return;
    }
    var tracks = 0, bytes = 0;
    for (final summary in summaries) {
      final music = (await repository.fetchRoutine(summary.id))?.music;
      if (music == null) continue;
      if (await library.sizeOf(music) case final size?) {
        tracks++;
        bytes += size;
      }
    }
    var includeMusic = false;
    if (tracks > 0) {
      if (!context.mounted) return;
      final include = await _askIncludeMusic(context, tracks, bytes);
      if (include == null) return;
      includeMusic = include;
    }

    final now = DateTime.now();
    Stream<String> lines() async* {
      yield RoutineFile.backupHeader(count: summaries.length, now: now);
      for (final summary in summaries) {
        final routine = await repository.fetchRoutine(summary.id);
        // Deleted while the backup was being made.
        if (routine == null) continue;
        final music = routine.music;
        yield RoutineFile.backupLine(
          routine,
          music:
              includeMusic &&
                  music != null &&
                  await library.pathOf(music) != null
              ? await sharedMusicOf(library, music)
              : null,
        );
      }
    }

    await transfer.share(
      fileName: RoutineFile.backupFileNameFor(now),
      lines: lines(),
      origin: origin,
    );
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not back up the routines.')),
    );
  }
}

/// `null` if the user dismissed the question.
Future<bool?> _askIncludeMusic(BuildContext context, int tracks, int bytes) {
  final megabytes = bytes / (1024 * 1024);
  final size = megabytes < 1 ? 'under 1 MB' : 'about ${megabytes.ceil()} MB';
  final what = tracks == 1 ? '1 track' : '$tracks tracks';
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Include the music?'),
      content: Text(
        'The music is $what, $size. With it, restoring gives everything '
        'back, ready for Play mode. Without it the backup is small, and each '
        'track is added again after restoring (marked times are kept).',
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
}

/// Restores the routines in [lines] (a backup after its header line, with
/// [count] routines), one at a time. A routine that is not on this device
/// is added with its id and dates; one that is here is replaced only if
/// the backup's version was edited later, so restoring never loses newer
/// work. A routine without music in the backup keeps the music it has
/// here. Reports what happened, also when it stops part way.
Future<void> restoreBackup(
  WidgetRef ref,
  StreamIterator<String> lines, {
  required int count,
  required ScaffoldMessengerState messenger,
}) async {
  final repository = ref.read(routineRepositoryProvider);
  final library = ref.read(musicLibraryProvider);
  var added = 0, updated = 0, kept = 0;
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        'Restoring ${count == 1 ? '1 routine' : '$count routines'}…',
      ),
      duration: const Duration(minutes: 10),
    ),
  );
  try {
    while (await lines.moveNext()) {
      if (lines.current.trim().isEmpty) continue;
      final decoded = RoutineFile.decodeBackupLine(lines.current);
      final backedUp = decoded.routine;
      final existing = await repository.fetchRoutine(backedUp.id);
      if (existing != null && !backedUp.updatedAt.isAfter(existing.updatedAt)) {
        kept++;
        continue;
      }
      RoutineMusic? stored;
      try {
        if (decoded.music case final music?) {
          stored = await library.addBytes(
            music.bytes,
            extension: music.extension,
            title: music.title,
          );
        }
        await repository.saveRoutine(
          backedUp.withMusic(stored ?? existing?.music),
        );
      } on Object {
        if (stored != null) await deleteMusicQuietly(library, stored);
        rethrow;
      }
      if (existing == null) {
        added++;
      } else {
        updated++;
        // Replaced by the backup's track.
        final old = existing.music;
        if (stored != null && old != null) {
          await deleteMusicQuietly(library, old);
        }
      }
    }
  } on Object catch (error) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            error is NewerRoutineFileException
                ? 'This backup needs a newer version of the app. Update it '
                      'and try again.'
                : added + updated == 0
                ? 'Could not restore this backup.'
                : 'Restoring stopped part way '
                      '(${_summary(added, updated, kept)}). The file may be '
                      'damaged.',
          ),
        ),
      );
    return;
  }
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          added + updated == 0
              ? 'Nothing to restore: the routines here are up to date.'
              : 'Restored the backup: ${_summary(added, updated, kept)}',
        ),
      ),
    );
}

String _summary(int added, int updated, int kept) => [
  if (added > 0) '$added added',
  if (updated > 0) '$updated updated',
  if (kept > 0) '$kept already up to date',
].join(', ');
