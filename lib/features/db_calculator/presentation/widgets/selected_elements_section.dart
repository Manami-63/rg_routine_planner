import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/message_view.dart';
import '../../../routines/presentation/routine_controller.dart';
import '../db_routine_providers.dart';
import 'adjust_element_sheet.dart';
import 'value_badge.dart';

/// Sliver listing the elements in the routine, or an empty state.
class SelectedElementsSection extends ConsumerWidget {
  const SelectedElementsSection({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = ref.watch(
      dbRoutineProvider(routineId).select((routine) => routine.elements),
    );
    final options = ref.watch(
      dbRoutineProvider(routineId).select((routine) => routine.elementOptions),
    );
    final result = ref.watch(dbScoreResultProvider(routineId));
    final muted = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.5);

    if (elements.isEmpty) {
      return const SliverToBoxAdapter(
        child: MessageView(
          icon: Icons.playlist_add,
          title: 'No elements yet',
          message: 'Tap "Add element" to choose from the catalogue.',
        ),
      );
    }

    return SliverList.builder(
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        final dbs = result.dbPerElement[index];
        final counted = result.counting.countedPerElement[index];
        final details = [
          element.group.label,
          ?describeOptions(element, options[index]),
          if (result.repeatedElements.contains(index))
            'Not valid: repetition'
          else if (counted == 0)
            'Not counted'
          else if (counted < dbs)
            '$counted of $dbs counted',
        ].join(' · ');
        return ListTile(
          key: ValueKey('selected-$index'),
          // Greyed out (but still adjustable and removable) when it does
          // not count.
          textColor: counted > 0 ? null : muted,
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(element.name),
          subtitle: Text(details),
          onTap: () => AdjustElementSheet.show(
            context,
            routineId: routineId,
            index: index,
            element: element,
            options: options[index],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // A series shows its total; a repetition is worth nothing.
              ValueBadge(value: result.elementValues[index] * dbs),
              IconButton(
                tooltip: 'Remove ${element.name}',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => ref
                    .read(routineControllerProvider(routineId).notifier)
                    .removeElementAt(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
