import 'package:flutter_test/flutter_test.dart';
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

  test('describeRequirements wording', () {
    expect(describeRequirements(null), 'Requirements not added yet');
    expect(describeRequirements(const LevelRequirements()), 'No limits set');
    expect(
      describeRequirements(
        const LevelRequirements(db: CountLimit(max: 8), da: CountLimit(min: 1)),
      ),
      'DB up to 8 · DA at least 1',
    );
  });
}
