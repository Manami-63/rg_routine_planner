import '../../levels/domain/competition_level.dart';
import '../domain/routine.dart';

/// Lightweight row for the routines list.
class RoutineSummary {
  const RoutineSummary({
    required this.id,
    required this.name,
    required this.level,
    required this.elementCount,
    required this.riskCount,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final CompetitionLevel? level;
  final int elementCount;
  final int riskCount;
  final DateTime updatedAt;
}

/// Stores and loads routines.
///
/// Implemented with Drift today; a Laravel API implementation can be added
/// later without changing callers.
abstract interface class RoutineRepository {
  /// All routines, most recently updated first. Emits again on any change.
  Stream<List<RoutineSummary>> watchRoutineSummaries();

  /// The routine with [id], or `null` if it does not exist.
  Future<Routine?> fetchRoutine(String id);

  /// Inserts or fully replaces the routine, as given (including
  /// `updatedAt`).
  Future<void> saveRoutine(Routine routine);

  Future<void> deleteRoutine(String id);
}
