import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/sample_data_banner.dart';
import 'db_calculator_providers.dart';
import 'widgets/catalogue_section.dart';
import 'widgets/routine_name_field.dart';
import 'widgets/selected_elements_section.dart';
import 'widgets/subtotal_bar.dart';

class DbCalculatorScreen extends ConsumerWidget {
  const DbCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruleset = ref.watch(dbScoringEngineProvider).ruleset;
    final elementCount = ref.watch(
      dbRoutineControllerProvider.select((r) => r.elements.length),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('DB Calculator'),
        actions: [
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: elementCount == 0
                ? null
                : () => _confirmClear(context, ref, elementCount),
          ),
        ],
      ),
      body: GestureDetector(
        // Tapping outside the name field dismisses the keyboard.
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverList.list(
                children: [
                  SampleDataBanner(ruleset: ruleset),
                  const SizedBox(height: 16),
                  const RoutineNameField(),
                ],
              ),
            ),
            _SectionHeader(
              title: 'Your routine',
              trailing: '$elementCount selected',
            ),
            const SelectedElementsSection(),
            const _SectionHeader(title: 'Element catalogue'),
            const CatalogueSection(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
      bottomNavigationBar: const SubtotalBar(),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    WidgetRef ref,
    int elementCount,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear routine?'),
        content: Text(
          'This removes all $elementCount '
          '${elementCount == 1 ? 'element' : 'elements'}. '
          'The routine name is kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      ref.read(dbRoutineControllerProvider.notifier).clear();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

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
