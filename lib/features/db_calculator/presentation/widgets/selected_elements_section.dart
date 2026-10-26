import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/message_view.dart';
import '../db_calculator_providers.dart';
import 'value_badge.dart';

/// Sliver listing the elements in the routine, or an empty state.
class SelectedElementsSection extends ConsumerWidget {
  const SelectedElementsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = ref.watch(
      dbRoutineControllerProvider.select((routine) => routine.elements),
    );

    if (elements.isEmpty) {
      return const SliverToBoxAdapter(
        child: MessageView(
          icon: Icons.playlist_add,
          title: 'No elements yet',
          message: 'Add elements from the catalogue below.',
        ),
      );
    }

    return SliverList.builder(
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        return ListTile(
          key: ValueKey('selected-$index'),
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(element.name),
          subtitle: Text(element.group.label),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueBadge(value: element.value),
              IconButton(
                tooltip: 'Remove ${element.name}',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => ref
                    .read(dbRoutineControllerProvider.notifier)
                    .removeAt(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
