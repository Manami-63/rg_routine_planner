import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routines/presentation/routine_controller.dart';
import '../../domain/risk.dart';
import '../db_calculator_providers.dart';
import '../db_routine_providers.dart';
import 'value_badge.dart';

/// Bottom sheet for composing a risk from a rotation option and criteria.
///
/// The half-built risk is local widget state (not Riverpod): it only
/// matters while the sheet is open, and is discarded if the user cancels.
class RiskBuilderSheet extends ConsumerStatefulWidget {
  const RiskBuilderSheet({super.key, required this.catalogue});

  final RiskCatalogue catalogue;

  static Future<void> show(BuildContext context, RiskCatalogue catalogue) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => RiskBuilderSheet(catalogue: catalogue),
    );
  }

  @override
  ConsumerState<RiskBuilderSheet> createState() => _RiskBuilderSheetState();
}

class _RiskBuilderSheetState extends ConsumerState<RiskBuilderSheet> {
  late RiskRotationOption _rotation = widget.catalogue.rotationOptions.first;
  final Set<RiskCriterion> _criteria = {};

  RiskElement get _risk => RiskElement(
    rotation: _rotation,
    // Keep catalogue order regardless of tap order.
    criteria: widget.catalogue.criteria.where(_criteria.contains).toList(),
  );

  void _add() {
    ref.read(routineControllerProvider.notifier).addRisk(_risk);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = ref.watch(dbScoringEngineProvider).riskValue(_risk);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Build a risk', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Text('Rotations', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in widget.catalogue.rotationOptions)
                  ChoiceChip(
                    label: Text(option.label),
                    selected: option == _rotation,
                    onSelected: (_) => setState(() => _rotation = option),
                  ),
              ],
            ),
            if (widget.catalogue.criteria.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Criteria', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final criterion in widget.catalogue.criteria)
                    FilterChip(
                      label: Text(criterion.name),
                      selected: _criteria.contains(criterion),
                      onSelected: (selected) => setState(
                        () => selected
                            ? _criteria.add(criterion)
                            : _criteria.remove(criterion),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text('Risk value', style: theme.textTheme.titleMedium),
                ),
                ValueBadge(
                  key: const ValueKey('risk-preview-value'),
                  value: value,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('Add risk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
