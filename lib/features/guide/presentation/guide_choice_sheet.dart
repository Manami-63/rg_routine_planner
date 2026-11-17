import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/guide.dart';
import 'guide_providers.dart';

/// Asks how the user wants to start the new routine [routineId] and starts
/// its guide. Returns the chosen path, or null for "explore on my own"
/// (also when closed, or when the guide is off and nothing is asked).
Future<GuidePath?> offerGuide(
  BuildContext context,
  WidgetRef ref,
  String routineId,
) async {
  if (!ref.read(guideControllerProvider).enabled) return null;
  final choice = await showModalBottomSheet<_Choice>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => const _GuideChoiceSheet(),
  );
  final controller = ref.read(guideControllerProvider.notifier);
  switch (choice) {
    case _Choice(:final path?):
      controller.start(routineId, path);
      return path;
    case _Choice(turnOff: true):
      controller.setEnabled(false);
    case _:
  }
  return null;
}

class _Choice {
  const _Choice.path(GuidePath this.path) : turnOff = false;
  const _Choice.explore() : path = null, turnOff = false;
  const _Choice.turnOff() : path = null, turnOff = true;

  final GuidePath? path;
  final bool turnOff;
}

class _GuideChoiceSheet extends StatelessWidget {
  const _GuideChoiceSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    void choose(_Choice choice) => Navigator.of(context).pop(choice);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('How do you want to start?', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'A short guide shows you each step.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _ChoiceCard(
            icon: Icons.music_note_outlined,
            title: 'From my music',
            description:
                'Play the music and tap when each move starts. Choose the '
                'DB, R and DA as you go.',
            onTap: () => choose(const _Choice.path(GuidePath.music)),
          ),
          const SizedBox(height: 8),
          _ChoiceCard(
            icon: Icons.format_list_numbered,
            title: 'Pick DB and DA first',
            description:
                'Build the difficulty and see the total. Add the music and '
                'times later.',
            onTap: () => choose(const _Choice.path(GuidePath.difficulties)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => choose(const _Choice.explore()),
            child: const Text("I'll explore on my own"),
          ),
          TextButton(
            onPressed: () => choose(const _Choice.turnOff()),
            child: const Text("Don't show the guide again"),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      color: colors.primaryContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: colors.onPrimaryContainer),
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
              Icon(Icons.chevron_right, color: colors.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
