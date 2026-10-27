import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/router.dart';
import '../../../core/widgets/message_view.dart';
import '../../db_calculator/presentation/db_calculator_providers.dart';
import '../data/routine_repository.dart';
import '../domain/routine.dart';
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

  /// Creates and saves an empty routine, then opens it. Saving first means
  /// it appears in the list even if the user leaves straight away.
  Future<void> _createRoutine(BuildContext context, WidgetRef ref) async {
    final routine = Routine.create(
      id: const Uuid().v4(),
      rulesetId: ref.read(dbScoringEngineProvider).ruleset.id,
      now: DateTime.now().toUtc(),
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
    context.go(AppRoutes.dbCalculator(routine.id));
  }
}

class _RoutineTile extends ConsumerWidget {
  const _RoutineTile({required this.summary});

  final RoutineSummary summary;

  String get _displayName =>
      summary.name.trim().isEmpty ? 'Untitled routine' : summary.name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = [
      ?summary.apparatus?.label,
      summary.level?.label ?? 'No level',
      '${summary.elementCount} DB',
      '${summary.riskCount} ${summary.riskCount == 1 ? 'risk' : 'risks'}',
    ].join(' · ');

    return ListTile(
      key: ValueKey('routine-${summary.id}'),
      title: Text(_displayName),
      subtitle: Text('$details\nUpdated ${formatDateTime(summary.updatedAt)}'),
      isThreeLine: true,
      trailing: IconButton(
        tooltip: 'Delete $_displayName',
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, ref),
      ),
      onTap: () => context.go(AppRoutes.dbCalculator(summary.id)),
    );
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
