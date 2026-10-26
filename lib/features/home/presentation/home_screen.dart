import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            Text(
              'RG Routine Planner',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Plan rhythmic gymnastics routines and check difficulty.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            _FeatureCard(
              icon: Icons.calculate_outlined,
              title: 'DB Calculator',
              description:
                  'Build a list of body difficulties and see a provisional '
                  'subtotal. Uses sample data for now.',
              onTap: () => context.go(AppRoutes.dbCalculator),
            ),
            const SizedBox(height: 12),
            const _FeatureCard(
              icon: Icons.sports_gymnastics,
              title: 'DA Calculator',
              description: 'Dynamic difficulty with apparatus.',
            ),
            const SizedBox(height: 12),
            const _FeatureCard(
              icon: Icons.event_note_outlined,
              title: 'Routine Planner',
              description: 'Save and organise full routines.',
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable feature entry. Without [onTap] it renders as "Coming soon".
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = onTap != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: enabled ? colors.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: enabled
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (enabled)
                Icon(Icons.chevron_right, color: colors.onPrimaryContainer)
              else
                Chip(
                  label: const Text('Coming soon'),
                  visualDensity: VisualDensity.compact,
                  labelStyle: theme.textTheme.labelSmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
