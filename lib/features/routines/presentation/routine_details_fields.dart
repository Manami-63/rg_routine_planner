import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../levels/domain/difficulty_category.dart';
import '../../levels/presentation/level_selector.dart';
import 'apparatus_selector.dart';
import 'routine_controller.dart';
import 'routine_name_field.dart';

/// The calculator pages of a routine.
enum RoutinePage {
  db('Body (DB)'),
  da('Apparatus (DA)');

  const RoutinePage(this.label);

  final String label;

  /// The categories this page shows in the level picker.
  List<DifficultyCategory> get categories => switch (this) {
    db => DifficultyCategory.dbPage,
    da => const [DifficultyCategory.da],
  };

  String route(String routineId) => switch (this) {
    db => AppRoutes.dbCalculator(routineId),
    da => AppRoutes.daCalculator(routineId),
  };
}

/// The header shared by the calculator pages: a switch between them, then
/// the routine's name, apparatus and level.
class RoutineDetailsFields extends ConsumerWidget {
  const RoutineDetailsFields({
    super.key,
    required this.routineId,
    required this.page,
  });

  final String routineId;
  final RoutinePage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (level, apparatus) = ref.watch(
      routineProvider(routineId).select((r) => (r.level, r.apparatus)),
    );
    final controller = ref.read(routineControllerProvider(routineId).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<RoutinePage>(
          showSelectedIcon: false,
          segments: [
            for (final page in RoutinePage.values)
              ButtonSegment(value: page, label: Text(page.label)),
          ],
          selected: {page},
          // Replaces the page, so Back still returns to "My routines".
          onSelectionChanged: (selection) =>
              context.go(selection.single.route(routineId)),
        ),
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
          categories: page.categories,
          onChanged: controller.selectLevel,
        ),
      ],
    );
  }
}
