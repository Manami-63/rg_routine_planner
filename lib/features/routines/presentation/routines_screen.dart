import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/router.dart';
import '../../../core/widgets/message_view.dart';
import '../../db_calculator/presentation/db_calculator_providers.dart';
import '../data/routine_repository.dart';
import '../domain/routine.dart';
import 'routine_actions.dart';
import 'routine_details_form.dart';
import 'routine_providers.dart';

/// "My routines": lists saved routines and creates new ones.
class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(routineSummariesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My routines')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createRoutine(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New routine'),
      ),
      body: summaries.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading routines'),
        ),
        error: (error, _) => Center(
          child: MessageView(
            icon: Icons.error_outline,
            isError: true,
            title: 'Could not load routines',
            message: 'Please try again.',
            action: FilledButton.tonalIcon(
              onPressed: () => ref.invalidate(routineSummariesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ),
        data: (routines) => routines.isEmpty
            ? const Center(
                child: MessageView(
                  icon: Icons.event_note_outlined,
                  title: 'No routines yet',
                  message: 'Tap "New routine" to start planning.',
                ),
              )
            : ListView.builder(
                // Leave room so the last item is not hidden by the button.
                padding: const EdgeInsets.only(top: 8, bottom: 96),
                itemCount: routines.length,
                itemBuilder: (context, index) =>
                    _RoutineTile(summary: routines[index]),
              ),
      ),
    );
  }

  /// Asks for the name, apparatus and level, then saves the new routine
  /// and opens it. Saving first means it appears in the list even if the
  /// user leaves straight away.
  Future<void> _createRoutine(BuildContext context, WidgetRef ref) async {
    final details = await RoutineDetailsForm.create(context);
    if (details == null || !context.mounted) return;
    final routine = details.applyTo(
      Routine.create(
        id: const Uuid().v4(),
        rulesetId: ref.read(dbScoringEngineProvider).ruleset.id,
        now: DateTime.now().toUtc(),
      ),
    );
    try {
      await ref.read(routineRepositoryProvider).saveRoutine(routine);
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create the routine.')),
      );
      return;
    }
    if (!context.mounted) return;
    context.go(AppRoutes.routine(routine.id));
  }
}

enum _RoutineAction { edit, duplicate, delete }

class _RoutineTile extends ConsumerWidget {
  const _RoutineTile({required this.summary});

  final RoutineSummary summary;

  String get _displayName => routineDisplayName(summary.name);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = [
      ?summary.apparatus?.label,
      summary.level?.label ?? 'No level',
      '${summary.elementCount} DB',
      '${summary.riskCount} ${summary.riskCount == 1 ? 'risk' : 'risks'}',
      '${summary.daCount} DA',
    ].join(' · ');

    return ListTile(
      key: ValueKey('routine-${summary.id}'),
      title: Text(_displayName),
      subtitle: Text('$details\nUpdated ${formatDateTime(summary.updatedAt)}'),
      isThreeLine: true,
      trailing: PopupMenuButton<_RoutineAction>(
        tooltip: 'Options for $_displayName',
        onSelected: (action) => switch (action) {
          _RoutineAction.edit => _edit(context, ref),
          _RoutineAction.duplicate => duplicateRoutine(
            context,
            ref,
            () => ref.read(routineRepositoryProvider).fetchRoutine(summary.id),
          ),
          _RoutineAction.delete => _confirmDelete(context, ref),
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _RoutineAction.edit,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit details'),
            ),
          ),
          PopupMenuItem(
            value: _RoutineAction.duplicate,
            child: ListTile(
              leading: Icon(Icons.copy_outlined),
              title: Text('Duplicate'),
            ),
          ),
          PopupMenuItem(
            value: _RoutineAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Delete'),
            ),
          ),
        ],
      ),
      onTap: () => context.go(AppRoutes.routine(summary.id)),
    );
  }

  /// Edits the name, apparatus and level without opening the routine.
  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(routineRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    Routine? routine;
    try {
      routine = await repository.fetchRoutine(summary.id);
    } on Object {
      routine = null;
    }
    if (!context.mounted) return;
    if (routine == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the routine.')),
      );
      return;
    }
    final details = await RoutineDetailsForm.edit(context, routine);
    if (details == null) return;
    try {
      await repository.saveRoutine(
        details.applyTo(routine).withUpdatedAt(DateTime.now().toUtc()),
      );
    } on Object {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save the changes.')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "$_displayName"?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(routineRepositoryProvider).deleteRoutine(summary.id);
    }
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// e.g. "26 Oct 2026, 14:05" in local time. Avoids adding the `intl`
/// package for a single format.
String formatDateTime(DateTime time) {
  final local = time.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_months[local.month - 1]} ${local.year}, $hh:$mm';
}
