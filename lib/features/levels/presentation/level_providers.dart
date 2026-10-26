import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fig_levels.dart';
import '../domain/competition_level.dart';

/// Preset levels offered in the picker. Overridable in tests.
final presetLevelsProvider = Provider<List<CompetitionLevel>>(
  (ref) => figLevels,
);

/// The level the current routine is planned for, or `null` if none chosen.
///
/// Kept outside the DB routine so the DA calculator can share it. In-memory
/// for now; it will be saved with the routine once persistence is added.
final selectedLevelProvider =
    NotifierProvider<SelectedLevelController, CompetitionLevel?>(
      SelectedLevelController.new,
    );

class SelectedLevelController extends Notifier<CompetitionLevel?> {
  @override
  CompetitionLevel? build() => null;

  void select(CompetitionLevel? level) => state = level;
}
