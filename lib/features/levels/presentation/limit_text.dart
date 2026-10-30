import '../../../core/scoring/apparatus.dart';
import '../../../core/scoring/db_element_group.dart';
import '../domain/competition_level.dart';
import '../domain/count_limit.dart';
import '../domain/difficulty_category.dart';

/// Short wording for a limit, e.g. "2–4", "at least 2", "up to 4".
String describeLimit(CountLimit limit) {
  final min = limit.min, max = limit.max;
  if (min != null && max != null) {
    return min == max ? 'exactly $min' : '$min–$max';
  }
  if (min != null) return 'at least $min';
  if (max != null) return 'up to $max';
  return 'no limit';
}

/// One-line summary of a level's requirements for a routine with
/// [apparatus], for the selector. Only [categories] are described (e.g. DA
/// on the DA page); body groups and dance steps (S) go with DB.
String describeLevel(
  CompetitionLevel level,
  Apparatus? apparatus, {
  List<DifficultyCategory> categories = DifficultyCategory.values,
}) {
  final requirements = level.requirementsFor(apparatus);
  if (requirements == null) {
    return apparatus == Apparatus.freehand && level.requirements != null
        ? 'No freehand requirements'
        : 'Requirements not added yet';
  }
  final parts = [
    for (final category in categoriesFor(apparatus, categories))
      if (category.limitOf(requirements).isSet)
        '${category.label} ${describeLimit(category.limitOf(requirements))}',
    if (categories.contains(DifficultyCategory.db) &&
        requirements.requiredBodyGroups.isNotEmpty)
      'needs ${[for (final group in DbElementGroup.requirable)
        if (requirements.requiredBodyGroups.contains(group)) group.singular].join(', ')}',
    if (categories.contains(DifficultyCategory.db))
      if (requirements.minDanceSteps case final min?) 'at least $min\u00A0S',
  ];
  return parts.isEmpty ? 'No limits set' : parts.join(' · ');
}

/// The [categories] that apply to a routine with [apparatus]: freehand
/// routines have no risks or DA, so their limits are not shown.
List<DifficultyCategory> categoriesFor(
  Apparatus? apparatus, [
  List<DifficultyCategory> categories = DifficultyCategory.values,
]) => [
  for (final category in categories)
    if (apparatus != Apparatus.freehand || category == DifficultyCategory.db)
      category,
];
