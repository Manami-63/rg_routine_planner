import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/db_scoring_engine.dart';
import '../db_routine_providers.dart';

/// Sticky bottom bar with the provisional DB subtotal and its breakdown.
class SubtotalBar extends ConsumerWidget {
  const SubtotalBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(dbScoreResultProvider);
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
                      ' · Risks ${result.riskSubtotal.format()}',
                      key: const ValueKey('db-breakdown'),
                      style: detailStyle,
                    ),
                    Text(
                      [
                        result.ruleset.label,
                        if (result.notices.contains(
                          DbScoreNotice.rulesNotValidated,
                        ))
                          'No rule checks applied',
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
