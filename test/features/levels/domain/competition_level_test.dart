import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/db_element_group.dart';
import 'package:rg_routine_planner/core/scoring/score.dart';
import 'package:rg_routine_planner/features/levels/data/fig_levels.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';

void main() {
  const allGroups = {
    DbElementGroup.jump,
    DbElementGroup.balance,
    DbElementGroup.rotation,
  };

  test('FIG levels set only maximums and require every body group', () {
    expect(
      figJunior.requirements,
      const LevelRequirements(
        db: CountLimit(max: 6),
        risk: CountLimit(max: 3),
        da: CountLimit(max: 12),
        requiredBodyGroups: allGroups,
        missingBodyGroupPenalty: Score.hundredths(30),
      ),
    );
    expect(
      figSenior.requirements,
      const LevelRequirements(
        db: CountLimit(max: 8),
        risk: CountLimit(max: 4),
        da: CountLimit(max: 15),
        requiredBodyGroups: allGroups,
        missingBodyGroupPenalty: Score.hundredths(30),
      ),
    );
  });

  test('FIG levels have no freehand requirements', () {
    expect(figJunior.requirementsFor(Apparatus.hoop), figJunior.requirements);
    expect(figJunior.requirementsFor(null), figJunior.requirements);
    expect(figJunior.requirementsFor(Apparatus.freehand), isNull);
  });

  test('a custom level applies to freehand and apparatus alike', () {
    const requirements = LevelRequirements(db: CountLimit(max: 5));
    const custom = CompetitionLevel.custom(requirements);

    expect(custom.requirementsFor(Apparatus.freehand), requirements);
    expect(custom.requirementsFor(Apparatus.rope), requirements);
  });

  test('requirement equality ignores body group order', () {
    expect(
      const LevelRequirements(
        requiredBodyGroups: {DbElementGroup.jump, DbElementGroup.balance},
      ),
      const LevelRequirements(
        requiredBodyGroups: {DbElementGroup.balance, DbElementGroup.jump},
      ),
    );
  });

  test('validity covers the risk limit', () {
    expect(
      const LevelRequirements(risk: CountLimit(min: 3, max: 2)).isValid,
      isFalse,
    );
  });
}
