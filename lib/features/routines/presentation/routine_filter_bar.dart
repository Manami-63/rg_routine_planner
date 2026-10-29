import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/message_view.dart';
import '../data/routine_repository.dart';
import 'routine_filter.dart';

/// Search field and filter chips above My routines. Chips are offered only
/// for apparatus and levels that [routines] use, and only when there is
/// more than one to choose from (or one is selected, so it can be cleared).
class RoutineFilterBar extends ConsumerStatefulWidget {
  const RoutineFilterBar({super.key, required this.routines});

  /// All routines, before filtering.
  final List<RoutineSummary> routines;

  @override
  ConsumerState<RoutineFilterBar> createState() => _RoutineFilterBarState();
}

class _RoutineFilterBarState extends ConsumerState<RoutineFilterBar> {
  late final _search = TextEditingController(
    text: ref.read(routineFilterProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // "Clear filters" also empties the field.
    ref.listen(routineFilterProvider.select((f) => f.query), (_, query) {
      if (_search.text != query) _search.text = query;
    });
    final filter = ref.watch(routineFilterProvider);
    final notifier = ref.read(routineFilterProvider.notifier);

    final apparatuses = {for (final r in widget.routines) ?r.apparatus}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    // Level ids with their labels, levels before "No level".
    final levels = <String, String>{
      for (final r in widget.routines)
        if (r.level != null) r.level!.id: r.level!.label,
    };
    final sortedLevels = levels.keys.toList()
      ..sort((a, b) => levels[a]!.compareTo(levels[b]!));
    if (widget.routines.any((r) => r.level == null)) {
      sortedLevels.add(RoutineFilter.noLevel);
    }

    final chips = [
      if (apparatuses.length > 1 || filter.apparatus != null)
        for (final apparatus in apparatuses)
          _chip(
            label: apparatus.label,
            selected: filter.apparatus == apparatus,
            onSelected: (on) => notifier.filterApparatus(on ? apparatus : null),
          ),
      if (sortedLevels.length > 1 || filter.levelId != null)
        for (final id in sortedLevels)
          _chip(
            label: levels[id] ?? 'No level',
            selected: filter.levelId == id,
            onSelected: (on) => notifier.filterLevel(on ? id : null),
          ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SearchBar(
            controller: _search,
            hintText: 'Search names and notes',
            leading: const Icon(Icons.search),
            trailing: [
              if (filter.query.isNotEmpty)
                IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () => notifier.search(''),
                ),
            ],
            elevation: const WidgetStatePropertyAll(0),
            onChanged: notifier.search,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
        ),
        if (chips.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                for (final chip in chips) ...[chip, const SizedBox(width: 8)],
              ],
            ),
          ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) => FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: onSelected,
  );
}

/// Shown when no routine matches the filter.
class NoMatchingRoutines extends ConsumerWidget {
  const NoMatchingRoutines({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: MessageView(
      icon: Icons.search_off,
      title: 'No matching routines',
      message: 'Try other words or clear the filters.',
      action: FilledButton.tonal(
        onPressed: ref.read(routineFilterProvider.notifier).clear,
        child: const Text('Clear filters'),
      ),
    ),
  );
}
