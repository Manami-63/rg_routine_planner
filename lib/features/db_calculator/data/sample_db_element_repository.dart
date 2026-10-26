import '../../../core/scoring/ruleset.dart';
import '../domain/db_element.dart';
import 'db_element_repository.dart';
import 'sample_db_elements.dart';

/// Serves the clearly-labelled sample catalogue from memory.
class SampleDbElementRepository implements DbElementRepository {
  const SampleDbElementRepository();

  @override
  RulesetVersion get ruleset => sampleRuleset;

  @override
  Future<List<DbElement>> fetchElements() async => sampleDbElements;
}
