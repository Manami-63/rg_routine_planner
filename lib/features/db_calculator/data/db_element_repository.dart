import '../../../core/scoring/ruleset.dart';
import '../domain/db_element.dart';

/// Source of DB catalogue elements for one ruleset.
///
/// Async on purpose: today the data is in memory, but a Drift/SQLite or
/// asset-backed implementation can be dropped in later without changing
/// any caller.
abstract interface class DbElementRepository {
  RulesetVersion get ruleset;

  Future<List<DbElement>> fetchElements();
}
