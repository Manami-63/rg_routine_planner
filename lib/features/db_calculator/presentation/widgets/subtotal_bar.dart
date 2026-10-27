import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/db_scoring_engine.dart';
import '../db_routine_providers.dart';

/// Sticky bottom bar with the provisional DB subtotal and its breakdown.
class SubtotalBar extends ConsumerWidget {
  const SubtotalBar({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(dbScoreResultProvider(routineId));
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isProvisional = result.notices.isNotEmpty;
    final detailStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Material(
      color: colors.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isProvisional ? 'Provisional DB subtotal' : 'DB subtotal',
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      'Body ${result.bodySubtotal.format()}'
                      '${_countedOf(result.countedElementCount, result.elementCount)}'
                      ' · Risks ${result.riskSubtotal.format()}'
                      '${_countedOf(result.countedRiskCount, result.riskCount)}',
                      key: const ValueKey('db-breakdown'),
                      style: detailStyle,
                    ),
                    Text(
                      [
                        result.ruleset.label,
                        if (result.notices.contains(
                          DbScoreNotice.rulesNotValidated,
                        ))
                          result.countLimitsApplied
                              ? 'Only count limits applied'
                              : 'No rule checks applied',
                      ].join(' · '),
                      style: detailStyle,
                    ),
                  ],
                ),
              ),
              Text(
                result.subtotal.format(),
                key: const ValueKey('db-subtotal'),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// e.g. " (6 of 8)" when some are not counted, otherwise nothing.
String _countedOf(int counted, int total) =>
    counted == total ? '' : ' ($counted of $total)';
