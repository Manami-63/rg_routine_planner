import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/router.dart';
import '../../../core/widgets/message_view.dart';
import '../../db_calculator/presentation/db_calculator_providers.dart';
import '../data/routine_repository.dart';
import '../domain/routine.dart';
import '../../routine_editor/presentation/routine_score_providers.dart';
import 'routine_actions.dart';
import 'routine_details_form.dart';
import 'routine_filter.dart';
import 'routine_filter_bar.dart';
import 'routine_providers.dart';

/// "My routines": lists saved routines and creates new ones.
class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(routineSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My routines'),
        actions: [
          IconButton(
            tooltip: 'Import routine',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => importRoutine(context, ref),
          ),
        ],
      ),
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
            : _FilteredRoutines(routines: routines),
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

/// The search and filters, with the routines that match them.
class _FilteredRoutines extends ConsumerWidget {
  const _FilteredRoutines({required this.routines});

  final List<RoutineSummary> routines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = ref.watch(routineFilterProvider).apply(routines);
    return Column(
      children: [
        RoutineFilterBar(routines: routines),
        Expanded(
          child: shown.isEmpty
              ? const NoMatchingRoutines()
              : ListView.builder(
                  // Leave room so the last item is not hidden by the button.
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: shown.length,
                  itemBuilder: (context, index) =>
                      _RoutineTile(summary: shown[index]),
                ),
        ),
      ],
    );
  }
}

enum _RoutineAction { edit, duplicate, share, delete }

class _RoutineTile extends ConsumerWidget {
  const _RoutineTile({required this.summary});

  final RoutineSummary summary;

  String get _displayName => routineDisplayName(summary.name);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Non-breaking spaces keep each part ("0 DA") on one line.
    final details = [
      ?summary.apparatus?.label,
      summary.level?.label ?? 'No level',
      '${summary.elementCount} DB',
      '${summary.riskCount} ${summary.riskCount == 1 ? 'risk' : 'risks'}',
      '${summary.daCount} DA',
    ].map((part) => part.replaceAll(' ', '\u00A0')).join(' · ');

    return ListTile(
      key: ValueKey('routine-${summary.id}'),
      leading: _RoutineTotal(summary: summary),
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
          _RoutineAction.share => shareRoutine(
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
            value: _RoutineAction.share,
            child: ListTile(
              leading: Icon(Icons.share_outlined),
              title: Text('Share'),
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
      await deleteRoutine(ref, summary.id);
    }
  }
}

/// The routine's provisional difficulty total, or a dash while it loads or
/// when it cannot be calculated.
class _RoutineTotal extends ConsumerWidget {
  const _RoutineTotal({required this.summary});

  final RoutineSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref
        .watch(savedRoutineScoreProvider((summary.id, summary.updatedAt)))
        .value;
    final theme = Theme.of(context);
    // Scales down rather than wrapping, e.g. with large text sizes.
    return SizedBox(
      width: 56,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score?.total.format() ?? '–',
              key: ValueKey('routine-total-${summary.id}'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text('total', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
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
