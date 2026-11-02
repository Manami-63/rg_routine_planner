import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/symbols/path_symbol_view.dart';
import '../../../core/widgets/message_view.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/db_element.dart';
import 'db_calculator_providers.dart';
import 'db_routine_providers.dart';
import '../../../core/widgets/async_sliver.dart';
import 'widgets/custom_element_sheet.dart';
import '../../../core/widgets/value_badge.dart';

/// Whether [element] matches a search: every word of [query] must appear
/// in its name or family (codes are part of the name, e.g. "2.203").
bool matchesQuery(DbElement element, String query) {
  final text = '${element.name} ${element.family ?? ''}'.toLowerCase();
  return query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .every(text.contains);
}

/// The body group the picker last showed, so reopening it continues where
/// the user left off. Kept for the app session only.
final pickerGroupProvider = NotifierProvider<PickerGroup, DbElementGroup>(
  PickerGroup.new,
);

class PickerGroup extends Notifier<DbElementGroup> {
  @override
  DbElementGroup build() => DbElementGroup.jump;

  void select(DbElementGroup group) => state = group;
}

/// Full-screen catalogue for adding DB to a routine: one body group at a
/// time, narrowed by a search, sectioned by catalogue row. Stays open so
/// several elements can be added in a row, unless [addOne] is set.
class ElementPickerScreen extends ConsumerStatefulWidget {
  const ElementPickerScreen({
    super.key,
    required this.routineId,
    this.addOne = false,
  });

  final String routineId;

  /// Closes after one element is added (adding at a moment in the music).
  final bool addOne;

  static Future<void> show(
    BuildContext context, {
    required String routineId,
    bool addOne = false,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) =>
            ElementPickerScreen(routineId: routineId, addOne: addOne),
      ),
    );
  }

  @override
  ConsumerState<ElementPickerScreen> createState() =>
      _ElementPickerScreenState();
}

class _ElementPickerScreenState extends ConsumerState<ElementPickerScreen> {
  final _search = TextEditingController();

  // Its own messenger, so "Added ..." messages close with the picker.
  final _messenger = GlobalKey<ScaffoldMessengerState>();

  String get _query => _search.text.trim();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _add(DbElement element) {
    ref
        .read(routineControllerProvider(widget.routineId).notifier)
        .addElement(element);
    if (widget.addOne) {
      Navigator.of(context).pop();
      return;
    }
    _messenger.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Added ${element.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  Future<void> _addCustom() async {
    final count = ref.read(dbRoutineProvider(widget.routineId)).elements.length;
    await CustomElementSheet.show(context, routineId: widget.routineId);
    if (!mounted || !widget.addOne) return;
    final added =
        ref.read(dbRoutineProvider(widget.routineId)).elements.length > count;
    if (added) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(key: _messenger, child: _buildScaffold(context));
  }

  Widget _buildScaffold(BuildContext context) {
    final group = ref.watch(pickerGroupProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add element'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search name or code, e.g. 2.203',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(_search.clear),
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Search narrows the selected group; it does not replace it.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<DbElementGroup>(
                showSelectedIcon: false,
                segments: [
                  for (final group in DbElementGroup.requirable)
                    ButtonSegment(value: group, label: Text(group.label)),
                ],
                selected: {group},
                onSelectionChanged: (selection) => ref
                    .read(pickerGroupProvider.notifier)
                    .select(selection.single),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: CustomScrollView(
              slivers: [
                AsyncSliver(
                  value: ref.watch(dbElementsProvider),
                  loadingLabel: 'Loading catalogue',
                  errorTitle: 'Could not load the catalogue',
                  onRetry: () => ref.invalidate(dbElementsProvider),
                  data: _buildElements,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: OutlinedButton.icon(
                      onPressed: _addCustom,
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Add an element not in the list'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElements(List<DbElement> catalogue) {
    if (catalogue.isEmpty) {
      return const SliverToBoxAdapter(
        child: MessageView(
          icon: Icons.inventory_2_outlined,
          title: 'Catalogue is empty',
          message: 'No elements are available for this ruleset.',
        ),
      );
    }

    final group = ref.watch(pickerGroupProvider);
    final query = _query;
    final matching = [
      for (final element in catalogue)
        if (matchesQuery(element, query)) element,
    ];
    final shown = [
      for (final element in matching)
        if (element.group == group) element,
    ];
    if (shown.isEmpty) {
      // Point to the groups that do have matches, so a search is not a
      // dead end.
      final elsewhere = [
        for (final group in DbElementGroup.requirable)
          if (matching.where((e) => e.group == group).length case final count
              when count > 0)
            '${group.label} ($count)',
      ];
      return SliverToBoxAdapter(
        child: MessageView(
          icon: Icons.search_off,
          title: 'No matches in ${group.label}',
          message: elsewhere.isEmpty
              ? 'Try another word or code, or add it yourself below.'
              : 'Found in: ${elsewhere.join(', ')}',
        ),
      );
    }

    final inRoutine = ref.watch(
      dbRoutineProvider(widget.routineId)
          .select((routine) => {for (final e in routine.elements) e.id}),
    );
    final theme = Theme.of(context);
    final children = <Widget>[];
    String? currentFamily;
    for (final element in shown) {
      // A header whenever a new catalogue row starts.
      final family = element.family;
      if (family != null && family != currentFamily) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              family,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      }
      currentFamily = family;
      children.add(_tile(element, inRoutine.contains(element.id)));
    }
    return SliverList.list(children: children);
  }

  Widget _tile(DbElement element, bool inRoutine) => ListTile(
    key: ValueKey('catalogue-${element.id}'),
    leading: switch (element.symbolPath) {
      null => null,
      final path => PathSymbolView(path, label: element.name, size: 28),
    },
    title: Text(element.name),
    // Adding it again would be a repetition (unless in a series).
    subtitle: inRoutine ? const Text('In your routine') : null,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueBadge(value: element.value),
        IconButton(
          tooltip: 'Add ${element.name}',
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _add(element),
        ),
      ],
    ),
  );
}
