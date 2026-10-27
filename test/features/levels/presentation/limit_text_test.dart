import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/core/scoring/db_element_group.dart';
import 'package:rg_routine_planner/features/levels/domain/competition_level.dart';
import 'package:rg_routine_planner/features/levels/domain/count_limit.dart';
import 'package:rg_routine_planner/features/levels/presentation/limit_text.dart';

void main() {
  test('describeLimit wording', () {
    expect(describeLimit(const CountLimit(min: 2, max: 4)), '2–4');
    expect(describeLimit(const CountLimit(min: 3, max: 3)), 'exactly 3');
    expect(describeLimit(const CountLimit(min: 2)), 'at least 2');
    expect(describeLimit(const CountLimit(max: 4)), 'up to 4');
    expect(describeLimit(CountLimit.none), 'no limit');
  });

  test('describeLevel wording', () {
    const notAdded = CompetitionLevel(id: 'x', label: 'X', isFig: true);
    expect(
      describeLevel(notAdded, Apparatus.hoop),
      'Requirements not added yet',
    );
    expect(
      describeLevel(
        const CompetitionLevel.custom(LevelRequirements()),
        Apparatus.hoop,
      ),
      'No limits set',
    );

    const custom = CompetitionLevel.custom(
      LevelRequirements(
        db: CountLimit(max: 8),
        risk: CountLimit(min: 1, max: 2),
        da: CountLimit(min: 1),
        requiredBodyGroups: {DbElementGroup.balance, DbElementGroup.jump},
      ),
    );
    expect(
      describeLevel(custom, Apparatus.hoop),
      'DB up to 8 · R 1–2 · DA at least 1 · needs leap, balance',
    );
  });

  test('describeLevel for freehand shows only DB', () {
    const custom = CompetitionLevel.custom(
      LevelRequirements(db: CountLimit(max: 5), risk: CountLimit(max: 2)),
    );
    expect(describeLevel(custom, Apparatus.freehand), 'DB up to 5');

    const figOnly = CompetitionLevel(
      id: 'fig',
      label: 'FIG',
      isFig: true,
      requirements: LevelRequirements(db: CountLimit(max: 6)),
    );
    expect(
      describeLevel(figOnly, Apparatus.freehand),
      'No freehand requirements',
    );
  });
}
