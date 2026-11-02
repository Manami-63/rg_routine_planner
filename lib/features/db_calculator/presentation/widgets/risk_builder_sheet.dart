import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/symbols/rg_symbol_view.dart';
import '../../../routines/presentation/routine_controller.dart';
import '../../domain/risk.dart';
import '../db_calculator_providers.dart';
import '../db_routine_providers.dart';
import '../../../../core/widgets/value_badge.dart';

/// Bottom sheet for composing a risk the way it is performed: the throw,
/// the rotations under the flight, and the catch.
///
/// Criteria are filtered by the routine's apparatus. The half-built risk is
/// local widget state (not Riverpod): it only matters while the sheet is
/// open, and is discarded if the user cancels.
class RiskBuilderSheet extends ConsumerStatefulWidget {
  const RiskBuilderSheet({
    super.key,
    required this.routineId,
    required this.catalogue,
    this.index,
  });

  final String routineId;
  final RiskCatalogue catalogue;

  /// The risk it replaces, or `null` to add one.
  final int? index;

  static Future<void> show(
    BuildContext context, {
    required String routineId,
    required RiskCatalogue catalogue,
    int? index,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => RiskBuilderSheet(
        routineId: routineId,
        catalogue: catalogue,
        index: index,
      ),
    );
  }

  @override
  ConsumerState<RiskBuilderSheet> createState() => _RiskBuilderSheetState();
}

class _RiskBuilderSheetState extends ConsumerState<RiskBuilderSheet> {
  int _rotationIndex = 0;
  final Set<RiskCriterion> _criteria = {};

  List<RiskRotationOption> get _options => widget.catalogue.rotationOptions;

  RiskElement get _risk => RiskElement(
    rotation: _options[_rotationIndex],
    // Keep catalogue order regardless of tap order.
    criteria: widget.catalogue.criteria.where(_criteria.contains).toList(),
  );

  void _add() {
    final controller = ref.read(
      routineControllerProvider(widget.routineId).notifier,
    );
    if (widget.index case final index?) {
      controller.replaceRiskAt(index, _risk);
    } else {
      controller.addRisk(_risk);
    }
    Navigator.of(context).pop();
  }

  void _toggle(RiskCriterion criterion, bool selected) => setState(
    () => selected ? _criteria.add(criterion) : _criteria.remove(criterion),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = ref.watch(dbScoringEngineProvider).riskValue(_risk);
    final apparatus = ref.watch(
      routineProvider(widget.routineId).select((r) => r.apparatus),
    );
    final rotation = _options[_rotationIndex];

    List<Widget> criteriaOf(RiskPhase phase) => [
      for (final criterion in widget.catalogue.criteriaFor(phase, apparatus))
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          title: Text(criterion.name),
          subtitle: criterion.note == null ? null : Text(criterion.note!),
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (criterion.symbol case final symbol?) ...[
                RgSymbolView(symbol, size: 22),
                const SizedBox(width: 8),
              ],
              ValueBadge(value: criterion.value),
            ],
          ),
          value: _criteria.contains(criterion),
          onChanged: (selected) => _toggle(criterion, selected ?? false),
        ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Build a risk', style: theme.textTheme.titleLarge),
            if (apparatus == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Choose an apparatus to see its specific criteria.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            _PhaseHeader(RiskPhase.throwing.label),
            ...criteriaOf(RiskPhase.throwing),
            _PhaseHeader(RiskPhase.rotations.label),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '2 base rotations, + each additional rotation',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Fewer rotations',
                  icon: const Icon(Icons.remove),
                  onPressed: _rotationIndex == 0
                      ? null
                      : () => setState(() => _rotationIndex--),
                ),
                Text(
                  '${rotation.rotations}',
                  key: const ValueKey('risk-rotations'),
                  style: theme.textTheme.titleMedium,
                ),
                IconButton(
                  tooltip: 'More rotations',
                  icon: const Icon(Icons.add),
                  onPressed: _rotationIndex == _options.length - 1
                      ? null
                      : () => setState(() => _rotationIndex++),
                ),
                ValueBadge(value: rotation.value),
              ],
            ),
            ...criteriaOf(RiskPhase.rotations),
            _PhaseHeader(RiskPhase.catching.label),
            ...criteriaOf(RiskPhase.catching),
            const SizedBox(height: 16),
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

class _PhaseHeader extends StatelessWidget {
  const _PhaseHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(title, style: Theme.of(context).textTheme.labelLarge),
  );
}
