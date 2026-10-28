import '../../../core/scoring/ruleset.dart';
import '../domain/db_element.dart';
import '../domain/risk.dart';
import 'db_catalogue_repository.dart';
import 'fig_db_elements.dart';
import 'fig_risks.dart';
import '../../../core/scoring/fig_ruleset.dart';

/// Serves the FIG DB and risk catalogues from memory.
class FigDbCatalogueRepository implements DbCatalogueRepository {
  const FigDbCatalogueRepository();

  @override
  RulesetVersion get ruleset => figRuleset;

  @override
  Future<List<DbElement>> fetchElements() async => figDbElements;

  @override
  Future<RiskCatalogue> fetchRiskCatalogue() async => RiskCatalogue(
    rotationOptions: figRiskRotationOptions,
    criteria: figRiskCriteria,
  );
}
