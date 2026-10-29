import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/router.dart';
import '../domain/routine.dart';
import 'routine_details_form.dart';
import 'routine_providers.dart';

/// Saves a copy of the routine from [load] (DB, DA, apparatus and level)
/// named "`name` (copy)", then offers to open it. Used from My routines and
/// from the routine page.
Future<void> duplicateRoutine(
  BuildContext context,
  WidgetRef ref,
  Future<Routine?> Function() load,
) async {
  final repository = ref.read(routineRepositoryProvider);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.maybeOf(context);
  final Routine copy;
  try {
    final original = await load();
    if (original == null) throw StateError('Routine not found');
    copy = original.duplicate(
      id: const Uuid().v4(),
      name: '${routineDisplayName(original.name)} (copy)',
      now: DateTime.now().toUtc(),
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
