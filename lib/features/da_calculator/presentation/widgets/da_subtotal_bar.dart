import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/da_scoring_engine.dart';
import '../da_routine_providers.dart';

/// Sticky bottom bar with the provisional DA subtotal.
class DaSubtotalBar extends ConsumerWidget {
  const DaSubtotalBar({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(daScoreResultProvider(routineId));
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isProvisional = result.notices.isNotEmpty;
    final detailStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    final daCount = result.daCount;

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
                      isProvisional ? 'Provisional DA subtotal' : 'DA subtotal',
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      result.countedCount == daCount
                          ? '$daCount DA'
                          : '${result.countedCount} of $daCount DA counted',
                      key: const ValueKey('da-breakdown'),
                      style: detailStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      [
                        result.ruleset.label,
                        if (result.notices.contains(
                          DaScoreNotice.rulesNotValidated,
                        ))
                          'Execution not checked',
                      ].join(' · '),
                      style: detailStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                result.subtotal.format(),
                key: const ValueKey('da-subtotal'),
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
