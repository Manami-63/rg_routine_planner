import '../../../core/scoring/ruleset.dart';
import '../domain/db_element.dart';
import '../domain/risk.dart';

/// Source of everything that counts towards DB for one ruleset: body
/// difficulty elements and risk building blocks.
///
/// One repository serves both so they always share a single ruleset.
/// Async on purpose: today the data is in memory, but a Drift/SQLite or
/// asset-backed implementation can be dropped in later without changing
/// any caller.
abstract interface class DbCatalogueRepository {
  RulesetVersion get ruleset;

  Future<List<DbElement>> fetchElements();

  Future<RiskCatalogue> fetchRiskCatalogue();
}
