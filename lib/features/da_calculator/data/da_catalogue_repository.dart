import '../../../core/scoring/ruleset.dart';
import '../domain/da_base.dart';

/// Source of the DA bases (with their criteria) for one ruleset.
///
/// Async on purpose, like the DB catalogue, so another source can be
/// dropped in later without changing any caller.
abstract interface class DaCatalogueRepository {
  RulesetVersion get ruleset;

  Future<List<DaBase>> fetchBases();
}
