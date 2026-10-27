import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db_catalogue_repository.dart';
import '../data/fig_db_catalogue_repository.dart';
import '../domain/db_element.dart';
import '../domain/db_scoring_engine.dart';
import '../domain/risk.dart';

// This file is the feature's wiring: the only place that decides which
// concrete repository and engine are used. Tests override
// `dbCatalogueRepositoryProvider` to supply their own data.

final dbCatalogueRepositoryProvider = Provider<DbCatalogueRepository>(
  (ref) => const FigDbCatalogueRepository(),
);

/// The engine always matches the repository's ruleset, so catalogue values
/// and calculation rules cannot drift apart.
final dbScoringEngineProvider = Provider<DbScoringEngine>(
  (ref) => ProvisionalDbScoringEngine(
    ruleset: ref.watch(dbCatalogueRepositoryProvider).ruleset,
  ),
);

final dbElementsProvider = FutureProvider<List<DbElement>>(
  (ref) => ref.watch(dbCatalogueRepositoryProvider).fetchElements(),
  // Local data will not fix itself on a retry; the user can retry manually.
  retry: (_, _) => null,
);

final riskCatalogueProvider = FutureProvider<RiskCatalogue>(
  (ref) => ref.watch(dbCatalogueRepositoryProvider).fetchRiskCatalogue(),
  retry: (_, _) => null,
);
