import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fig_levels.dart';
import '../domain/competition_level.dart';

/// Preset levels offered in the picker. Overridable in tests.
final presetLevelsProvider = Provider<List<CompetitionLevel>>(
  (ref) => figLevels,
);
