import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';
import 'package:rg_routine_planner/features/db_calculator/data/sample_db_catalogue_repository.dart';

void main() {
  const repository = SampleDbCatalogueRepository();

  group('SampleDbCatalogueRepository', () {
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

    test('risk rotations follow the FIG base and additional values', () async {
      final catalogue = await repository.fetchRiskCatalogue();

      // CoP 2025-2028 #4.2.1 and #4.8.1: 2 rotations 0.20, + 0.10 each.
      expect(catalogue.rotationOptions.first.rotations, 2);
      for (final option in catalogue.rotationOptions) {
        expect(option.rulesetId, repository.ruleset.id);
        expect(option.value.hundredths, 20 + (option.rotations - 2) * 10);
      }
    });

    test('risk criteria are in the ruleset with unique ids', () async {
      final catalogue = await repository.fetchRiskCatalogue();
      final ids = catalogue.criteria.map((c) => c.id).toSet();

      expect(ids.length, catalogue.criteria.length);
      for (final criterion in catalogue.criteria) {
        expect(criterion.rulesetId, repository.ruleset.id);
        expect(criterion.phase, isNotNull);
      }
    });

    test('Ribbon has only the general criteria', () async {
      final catalogue = await repository.fetchRiskCatalogue();

      for (final phase in RiskPhase.values) {
        expect(
          catalogue.criteriaFor(phase, Apparatus.ribbon),
          catalogue.criteriaFor(phase, null),
        );
      }
    });

    test('element ids are unique', () async {
      final elements = await repository.fetchElements();
      final ids = elements.map((e) => e.id).toSet();

      expect(ids.length, elements.length);
    });
  });
}
