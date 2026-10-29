import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../da_calculator/presentation/da_routine_providers.dart';
import '../../da_calculator/presentation/da_tab.dart';
import '../../db_calculator/presentation/db_calculator_providers.dart';
import '../../db_calculator/presentation/db_routine_providers.dart';
import '../../db_calculator/presentation/db_tabs.dart';
import '../../routines/presentation/routine_actions.dart';
import '../../routines/presentation/routine_controller.dart';
import '../../routines/presentation/routine_details_form.dart';
import '../../routines/presentation/routine_loader.dart';
import '../../routines/presentation/save_status_indicator.dart';
import 'routine_total_bar.dart';

/// The tabs of the routine page.
enum RoutineTab {
  db('DB'),
  risks('R'),
  da('DA');

  const RoutineTab(this.label);

  final String label;

  /// The tab named [name] (e.g. from the `tab` query parameter), or DB.
  static RoutineTab fromName(String? name) =>
      values.firstWhere((tab) => tab.name == name, orElse: () => db);
}

/// One saved routine: its name, apparatus and level in the header, and
/// its body difficulties (DB), risks (R) and apparatus difficulties (DA)
/// as tabs, with the provisional total below.
class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({
    super.key,
    required this.routineId,
    this.initialTab = RoutineTab.db,
  });

  final String routineId;
  final RoutineTab initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) => RoutineLoader(
    routineId: routineId,
    title: 'Routine',
    rulesetId: ref.watch(dbScoringEngineProvider).ruleset.id,
    content: (context) => DefaultTabController(
      length: RoutineTab.values.length,
      initialIndex: initialTab.index,
      // A Builder so the parts below can find the tab controller.
      child: Builder(builder: (context) => _RoutinePage(routineId: routineId)),
    ),
  );
}

enum _MenuAction { duplicate, clearDb, clearDa }

class _RoutinePage extends ConsumerWidget {
  const _RoutinePage({required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = DefaultTabController.of(context);
    final dbEmpty = ref.watch(
      dbRoutineProvider(routineId).select((r) => r.isEmpty),
    );
    final daEmpty = ref.watch(
      daRoutineProvider(routineId).select((r) => r.isEmpty),
    );
    final controller = ref.read(routineControllerProvider(routineId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: _RoutineTitle(routineId: routineId),
        actions: [
          SaveStatusIndicator(routineId: routineId),
          IconButton(
            tooltip: 'Edit details',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editDetails(context, ref),
          ),
          PopupMenuButton<_MenuAction>(
            tooltip: 'More options',
            onSelected: (action) => switch (action) {
              _MenuAction.duplicate => duplicateRoutine(
                context,
                ref,
                () async => ref.read(routineProvider(routineId)),
              ),
              _MenuAction.clearDb => _confirmClear(
                context,
                title: 'Clear DB and risks?',
                message:
                    'This removes all body difficulties and risks. DA, the '
                    'routine name, apparatus and level are kept.',
                onClear: controller.clearDb,
              ),
              _MenuAction.clearDa => _confirmClear(
                context,
                title: 'Clear DA?',
                message:
                    'This removes all DA. Body difficulties, risks, the '
                    'routine name, apparatus and level are kept.',
                onClear: controller.clearDa,
              ),
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _MenuAction.duplicate,
                child: ListTile(
                  leading: Icon(Icons.copy_outlined),
                  title: Text('Duplicate'),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.clearDb,
                enabled: !dbEmpty,
                child: const ListTile(
                  leading: Icon(Icons.delete_sweep_outlined),
                  title: Text('Clear DB and risks'),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.clearDa,
                enabled: !daEmpty,
                child: const ListTile(
                  leading: Icon(Icons.delete_sweep_outlined),
                  title: Text('Clear DA'),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          tabs: [for (final tab in RoutineTab.values) Tab(text: tab.label)],
        ),
      ),
      body: TabBarView(
        children: [
          DbBodyTab(routineId: routineId),
          DbRisksTab(routineId: routineId),
          DaTab(routineId: routineId),
        ],
      ),
      // The add button and the total's breakdown follow the selected tab.
      floatingActionButton: ListenableBuilder(
        listenable: tabs,
        builder: (context, _) => switch (RoutineTab.values[tabs.index]) {
          RoutineTab.db => AddElementButton(routineId: routineId),
          RoutineTab.risks => BuildRiskButton(routineId: routineId),
          RoutineTab.da => BuildDaButton(routineId: routineId),
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: tabs,
        builder: (context, _) => RoutineTotalBar(
          routineId: routineId,
          showDa: tabs.index == RoutineTab.da.index,
        ),
      ),
    );
  }

  Future<void> _editDetails(BuildContext context, WidgetRef ref) async {
    final details = await RoutineDetailsForm.edit(
      context,
      ref.read(routineProvider(routineId)),
    );
    if (details == null) return;
    ref
        .read(routineControllerProvider(routineId).notifier)
        .updateDetails(details);
  }

  Future<void> _confirmClear(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onClear,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onClear();
  }
}

/// The routine's name, with its apparatus and level underneath.
class _RoutineTitle extends ConsumerWidget {
  const _RoutineTitle({required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (name, apparatus, level) = ref.watch(
      routineProvider(routineId).select((r) => (r.name, r.apparatus, r.level)),
    );
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          routineDisplayName(name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          describeRoutineDetails(apparatus, level),
          key: const ValueKey('routine-details'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
