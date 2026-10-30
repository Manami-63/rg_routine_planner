import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../data/welcome_store.dart';
import 'welcome_providers.dart';

/// Shown on the first launch, and again from Home ("How it works"): the
/// intro video and the three steps of the app, as briefly as possible.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const steps = [
    'Add your DB, R and DA',
    'Add music and tap to mark each one',
    'Practise in Play mode',
  ];

  Future<void> _done(BuildContext context, WidgetRef ref) async {
    await ref.read(welcomeStoreProvider).markSeen(welcomeVersion);
    if (!context.mounted) return;
    context.canPop() ? context.pop() : context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'RG Routine Planner',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: ref.watch(introVideoProvider)),
              const SizedBox(height: 16),
              for (final (i, step) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        child: Text(
                          '${i + 1}',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(step, style: theme.textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _done(context, ref),
                child: const Text('Get started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
