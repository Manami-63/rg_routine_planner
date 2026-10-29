import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/message_view.dart';
import '../../../routines/presentation/routine_controller.dart';
import '../db_calculator_providers.dart';
import '../db_routine_providers.dart';
import '../../../../core/widgets/async_sliver.dart';
import '../../../../core/widgets/value_badge.dart';

/// Sliver listing the risks in the routine, or an empty state.
class SelectedRisksSection extends ConsumerWidget {
  const SelectedRisksSection({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final risks = ref.watch(
      dbRoutineProvider(routineId).select((routine) => routine.risks),
    );
    final engine = ref.watch(dbScoringEngineProvider);
    final counting = ref.watch(
      dbScoreResultProvider(routineId).select((result) => result.counting),
    );

    if (risks.isEmpty) {
      return const SliverToBoxAdapter(
        child: MessageView(
          icon: Icons.rotate_right,
          title: 'No risks yet',
          message: 'Build a risk to add it to the routine.',
        ),
      );
    }

    return SliverList.builder(
      itemCount: risks.length,
      itemBuilder: (context, index) {
        final risk = risks[index];
        final counted = counting.isRiskCounted(index);
        return ListTile(
          key: ValueKey('risk-$index'),
          enabled: counted,
          leading: CircleAvatar(child: Text('R${index + 1}')),
          title: Text(risk.description),
          subtitle: counted ? null : const Text('Not counted'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueBadge(value: engine.riskValue(risk)),
              IconButton(
                tooltip: 'Remove risk ${index + 1}',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => ref
                    .read(routineControllerProvider(routineId).notifier)
                    .removeRiskAt(index),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sliver showing the risk options' loading, error and empty states. Once
/// they have loaded it shows nothing: risks are built from the floating
/// "Build a risk" button.
class RiskOptionsStatus extends ConsumerWidget {
  const RiskOptionsStatus({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncSliver(
      value: ref.watch(riskCatalogueProvider),
      loadingLabel: 'Loading risk options',
      errorTitle: 'Could not load risk options',
      onRetry: () => ref.invalidate(riskCatalogueProvider),
      data: (catalogue) => catalogue.isEmpty
          ? const SliverToBoxAdapter(
              child: MessageView(
                icon: Icons.inventory_2_outlined,
                title: 'No risk options',
                message: 'No risk options are available for this ruleset.',
              ),
            )
          : const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}
