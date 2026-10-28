import '../../../core/scoring/fig_ruleset.dart';
import '../../../core/scoring/ruleset.dart';
import '../domain/da_base.dart';
import 'da_catalogue_repository.dart';
import 'fig_da_bases.dart';

/// Serves the FIG DA bases from memory.
class FigDaCatalogueRepository implements DaCatalogueRepository {
  const FigDaCatalogueRepository();

  @override
  RulesetVersion get ruleset => figRuleset;

  @override
  Future<List<DaBase>> fetchBases() async => figDaBases;
}
