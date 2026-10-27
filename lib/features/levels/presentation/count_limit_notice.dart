import 'package:flutter/material.dart';

import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/db_element_group.dart';
import '../domain/competition_level.dart';
import '../domain/count_limit.dart';
import '../domain/difficulty_category.dart';
import 'limit_text.dart';

/// Compares a count (e.g. number of DB) with the selected level's limit.
///
/// Advisory only: it never blocks editing, because a planned routine is
/// often a work in progress, and elements over the maximum are allowed
/// (they just do not count). Renders nothing when there is nothing to check.
class CountLimitNotice extends StatelessWidget {
  const CountLimitNotice({
    super.key,
    required this.level,
    required this.apparatus,
    required this.category,
    required this.count,
  });

  /// The routine's level, or `null` if none chosen.
  final CompetitionLevel? level;
  final Apparatus? apparatus;
  final DifficultyCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final level = this.level;
    if (level == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final noun = category.noun;
    final requirements = level.requirementsFor(apparatus);
    if (requirements == null) {
      return LevelNotice(
        icon: Icons.info_outline,
        background: colors.surfaceContainerHighest,
        foreground: colors.onSurfaceVariant,
        message: apparatus == Apparatus.freehand && level.requirements != null
            ? '${level.label} has no freehand requirements in the app, '
                  'so the number of $noun is not checked.'
            : 'Official ${level.label} requirements are not in the app yet, '
                  'so the number of $noun is not checked.',
      );
    }

    final limit = category.limitOf(requirements);
    final range = describeLimit(limit);
    return switch (limit.statusOf(count)) {
      CountStatus.noLimit => const SizedBox.shrink(),
      CountStatus.withinLimits => LevelNotice(
        icon: Icons.check_circle_outline,
        background: colors.primaryContainer,
        foreground: colors.onPrimaryContainer,
        message: '$count $noun · meets the level ($range)',
      ),
      CountStatus.belowMinimum => LevelNotice(
        icon: Icons.info_outline,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
        message: '$count $noun · ${limit.min! - count} more needed ($range)',
      ),
      // Not an error: extra elements are allowed, they just do not count.
      CountStatus.aboveMaximum => LevelNotice(
        icon: Icons.info_outline,
        background: colors.tertiaryContainer,
        foreground: colors.onTertiaryContainer,
        message:
            '$count $noun · ${count - limit.max!} not counted '
            '(${category.countedRule(limit.max!)})',
      ),
    };
  }
}

/// Alerts about body groups the level requires but the counted DB lack.
///
/// Only a reminder: penalties have many causes the app cannot see, so it
/// never deducts anything from the score.
class BodyGroupsNotice extends StatelessWidget {
  const BodyGroupsNotice({
    super.key,
    required this.requirements,
    required this.countedGroups,
  });

  /// The level's requirements for the routine, or `null` if none.
  final LevelRequirements? requirements;

  /// Groups present among the counted DB.
  final Set<DbElementGroup> countedGroups;

  @override
  Widget build(BuildContext context) {
    final missing = [
      for (final group in DbElementGroup.requirable)
        if ((requirements?.requiredBodyGroups.contains(group) ?? false) &&
            !countedGroups.contains(group))
          group,
    ];
    if (missing.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final names = missing.map((g) => g.singular).toList();
    final list = names.length == 1
        ? names.single
        : '${names.sublist(0, names.length - 1).join(', ')} or ${names.last}';
    return LevelNotice(
      key: const ValueKey('body-groups-notice'),
      icon: Icons.warning_amber_rounded,
      background: colors.errorContainer,
      foreground: colors.onErrorContainer,
      message:
          'No counted $list. Your level requires '
          '${missing.length == 1 ? 'one' : 'one of each'}: '
          'you may get a penalty.',
    );
  }
}

/// A rounded, coloured message row used by the level notices.
class LevelNotice extends StatelessWidget {
  const LevelNotice({
    super.key = const ValueKey('count-limit-notice'),
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
