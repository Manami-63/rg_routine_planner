import 'package:flutter_test/flutter_test.dart';
import 'package:rg_routine_planner/core/scoring/apparatus.dart';
import 'package:rg_routine_planner/features/db_calculator/data/fig_db_catalogue_repository.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/db_element.dart';
import 'package:rg_routine_planner/features/db_calculator/domain/risk.dart';

void main() {
  const repository = FigDbCatalogueRepository();

  group('FigDbCatalogueRepository', () {
    late List<DbElement> elements;

    setUp(() async => elements = await repository.fetchElements());

    test('stays unofficial until the transcription is checked', () {
      expect(repository.ruleset.isOfficial, isFalse);
      expect(repository.ruleset.label, contains('FIG'));
    });

    test('has every element of the jump, balance and rotation tables', () {
      int countOf(DbElementGroup group) =>
          elements.where((e) => e.group == group).length;

      expect(countOf(DbElementGroup.jump), 70);
      expect(countOf(DbElementGroup.balance), 36);
      expect(countOf(DbElementGroup.rotation), 33);
    });

    test('every element is in the ruleset with a unique id', () {
      expect(elements.map((e) => e.id).toSet().length, elements.length);
      for (final element in elements) {
        expect(element.rulesetId, repository.ruleset.id);
      }
    });

    test('code prefix, name and value match each element', () {
      const prefixes = {
        DbElementGroup.jump: '1.',
        DbElementGroup.balance: '2.',
        DbElementGroup.rotation: '3.',
      };
      for (final element in elements) {
        final code = element.id.substring('fig-'.length);
        expect(code, startsWith(prefixes[element.group]!), reason: code);
        expect(element.name, startsWith('$code · '), reason: code);
        // The last digit of a code repeats its value column (0.10-0.80).
        expect(
          element.value.hundredths,
          int.parse(code[code.length - 1]) * 10,
          reason: code,
        );
      }
    });

    test('options only on the kinds of element that allow them', () {
      for (final element in elements) {
        if (element.canBeOnFlatFoot || element.canSlowTurn) {
          expect(element.group, DbElementGroup.balance, reason: element.id);
        }
        if (element.extraRotationValue != null) {
          expect(element.group, DbElementGroup.rotation, reason: element.id);
        }
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
  });
}
