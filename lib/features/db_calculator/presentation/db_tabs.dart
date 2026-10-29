import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/scoring/apparatus.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/sample_data_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../levels/domain/difficulty_category.dart';
import '../../levels/presentation/count_limit_notice.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/db_routine.dart';
import 'db_calculator_providers.dart';
import 'db_routine_providers.dart';
import 'element_picker_screen.dart';
import 'widgets/risk_builder_sheet.dart';
import 'widgets/risks_section.dart';
import 'widgets/selected_elements_section.dart';

// The DB and risk (R) tabs of the routine page, with their add buttons.

/// Body difficulties of a routine, with count and body group notices.
class DbBodyTab extends ConsumerWidget {
  const DbBodyTab({super.key, required this.routineId});

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
    return _DbTabScrollView(
      routineId: routineId,
      slivers: [
        SectionHeader(title: 'Body difficulties', trailing: '$count selected'),
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

/// Risks of a routine, in performance order.
class DbRisksTab extends ConsumerWidget {
  const DbRisksTab({super.key, required this.routineId});

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
    return _DbTabScrollView(
      routineId: routineId,
      slivers: [
        SectionHeader(title: 'Risks', trailing: '$count added'),
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

/// "Add element" on the body difficulties tab.
class AddElementButton extends StatelessWidget {
  const AddElementButton({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    heroTag: null,
    onPressed: () => ElementPickerScreen.show(context, routineId: routineId),
    icon: const Icon(Icons.add),
    label: const Text('Add element'),
  );
}

/// "Build a risk" on the risks tab, once risk options have loaded and
/// never for freehand.
class BuildRiskButton extends ConsumerWidget {
  const BuildRiskButton({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFreehand = ref.watch(
      routineProvider(routineId)
          .select((r) => r.apparatus == Apparatus.freehand),
    );
    final riskCatalogue = ref.watch(riskCatalogueProvider).value;
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
  }
}

/// A DB tab's scroll view: the ruleset and unknown-items banners, then
/// [slivers].
class _DbTabScrollView extends ConsumerWidget {
  const _DbTabScrollView({required this.routineId, required this.slivers});

  final String routineId;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruleset = ref.watch(dbScoringEngineProvider).ruleset;
    final unknownCount = ref.watch(
      dbRoutineProvider(routineId).select(_countUnknown),
    );
    return CustomScrollView(
      slivers: [
        if (!ruleset.isOfficial || unknownCount > 0)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList.list(
              children: [
                SampleDataBanner(ruleset: ruleset),
                if (unknownCount > 0) ...[
                  const SizedBox(height: 8),
                  _UnknownItemsBanner(count: unknownCount),
                ],
              ],
            ),
          ),
        ...slivers,
        // Room for the floating button, so it never covers the last row.
        const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
      ],
    );
  }

  static int _countUnknown(DbRoutine db) =>
      db.elements.where((e) => e.isUnknown).length +
      db.risks
          .where(
            (r) => r.rotation.isUnknown || r.criteria.any((c) => c.isUnknown),
          )
          .length;
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
