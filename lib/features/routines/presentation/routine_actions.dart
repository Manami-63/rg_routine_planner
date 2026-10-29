import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/router.dart';
import '../../music/presentation/music_providers.dart';
import '../domain/routine.dart';
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

/// Deletes the routine with [id] and the app's copy of its music.
Future<void> deleteRoutine(WidgetRef ref, String id) async {
  final repository = ref.read(routineRepositoryProvider);
  final library = ref.read(musicLibraryProvider);
  final music = (await repository.fetchRoutine(id))?.music;
  await repository.deleteRoutine(id);
  if (music != null) {
    try {
      await library.delete(music);
    } on Object {
      // A leftover file only wastes space.
    }
  }
}
