import 'package:flutter/material.dart';

import '../scoring/ruleset.dart';

/// Warns that results are based on unverified data. Renders nothing for an
/// official ruleset.
class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({super.key, required this.ruleset});

  final RulesetVersion ruleset;

  @override
  Widget build(BuildContext context) {
    if (ruleset.isOfficial) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.science_outlined, color: colors.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${ruleset.label}: element names and values are placeholders, '
                'not official rules. Totals are provisional and not '
                'competition-ready.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
