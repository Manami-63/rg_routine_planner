import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routine_controller.dart';

/// Saved / saving / failed indicator. Tapping it after a failure retries.
class SaveStatusIndicator extends ConsumerWidget {
  const SaveStatusIndicator({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return switch (ref.watch(routineSaveStatusProvider(routineId))) {
      SaveStatus.saved => Tooltip(
        message: 'Saved',
        child: Icon(Icons.check_circle_outline, color: colors.primary),
      ),
      SaveStatus.saving => Tooltip(
        message: 'Saving…',
        child: Icon(Icons.sync, color: colors.onSurfaceVariant),
      ),
      SaveStatus.failed => IconButton(
        tooltip: "Couldn't save. Tap to retry",
        icon: Icon(Icons.error_outline, color: colors.error),
        onPressed: ref
            .read(routineControllerProvider(routineId).notifier)
            .saveNow,
      ),
    };
  }
}
