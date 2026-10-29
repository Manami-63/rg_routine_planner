import 'dart:async';

import 'package:rg_routine_planner/features/routines/data/routine_repository.dart';
import 'package:rg_routine_planner/features/routines/domain/routine.dart';

/// In-memory [RoutineRepository] for widget and controller tests.
class FakeRoutineRepository implements RoutineRepository {
  FakeRoutineRepository([Iterable<Routine> initial = const []]) {
    for (final routine in initial) {
      _routines[routine.id] = routine;
    }
  }

  final _routines = <String, Routine>{};
  final _changes = StreamController<void>.broadcast();

  /// When set, [saveRoutine] throws this error.
  Object? saveError;

  int saveCount = 0;

  Map<String, Routine> get routines => Map.unmodifiable(_routines);

  @override
  Stream<List<RoutineSummary>> watchRoutineSummaries() async* {
    yield _summaries();
    await for (final _ in _changes.stream) {
      yield _summaries();
    }
  }

  List<RoutineSummary> _summaries() => [
    for (final r in _routines.values)
      RoutineSummary(
        id: r.id,
        name: r.name,
        apparatus: r.apparatus,
        level: r.level,
        elementCount: r.db.elements.length,
        riskCount: r.db.risks.length,
        daCount: r.da.elements.length,
        updatedAt: r.updatedAt,
        notes: r.notes,
      ),
  ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<Routine?> fetchRoutine(String id) async => _routines[id];

  @override
  Future<void> saveRoutine(Routine routine) async {
    if (saveError case final error?) throw error;
    saveCount++;
    _routines[routine.id] = routine;
    _changes.add(null);
  }

  @override
  Future<void> deleteRoutine(String id) async {
    _routines.remove(id);
    _changes.add(null);
  }
}
