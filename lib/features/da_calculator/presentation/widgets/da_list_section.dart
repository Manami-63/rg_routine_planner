import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/scoring/score.dart';
import '../../../../core/widgets/message_view.dart';
import '../../../../core/widgets/value_badge.dart';
import '../../../routines/presentation/routine_controller.dart';
import '../../domain/da_element.dart';
import '../../domain/da_scoring_engine.dart';
import '../da_calculator_providers.dart';
import '../da_routine_providers.dart';
import 'da_builder_sheet.dart';
import 'da_symbols.dart';

/// Why an entry is not counted or not valid, or `null` when it counts.
String? describeDaStatus(
  DaElement element,
  DaStatus status,
) => switch (status) {
  DaStatus.valid => null,
  DaStatus.notChosen => 'Tap to choose',
  DaStatus.tooFewCriteria =>
    element.secondBase == null
        ? 'Not a DA: needs 2 criteria'
        : 'Not a DA: needs 1 criterion during both bases',
  DaStatus.otherApparatus =>
    'Not a DA: base for ${element.base.apparatus?.label ?? 'another apparatus'}',
  DaStatus.unknownBase => 'Not a DA: no longer in the catalogue',
  DaStatus.repetition => 'Not valid: identical repetition',
  DaStatus.tooManyPreAcrobatic =>
    'Not valid: more than 3 pre-acrobatic rotations',
};

/// Sliver listing the routine's DA in performance order. Drag the handle
/// to reorder; tap a DA to edit it.
class DaListSection extends ConsumerWidget {
  const DaListSection({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = ref.watch(
      daRoutineProvider(routineId).select((routine) => routine.elements),
    );
    final result = ref.watch(daScoreResultProvider(routineId));
    final apparatus = ref.watch(
      routineProvider(routineId).select((r) => r.apparatus),
    );
    final bases = ref.watch(daBasesProvider).value;
    final muted = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.5);
    final controller = ref.read(routineControllerProvider(routineId).notifier);

    if (elements.isEmpty) {
      return const SliverToBoxAdapter(
        child: MessageView(
          icon: Icons.playlist_add,
          title: 'No DA yet',
          message:
              'Tap "Build a DA" to add them in the order they are '
              'performed.',
        ),
      );
    }

    return SliverReorderableList(
      itemCount: elements.length,
      onReorderItem: controller.moveDa,
      itemBuilder: (context, index) {
        final element = elements[index];
        final status = result.statuses[index];
        final counted = result.isCounted(index);
        final details = [
          if (element.criteriaSummary.isNotEmpty) element.criteriaSummary,
          if (element.manualValue != null && !element.isCustom) 'Manual value',
          ?describeDaStatus(element, status),
          if (status.isDa && !counted) 'Not counted',
          if (result.floorWarnings.contains(index))
            '4th+ in a row on the floor',
        ].join(' · ');
        final valid = status == DaStatus.valid;
        return Material(
          key: ValueKey('da-$index'),
          child: ListTile(
            // Greyed out (but still editable) when it adds nothing.
            textColor: valid && counted ? null : muted,
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (DaSymbols.canShow(element))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: DaSymbols(
                      element,
                      color: valid && counted ? null : muted,
                    ),
                  ),
                Text(element.name),
              ],
            ),
            subtitle: details.isEmpty ? null : Text(details),
            onTap: bases == null
                ? null
                : () => DaBuilderSheet.show(
                    context,
                    routineId: routineId,
                    bases: [
                      for (final base in bases)
                        if (base.apparatus == apparatus) base,
                    ],
                    index: index,
                    initial: element,
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueBadge(value: valid ? result.values[index] : Score.zero),
                IconButton(
                  tooltip: 'Remove DA ${index + 1}',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => controller.removeDaAt(index),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Tooltip(
                    message: 'Drag to reorder',
                    child: const Padding(
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
