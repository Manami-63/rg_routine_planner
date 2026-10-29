import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/scoring/apparatus.dart';
import '../data/routine_repository.dart';
import 'routine_details_form.dart';

/// What My routines shows: a search text plus an optional apparatus and
/// level. Every part must match.
class RoutineFilter {
  const RoutineFilter({this.query = '', this.apparatus, this.levelId});

  /// [levelId] for routines without a level.
  static const noLevel = '';

  /// Words to find in the name or notes, in any order and case.
  final String query;

  /// Only routines for this apparatus, or any when `null`.
  final Apparatus? apparatus;

  /// Only routines at this level (`CompetitionLevel.id`, or [noLevel]), or
  /// any when `null`.
  final String? levelId;

  bool get isActive =>
      query.trim().isNotEmpty || apparatus != null || levelId != null;

  // Explicit constructors, because `null` means "any".
  RoutineFilter withQuery(String newQuery) =>
      RoutineFilter(query: newQuery, apparatus: apparatus, levelId: levelId);

  RoutineFilter withApparatus(Apparatus? newApparatus) =>
      RoutineFilter(query: query, apparatus: newApparatus, levelId: levelId);

  RoutineFilter withLevelId(String? newLevelId) =>
      RoutineFilter(query: query, apparatus: apparatus, levelId: newLevelId);

  bool matches(RoutineSummary routine) {
    if (apparatus != null && routine.apparatus != apparatus) return false;
    if (levelId != null && levelIdOf(routine) != levelId) return false;
    final text = '${routineDisplayName(routine.name)}\n${routine.notes}'
        .toLowerCase();
    return query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .every(text.contains);
  }

  List<RoutineSummary> apply(List<RoutineSummary> routines) => [
    for (final routine in routines)
      if (matches(routine)) routine,
  ];

  /// The id [levelId] filters by: the level's id, or [noLevel].
  static String levelIdOf(RoutineSummary routine) =>
      routine.level?.id ?? noLevel;
}

/// The filter of My routines. Reset when the screen closes.
final routineFilterProvider =
    NotifierProvider.autoDispose<RoutineFilterNotifier, RoutineFilter>(
      RoutineFilterNotifier.new,
    );

class RoutineFilterNotifier extends Notifier<RoutineFilter> {
  @override
  RoutineFilter build() => const RoutineFilter();

  void search(String query) => state = state.withQuery(query);

  void filterApparatus(Apparatus? apparatus) =>
      state = state.withApparatus(apparatus);

  void filterLevel(String? levelId) => state = state.withLevelId(levelId);

  void clear() => state = const RoutineFilter();
}
