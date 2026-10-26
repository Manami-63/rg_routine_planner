import '../../../core/scoring/ruleset.dart';
import '../domain/db_element.dart';
import '../domain/risk.dart';
import 'db_catalogue_repository.dart';
import 'sample_db_elements.dart';
import 'sample_risks.dart';
import 'sample_ruleset.dart';

/// Serves the clearly-labelled sample catalogues from memory.
class SampleDbCatalogueRepository implements DbCatalogueRepository {
  const SampleDbCatalogueRepository();

  @override
  RulesetVersion get ruleset => sampleRuleset;

  @override
  Future<List<DbElement>> fetchElements() async => sampleDbElements;

  @override
  Future<RiskCatalogue> fetchRiskCatalogue() async => RiskCatalogue(
    rotationOptions: sampleRiskRotationOptions,
    criteria: sampleRiskCriteria,
  );
}
