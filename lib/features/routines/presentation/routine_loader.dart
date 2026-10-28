import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/message_view.dart';
import 'routine_controller.dart';

/// Loads the routine with [routineId] for a calculator screen and handles
/// loading, "not found", errors and a ruleset the calculator does not know.
/// Builds [content] once the routine is ready.
class RoutineLoader extends ConsumerWidget {
  const RoutineLoader({
    super.key,
    required this.routineId,
    required this.title,
    required this.rulesetId,
    required this.content,
  });

  final String routineId;

  /// The screen title, shown while loading and on errors.
  final String title;

  /// The ruleset of the calculator's engine.
  final String rulesetId;

  final WidgetBuilder content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when loading state or ruleset changes, not on every edit.
    final routineRulesetId = ref.watch(
      routineControllerProvider(routineId)
          .select((routine) => routine.whenData((r) => r.rulesetId)),
    );

    return routineRulesetId.when(
      loading: () => _MessageScaffold(
        title: title,
        child: const CircularProgressIndicator(
          semanticsLabel: 'Loading routine',
        ),
      ),
      error: (error, _) => _MessageScaffold(
        title: title,
        child: error is RoutineNotFoundException
            ? const MessageView(
                icon: Icons.search_off,
                title: 'Routine not found',
                message: 'It may have been deleted.',
              )
            : MessageView(
                icon: Icons.error_outline,
                isError: true,
                title: 'Could not open the routine',
                message: 'Please try again.',
                action: FilledButton.tonalIcon(
                  onPressed: () =>
                      ref.invalidate(routineControllerProvider(routineId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ),
      ),
      data: (routineRulesetId) => routineRulesetId == rulesetId
          ? content(context)
          : _MessageScaffold(
              title: title,
              child: MessageView(
                icon: Icons.rule,
                title: 'Different ruleset',
                message:
                    'This routine was planned with the "$routineRulesetId" '
                    'ruleset, which is not available in this version of '
                    'the app.',
              ),
            ),
    );
  }
}

class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: child),
  );
}
