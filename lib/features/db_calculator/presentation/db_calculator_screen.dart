import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/scoring/apparatus.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/sample_data_banner.dart';
import '../../levels/presentation/count_limit_notice.dart';
import '../../levels/domain/difficulty_category.dart';
import '../../levels/presentation/level_selector.dart';
import '../../routines/presentation/apparatus_selector.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/db_routine.dart';
import 'db_calculator_providers.dart';
import 'db_routine_providers.dart';
import 'element_picker_screen.dart';
import 'widgets/risk_builder_sheet.dart';
import 'widgets/risks_section.dart';
import 'widgets/routine_name_field.dart';
import 'widgets/section_header.dart';
import 'widgets/selected_elements_section.dart';
import 'widgets/subtotal_bar.dart';

/// DB calculator for one saved routine, with two tabs: body difficulties
/// and risks. Handles loading, "not found" and ruleset mismatch first.
class DbCalculatorScreen extends ConsumerWidget {
  const DbCalculatorScreen({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when loading state or ruleset changes, not on every edit.
    final rulesetId = ref.watch(
      routineControllerProvider(routineId)
          .select((routine) => routine.whenData((r) => r.rulesetId)),
    );
    final engineRuleset = ref.watch(dbScoringEngineProvider).ruleset;

    return rulesetId.when(
      loading: () => const _MessageScaffold(
        child: CircularProgressIndicator(semanticsLabel: 'Loading routine'),
      ),
      error: (error, _) => _MessageScaffold(
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
      data: (rulesetId) => rulesetId == engineRuleset.id
          ? _DbCalculatorContent(routineId: routineId)
          : _MessageScaffold(
              child: MessageView(
                icon: Icons.rule,
                title: 'Different ruleset',
                message:
                    'This routine was planned with the "$rulesetId" '
                    'ruleset, which is not available in this version of '
                    'the app.',
              ),
            ),
    );
  }
}

class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('DB Calculator')),
    body: Center(child: child),
  );
}

class _DbCalculatorContent extends ConsumerWidget {
  const _DbCalculatorContent({required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruleset = ref.watch(dbScoringEngineProvider).ruleset;
    final level = ref.watch(routineProvider(routineId).select((r) => r.level));
    final apparatus = ref.watch(
      routineProvider(routineId).select((r) => r.apparatus),
    );
    final isEmpty = ref.watch(
      dbRoutineProvider(routineId).select((r) => r.isEmpty),
    );
    final unknownCount = ref.watch(
      dbRoutineProvider(routineId).select(_countUnknown),
    );
    final controller = ref.read(routineControllerProvider(routineId).notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DB Calculator'),
          actions: [
            _SaveStatusIndicator(routineId: routineId),
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: isEmpty
                  ? null
                  : () => _confirmClear(context, controller),
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
                    if (unknownCount > 0) ...[
                      const SizedBox(height: 8),
                      _UnknownItemsBanner(count: unknownCount),
                    ],
                    const SizedBox(height: 16),
                    RoutineNameField(routineId: routineId),
                    const SizedBox(height: 12),
                    ApparatusSelector(
                      apparatus: apparatus,
                      onChanged: controller.selectApparatus,
                    ),
                    const SizedBox(height: 12),
                    LevelSelector(
                      level: level,
                      apparatus: apparatus,
                      onChanged: controller.selectLevel,
                    ),
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
            body: TabBarView(
              children: [
                _BodyTab(routineId: routineId),
                _RisksTab(routineId: routineId),
              ],
            ),
          ),
        ),
        // Always reachable, even when the header fills a small screen.
        floatingActionButton: _AddFab(routineId: routineId),
        bottomNavigationBar: SubtotalBar(routineId: routineId),
      ),
    );
  }

  static int _countUnknown(DbRoutine db) =>
      db.elements.where((e) => e.isUnknown).length +
      db.risks
          .where(
            (r) => r.rotation.isUnknown || r.criteria.any((c) => c.isUnknown),
          )
          .length;

  Future<void> _confirmClear(
    BuildContext context,
    RoutineController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear routine?'),
        content: const Text(
          'This removes all body difficulties and risks. '
          'The routine name and level are kept.',
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
    if (confirmed ?? false) controller.clearDb();
  }
}

