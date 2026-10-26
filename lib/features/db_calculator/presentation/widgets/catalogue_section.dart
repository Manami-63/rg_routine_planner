import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/message_view.dart';
import '../../../routines/presentation/routine_controller.dart';
import '../../domain/db_element.dart';
import '../db_calculator_providers.dart';
import '../db_routine_providers.dart';
import 'async_sliver.dart';
import 'value_badge.dart';

/// Sliver showing the element catalogue grouped by family, with loading,
/// error and empty states.
class CatalogueSection extends ConsumerWidget {
  const CatalogueSection({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncSliver(
      value: ref.watch(dbElementsProvider),
      loadingLabel: 'Loading catalogue',
      errorTitle: 'Could not load the catalogue',
      onRetry: () => ref.invalidate(dbElementsProvider),
      data: (elements) {
        if (elements.isEmpty) {
          return const SliverToBoxAdapter(
            child: MessageView(
              icon: Icons.inventory_2_outlined,
              title: 'Catalogue is empty',
              message: 'No elements are available for this ruleset.',
            ),
          );
        }
        return SliverList.list(
          children: _buildGroupedTiles(context, ref, elements),
        );
      },
    );
  }

  List<Widget> _buildGroupedTiles(
    BuildContext context,
    WidgetRef ref,
    List<DbElement> elements,
  ) {
    final theme = Theme.of(context);
    return [
      for (final group in DbElementGroup.values)
        if (elements.any((e) => e.group == group)) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              group.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          for (final element in elements.where((e) => e.group == group))
            ListTile(
              key: ValueKey('catalogue-${element.id}'),
              title: Text(element.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueBadge(value: element.value),
                  IconButton(
                    tooltip: 'Add ${element.name}',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => ref
                        .read(routineControllerProvider(routineId).notifier)
                        .addElement(element),
                  ),
                ],
              ),
            ),
        ],
    ];
  }
}
