import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/features/db_calculator/data/sample_db_element_repository.dart';

void main() {
  const repository = SampleDbElementRepository();

  group('SampleDbElementRepository', () {
    test('is explicitly marked as unofficial sample data', () {
      expect(repository.ruleset.isOfficial, isFalse);
      expect(repository.ruleset.label, contains('Sample'));
    });

    test('every element belongs to the sample ruleset', () async {
      final elements = await repository.fetchElements();

      expect(elements, isNotEmpty);
      for (final element in elements) {
        expect(element.rulesetId, repository.ruleset.id);
      }
    });

    test('every element is clearly named as a sample', () async {
      final elements = await repository.fetchElements();

      for (final element in elements) {
        expect(element.name, startsWith('Sample '));
      }
    });

    test('element ids are unique', () async {
      final elements = await repository.fetchElements();
      final ids = elements.map((e) => e.id).toSet();

      expect(ids.length, elements.length);
    });
  });
}
