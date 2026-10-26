import '../domain/competition_level.dart';
import '../domain/count_limit.dart';

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

/// One-line summary of a level's requirements for the selector.
String describeRequirements(LevelRequirements? requirements) {
  if (requirements == null) return 'Requirements not added yet';
  final parts = [
    if (requirements.db.isSet) 'DB ${describeLimit(requirements.db)}',
    if (requirements.da.isSet) 'DA ${describeLimit(requirements.da)}',
  ];
  return parts.isEmpty ? 'No limits set' : parts.join(' · ');
}
