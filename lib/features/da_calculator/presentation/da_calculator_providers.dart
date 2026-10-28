import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/da_catalogue_repository.dart';
import '../data/fig_da_catalogue_repository.dart';
import '../domain/da_base.dart';
import '../domain/da_scoring_engine.dart';

// This file is the feature's wiring: the only place that decides which
// concrete repository and engine are used. Tests override
// `daCatalogueRepositoryProvider` to supply their own data.

final daCatalogueRepositoryProvider = Provider<DaCatalogueRepository>(
  (ref) => const FigDaCatalogueRepository(),
);

/// The engine always matches the repository's ruleset.
final daScoringEngineProvider = Provider<DaScoringEngine>(
  (ref) => ProvisionalDaScoringEngine(
    ruleset: ref.watch(daCatalogueRepositoryProvider).ruleset,
  ),
);

final daBasesProvider = FutureProvider<List<DaBase>>(
  (ref) => ref.watch(daCatalogueRepositoryProvider).fetchBases(),
  // Local data will not fix itself on a retry; the user can retry manually.
  retry: (_, _) => null,
);
