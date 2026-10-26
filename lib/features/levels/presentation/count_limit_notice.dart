import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/competition_level.dart';
import '../domain/count_limit.dart';
import 'level_providers.dart';
import 'limit_text.dart';

/// Compares a count (e.g. number of DB) with the selected level's limit.
///
/// Advisory only: it never blocks editing, because a planned routine is
/// often a work in progress. Renders nothing when there is nothing to check.
class CountLimitNotice extends ConsumerWidget {
  const CountLimitNotice({
    super.key,
    required this.category,
    required this.count,
    required this.limitOf,
  });

  /// Short name of what is counted, e.g. "DB".
  final String category;
  final int count;
  final CountLimit Function(LevelRequirements requirements) limitOf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(selectedLevelProvider);
    if (level == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final requirements = level.requirements;
    if (requirements == null) {
      return _Notice(
        icon: Icons.info_outline,
        background: colors.surfaceContainerHighest,
        foreground: colors.onSurfaceVariant,
        message:
            'Official ${level.label} requirements are not in the app yet, '
            'so the number of $category is not checked.',
      );
    }

    final limit = limitOf(requirements);
    final range = describeLimit(limit);
    return switch (limit.statusOf(count)) {
      CountStatus.noLimit => const SizedBox.shrink(),
      CountStatus.withinLimits => _Notice(
        icon: Icons.check_circle_outline,
        background: colors.primaryContainer,
        foreground: colors.onPrimaryContainer,
        message: '$count $category · meets the level ($range)',
      ),
      CountStatus.belowMinimum => _Notice(
        icon: Icons.info_outline,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
        message:
            '$count $category · ${limit.min! - count} more needed ($range)',
      ),
      CountStatus.aboveMaximum => _Notice(
        icon: Icons.warning_amber_rounded,
        background: colors.errorContainer,
        foreground: colors.onErrorContainer,
        message:
            '$count $category · ${count - limit.max!} over the limit ($range)',
      ),
    };
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.message,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('count-limit-notice'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
