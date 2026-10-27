import 'package:flutter/material.dart';

import '../../../core/scoring/apparatus.dart';

/// Chips for choosing a routine's apparatus.
///
/// Takes the value and a callback, like `LevelSelector`, so it can sit on
/// both the DB and (future) DA pages.
class ApparatusSelector extends StatelessWidget {
  const ApparatusSelector({
    super.key,
    required this.apparatus,
    required this.onChanged,
  });

  final Apparatus? apparatus;
  final ValueChanged<Apparatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Apparatus', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final option in Apparatus.values)
              ChoiceChip(
                label: Text(option.label),
                selected: option == apparatus,
                onSelected: (_) => onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}
