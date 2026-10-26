import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/sample_data_banner.dart';
import '../../levels/presentation/count_limit_notice.dart';
import '../../levels/presentation/level_selector.dart';
import 'db_calculator_providers.dart';
import 'widgets/catalogue_section.dart';
import 'widgets/risks_section.dart';
import 'widgets/routine_name_field.dart';
import 'widgets/section_header.dart';
import 'widgets/selected_elements_section.dart';
import 'widgets/subtotal_bar.dart';

/// DB calculator with two tabs: body difficulties and risks.
///
/// Both count towards the same DB subtotal, but are built differently:
/// body difficulties are picked from a catalogue, risks are composed.
class DbCalculatorScreen extends ConsumerWidget {
  const DbCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruleset = ref.watch(dbScoringEngineProvider).ruleset;
    final isEmpty = ref.watch(
      dbRoutineControllerProvider.select((r) => r.isEmpty),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DB Calculator'),
          actions: [
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: isEmpty ? null : () => _confirmClear(context, ref),
            ),
          ],
        ),
        body: GestureDetector(
          // Tapping outside the name field dismisses the keyboard.
          onTap: () => FocusScope.of(context).unfocus(),
          // The banner and name scroll away; the tab bar stays pinned.
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverList.list(
                  children: [
                    SampleDataBanner(ruleset: ruleset),
                    const SizedBox(height: 16),
                    const RoutineNameField(),
                    const SizedBox(height: 12),
                    const LevelSelector(),
                  ],
                ),
              ),
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: const SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      tabs: [
                        Tab(text: 'Body difficulties'),
                        Tab(text: 'Risks'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: const TabBarView(children: [_BodyTab(), _RisksTab()]),
          ),
        ),
        bottomNavigationBar: const SubtotalBar(),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear routine?'),
        content: const Text(
          'This removes all body difficulties and risks. '
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

class _BodyTab extends ConsumerWidget {
  const _BodyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      dbRoutineControllerProvider.select((r) => r.elements.length),
    );
    return _TabScrollView(
      slivers: [
        SectionHeader(title: 'Your routine', trailing: '$count selected'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverToBoxAdapter(
            child: CountLimitNotice(
              category: 'DB',
              count: count,
              limitOf: (requirements) => requirements.db,
            ),
          ),
        ),
        const SelectedElementsSection(),
        const SectionHeader(title: 'Element catalogue'),
        const CatalogueSection(),
      ],
    );
  }
}

class _RisksTab extends ConsumerWidget {
  const _RisksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      dbRoutineControllerProvider.select((r) => r.risks.length),
    );
    return _TabScrollView(
      slivers: [
        SectionHeader(title: 'Your risks', trailing: '$count added'),
        // The action comes first so it stays reachable on small screens.
        const BuildRiskAction(),
        const SelectedRisksSection(),
      ],
    );
  }
}

/// A tab's scroll view inside the [NestedScrollView]. The injector leaves
/// room for the pinned tab bar so content does not scroll underneath it.
class _TabScrollView extends StatelessWidget {
  const _TabScrollView({required this.slivers});

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        ...slivers,
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}
