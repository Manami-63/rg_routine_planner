import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/routines/data/routine_repository.dart';
import 'package:rg_routine_planner/features/routines/presentation/routine_filter.dart';

void main() {
  RoutineSummary summary(
    String name, {
    Apparatus? apparatus,
    CompetitionLevel? level,
    String notes = '',
  }) => RoutineSummary(
    id: name,
    name: name,
    apparatus: apparatus,
    level: level,
    elementCount: 0,
    riskCount: 0,
    daCount: 0,
    updatedAt: DateTime.utc(2026),
    notes: notes,
  );

  final hoop = summary(
    'Hoop final',
    apparatus: Apparatus.hoop,
    level: figSenior,
    notes: 'Music: Bolero',
  );
  final ball = summary('Ball', apparatus: Apparatus.ball, level: figJunior);
  final untitled = summary('');
  final all = [hoop, ball, untitled];

  test('an empty filter shows everything', () {
    const filter = RoutineFilter(query: '  ');

    expect(filter.isActive, isFalse);
    expect(filter.apply(all), all);
  });

  test('search finds every word in the name or notes, in any case', () {
    expect(const RoutineFilter(query: 'HOOP').apply(all), [hoop]);
    expect(const RoutineFilter(query: 'bolero').apply(all), [hoop]);
    expect(const RoutineFilter(query: 'bolero final').apply(all), [hoop]);
    expect(const RoutineFilter(query: 'bolero ball').apply(all), isEmpty);
    // Untitled routines are found by the name they are shown with.
    expect(const RoutineFilter(query: 'untitled').apply(all), [untitled]);
  });

  test('apparatus and level filters combine with the search', () {
    const filter = RoutineFilter();

    expect(filter.withApparatus(Apparatus.ball).apply(all), [ball]);
    expect(filter.withLevelId(figSenior.id).apply(all), [hoop]);
    expect(filter.withLevelId(RoutineFilter.noLevel).apply(all), [untitled]);
    expect(
      filter.withApparatus(Apparatus.ball).withLevelId(figSenior.id).apply(all),
      isEmpty,
    );
    expect(
      filter.withQuery('hoop').withApparatus(null).withLevelId(null).isActive,
      isTrue,
    );
  });
}
