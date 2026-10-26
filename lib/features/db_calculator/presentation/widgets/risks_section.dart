import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/message_view.dart';
import '../db_calculator_providers.dart';
import 'async_sliver.dart';
import 'risk_builder_sheet.dart';
import 'value_badge.dart';

/// Sliver listing the risks in the routine, or an empty state.
class SelectedRisksSection extends ConsumerWidget {
  const SelectedRisksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final risks = ref.watch(
      dbRoutineControllerProvider.select((routine) => routine.risks),
    );
    final engine = ref.watch(dbScoringEngineProvider);

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
        return ListTile(
          key: ValueKey('risk-$index'),
          leading: CircleAvatar(child: Text('R${index + 1}')),
          title: Text(risk.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueBadge(value: engine.riskValue(risk)),
              IconButton(
                tooltip: 'Remove risk ${index + 1}',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => ref
                    .read(dbRoutineControllerProvider.notifier)
                    .removeRiskAt(index),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sliver with the "Build a risk" action, once the risk catalogue loads.
class BuildRiskAction extends ConsumerWidget {
  const BuildRiskAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncSliver(
      value: ref.watch(riskCatalogueProvider),
      loadingLabel: 'Loading risk options',
      errorTitle: 'Could not load risk options',
      onRetry: () => ref.invalidate(riskCatalogueProvider),
      data: (catalogue) {
        if (catalogue.isEmpty) {
          return const SliverToBoxAdapter(
            child: MessageView(
              icon: Icons.inventory_2_outlined,
              title: 'No risk options',
              message: 'No risk options are available for this ruleset.',
            ),
          );
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: FilledButton.tonalIcon(
              onPressed: () => RiskBuilderSheet.show(context, catalogue),
              icon: const Icon(Icons.add),
              label: const Text('Build a risk'),
            ),
          ),
        );
      },
    );
  }
}
