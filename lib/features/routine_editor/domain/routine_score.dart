import '../../../core/scoring/score.dart';
import '../../da_calculator/domain/da_scoring_engine.dart';
import '../../db_calculator/domain/db_counting.dart';
import '../../db_calculator/domain/db_scoring_engine.dart';
import '../../routines/domain/routine.dart';

/// A routine's provisional difficulty: DB (body difficulties and risks)
/// plus DA. Penalties are never deducted.
class RoutineScore {
  const RoutineScore({required this.db, required this.da});

  /// Scores [routine] with the count limits of its level and apparatus.
  factory RoutineScore.of(
    Routine routine, {
    required DbScoringEngine dbEngine,
    required DaScoringEngine daEngine,
  }) {
    final requirements = routine.level?.requirementsFor(routine.apparatus);
    return RoutineScore(
      db: dbEngine.calculate(
        routine.db,
        limits: DbCountLimits.of(requirements, routine.apparatus),
      ),
      da: daEngine.calculate(
        routine.da,
        apparatus: routine.apparatus,
        maxCounted: daMaxCounted(requirements, routine.apparatus),
      ),
    );
  }

  final DbScoreResult db;
  final DaScoreResult da;

  Score get total => db.subtotal + da.subtotal;

  /// Whether either part has caveats, so the total must be labelled
  /// provisional.
  bool get isProvisional => db.notices.isNotEmpty || da.notices.isNotEmpty;
}
