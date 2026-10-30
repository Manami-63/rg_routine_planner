import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/levels/domain/difficulty_category.dart';

void main() {
  test('one risk is singular; DB and DA never change', () {
    expect(DifficultyCategory.risk.nounFor(1), 'risk');
    expect(DifficultyCategory.risk.nounFor(0), 'risks');
    expect(DifficultyCategory.risk.nounFor(3), 'risks');
    expect(DifficultyCategory.db.nounFor(1), 'DB');
    expect(DifficultyCategory.da.nounFor(1), 'DA');
  });
}
