import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'message_view.dart';

/// Renders an [AsyncValue] as a sliver with consistent loading and error
/// (with retry) states. [data] builds the loaded content.
class AsyncSliver<T> extends StatelessWidget {
  const AsyncSliver({
    super.key,
    required this.value,
    required this.loadingLabel,
    required this.errorTitle,
    required this.onRetry,
    required this.data,
  });

  final AsyncValue<T> value;
  final String loadingLabel;
  final String errorTitle;
  final VoidCallback onRetry;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      // Show the spinner again when the user retries after an error.
      skipLoadingOnRefresh: false,
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(semanticsLabel: loadingLabel),
          ),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: MessageView(
          icon: Icons.error_outline,
          isError: true,
          title: errorTitle,
          message: 'Please try again.',
          action: FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ),
      data: data,
    );
  }
}