/// Saved / saving / failed indicator. Tapping it after a failure retries.
class _SaveStatusIndicator extends ConsumerWidget {
  const _SaveStatusIndicator({required this.routineId});

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

class _UnknownItemsBanner extends StatelessWidget {
  const _UnknownItemsBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: colors.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count ${count == 1 ? 'item is' : 'items are'} no longer in '
              'the catalogue and count as 0.00. Remove and re-add them.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyTab extends ConsumerWidget {
  const _BodyTab({required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      dbRoutineProvider(routineId).select((r) => r.elements.length),
    );
    // Series count as several DB, repetitions as none.
    final dbCount = ref.watch(
      dbScoreResultProvider(routineId).select((r) => r.elementCount),
    );
    final (level, apparatus) = ref.watch(
      routineProvider(routineId).select((r) => (r.level, r.apparatus)),
    );
    final elements = ref.watch(
      dbRoutineProvider(routineId).select((r) => r.elements),
    );
    return _TabScrollView(
      slivers: [
        SectionHeader(title: 'Your routine', trailing: '$count selected'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverList.list(
            children: [
              CountLimitNotice(
                level: level,
                apparatus: apparatus,
                category: DifficultyCategory.db,
                count: dbCount,
              ),
              BodyGroupsNotice(
                requirements: ref.watch(routineRequirementsProvider(routineId)),
                presentGroups: {for (final e in elements) e.group},
              ),
            ],
          ),
        ),
        SelectedElementsSection(routineId: routineId),
      ],
    );
  }
}

class _RisksTab extends ConsumerWidget {
  const _RisksTab({required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      dbRoutineProvider(routineId).select((r) => r.risks.length),
    );
    final (level, apparatus) = ref.watch(
      routineProvider(routineId).select((r) => (r.level, r.apparatus)),
    );
    final isFreehand = apparatus == Apparatus.freehand;
    return _TabScrollView(
      slivers: [
        SectionHeader(title: 'Your risks', trailing: '$count added'),
        if (isFreehand)
          // Existing risks stay listed (as not counted) so nothing is lost
          // if the apparatus was changed by mistake.
          SliverToBoxAdapter(
            child: MessageView(
              icon: Icons.do_not_disturb_alt,
              title: 'No risks in freehand',
              message: count == 0
                  ? 'Freehand routines have no apparatus throws.'
                  : 'Freehand routines have no apparatus throws, so these '
                        'risks are not counted.',
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverToBoxAdapter(
              child: CountLimitNotice(
                level: level,
                apparatus: apparatus,
                category: DifficultyCategory.risk,
                count: count,
              ),
            ),
          ),
          // Loading, error and empty states; the action is the floating
          // button.
          RiskOptionsStatus(routineId: routineId),
        ],
        SelectedRisksSection(routineId: routineId),
      ],
    );
  }
}

/// A tab's scroll view inside the [NestedScrollView]. The injector leaves
/// room for the pinned tab bar so content does not scroll underneath it.
/// "Add element" on the body difficulties tab, "Build a risk" on the risks
/// tab (only once risk options have loaded, and never for freehand).
class _AddFab extends ConsumerWidget {
  const _AddFab({required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = DefaultTabController.of(context);
    final isFreehand = ref.watch(
      routineProvider(routineId)
          .select((r) => r.apparatus == Apparatus.freehand),
    );
    final riskCatalogue = ref.watch(riskCatalogueProvider).value;

    return ListenableBuilder(
      listenable: tabs,
      builder: (context, _) {
        if (tabs.index == 0) {
          return FloatingActionButton.extended(
            heroTag: null,
            onPressed: () =>
                ElementPickerScreen.show(context, routineId: routineId),
            icon: const Icon(Icons.add),
            label: const Text('Add element'),
          );
        }
        if (isFreehand || riskCatalogue == null || riskCatalogue.isEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => RiskBuilderSheet.show(
            context,
            routineId: routineId,
            catalogue: riskCatalogue,
          ),
          icon: const Icon(Icons.add),
          label: const Text('Build a risk'),
        );
      },
    );
  }
}

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
        // Room for the floating button, so it never covers the last row.
        const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
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
