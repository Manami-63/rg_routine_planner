import 'package:flutter/material.dart';

import '../scoring/ruleset.dart';

/// Warns that results are based on unverified data. Renders nothing for an
/// official ruleset.
///
/// Kept to one line so it does not push the calculator off small screens;
/// "Details" shows the full explanation.
class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({super.key, required this.ruleset});

  final RulesetVersion ruleset;

  String get _details =>
      '${ruleset.label}: '
      '${ruleset.detail ?? 'element names and values are placeholders, '
              'not official rules.'} '
      'Totals are provisional and not competition-ready.';

  void _showDetails(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unofficial values'),
      content: Text(_details),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (ruleset.isOfficial) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.science_outlined,
              size: 20,
              color: colors.onTertiaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unofficial values · totals are provisional',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onTertiaryContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _showDetails(context),
              child: const Text('Details'),
            ),
          ],
        ),
      ),
    );
  }
}
