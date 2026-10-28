import 'package:flutter/material.dart';

/// Sliver section title with optional trailing summary text.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
        child: Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            if (trailing != null)
              Text(
                trailing!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
