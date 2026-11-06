import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/scoring/apparatus.dart';
import '../../../core/widgets/async_sliver.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/sample_data_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../levels/domain/difficulty_category.dart';
import '../../levels/presentation/count_limit_notice.dart';
import '../../routines/presentation/routine_controller.dart';
import '../domain/da_base.dart';
import '../domain/da_scoring_engine.dart';
import 'da_calculator_providers.dart';
import 'da_routine_providers.dart';
import 'widgets/da_builder_sheet.dart';
import 'widgets/da_list_section.dart';

/// The DA tab of the routine page: DA in performance order, with the ones
/// that count.
class DaTab extends ConsumerWidget {
  const DaTab({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruleset = ref.watch(daScoringEngineProvider).ruleset;
    final count = ref.watch(
      daRoutineProvider(routineId).select((r) => r.elements.length),
    );
    final (level, apparatus) = ref.watch(
      routineProvider(routineId).select((r) => (r.level, r.apparatus)),
    );
    final daCount = ref.watch(
      daScoreResultProvider(routineId).select((r) => r.daCount),
    );
    final onFloorWarning = ref.watch(
      daScoreResultProvider(routineId)
          .select((r) => r.floorWarnings.isNotEmpty),
    );
    return CustomScrollView(
      slivers: [
        if (!ruleset.isOfficial)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: SampleDataBanner(ruleset: ruleset),
            ),
          ),
        SectionHeader(
          title: 'Apparatus difficulties',
          trailing: '$count added',
        ),
        if (apparatus == Apparatus.freehand)
          // FIG has no freehand DA, but some levels have their own (e.g.
          // set freehand requirements). FIG DA stay listed (as not counted)
          // so nothing is lost if the apparatus was changed by mistake.
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverList.list(
              children: [
                const _FreehandNotice(),
                const SizedBox(height: 8),
                CountLimitNotice(
                  level: level,
                  apparatus: apparatus,
                  category: DifficultyCategory.da,
                  count: daCount,
                ),
              ],
            ),
          )
        else if (apparatus == null)
          const SliverToBoxAdapter(
            child: MessageView(
              icon: Icons.sports_gymnastics,
              title: 'Choose an apparatus',
              message:
                  'DA bases and criteria depend on the apparatus. Tap the '
                  'pencil at the top to choose one.',
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverList.list(
              children: [
                CountLimitNotice(
                  level: level,
                  apparatus: apparatus,
                  category: DifficultyCategory.da,
                  count: daCount,
                ),
                if (onFloorWarning) const _OnFloorNotice(),
              ],
            ),
          ),
          // Loading and error states; the action is the floating button.
          AsyncSliver(
            value: ref.watch(daBasesProvider),
            loadingLabel: 'Loading DA bases',
            errorTitle: 'Could not load DA bases',
            onRetry: () => ref.invalidate(daBasesProvider),
            data: (_) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
        DaListSection(routineId: routineId),
        // Room for the floating button, so it never covers the last row.
        const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
      ],
    );
  }
}

/// Freehand DA are a level's own rules, entered by the user.
class _FreehandNotice extends StatelessWidget {
  const _FreehandNotice();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LevelNotice(
      key: const ValueKey('da-freehand-notice'),
      icon: Icons.info_outline,
      background: colors.surfaceContainerHighest,
      foreground: colors.onSurfaceVariant,
      message:
          'The FIG Code has no freehand DA. If your level has its own (e.g. '
          'set freehand requirements), add each with its name and value.',
    );
  }
}

/// More than 3 DA in a row on the floor (#5.4.6). Only a reminder: the app
/// cannot see whether the gymnast leaves the floor in between.
class _OnFloorNotice extends StatelessWidget {
  const _OnFloorNotice();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: LevelNotice(
        key: const ValueKey('da-floor-notice'),
        icon: Icons.warning_amber_rounded,
        background: colors.errorContainer,
        foreground: colors.onErrorContainer,
        message:
            'More than 3 DA in a row on the floor. Unless you leave the '
            'floor in between, the 4th onwards is not valid: you may get a '
            '${ProvisionalDaScoringEngine.onFloorPenalty.format()} penalty.',
      ),
    );
  }
}

/// "Build a DA", once the bases have loaded, for routines with an
/// apparatus; "Add a DA" (name and value) for freehand routines.
class BuildDaButton extends ConsumerWidget {
  const BuildDaButton({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apparatus = ref.watch(
      routineProvider(routineId).select((r) => r.apparatus),
    );
    final bases = ref.watch(daBasesProvider).value;
    final forApparatus = [
      for (final base in bases ?? const <DaBase>[])
        if (base.apparatus == apparatus) base,
    ];
    final freehand = apparatus == Apparatus.freehand;
    if (apparatus == null || (!freehand && forApparatus.isEmpty)) {
      return const SizedBox.shrink();
    }
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () => DaBuilderSheet.show(
        context,
        routineId: routineId,
        bases: forApparatus,
      ),
      icon: const Icon(Icons.add),
      label: Text(freehand ? 'Add a DA' : 'Build a DA'),
    );
  }
}
