import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/message_view.dart';
import '../../../routines/presentation/routine_controller.dart';
import '../db_routine_providers.dart';
import '../element_picker_screen.dart';
import 'adjust_element_sheet.dart';
import 'db_symbol.dart';
import '../../../../core/widgets/value_badge.dart';

/// Sliver listing the elements in the routine in performance order, or an
/// empty state. Drag the handle to reorder; tap an element to adjust it.
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
    final controller = ref.read(routineControllerProvider(routineId).notifier);

    if (elements.isEmpty) {
      return const SliverToBoxAdapter(
        child: MessageView(
          icon: Icons.playlist_add,
          title: 'No elements yet',
          message: 'Tap "Add element" to choose from the catalogue.',
        ),
      );
    }

    return SliverReorderableList(
      itemCount: elements.length,
      onReorderItem: controller.moveElement,
      itemBuilder: (context, index) {
        final element = elements[index];
        final dbs = result.dbPerElement[index];
        final counted = result.counting.countedPerElement[index];
        final details = [
          if (element.isPending) 'Tap to choose' else element.group.label,
          ?describeOptions(element, options[index]),
          if (result.repeatedElements.contains(index))
            'Not valid: repetition'
          else if (counted == 0 && !element.isPending)
            'Not counted'
          else if (counted < dbs)
            '$counted of $dbs counted',
        ].join(' · ');
        // Material keeps the tile's ink visible while it is dragged.
        return Material(
          key: ValueKey('selected-$index'),
          child: ListTile(
            // Greyed out (but still adjustable and removable) when it does
            // not count.
            textColor: counted > 0 ? null : muted,
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (element.symbolPath case final path?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: DbSymbol(
                      path,
                      label: element.name,
                      cycles: options[index].rotationCycles,
                    ),
                  ),
                Text(element.name),
              ],
            ),
            subtitle: Text(details),
            onTap: () => element.isPending
                ? ElementPickerScreen.show(
                    context,
                    routineId: routineId,
                    replaceIndex: index,
                  )
                : AdjustElementSheet.show(
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
                  onPressed: () => controller.removeElementAt(index),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Tooltip(
                    message: 'Drag to reorder',
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
