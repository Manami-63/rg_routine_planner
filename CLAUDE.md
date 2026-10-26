# RG Routine Planner

Flutter app for rhythmic gymnastics gymnasts and coaches: plan routines, pick
difficulty elements (DB, later DA), and see provisional difficulty totals.

## Commands

- `dart format lib test`
- `flutter analyze`
- `flutter test`

## Stack

Flutter, Riverpod 3 (non-generated APIs: `Provider`, `FutureProvider`,
`NotifierProvider`), go_router, Material 3. No code generation, no Freezed.
Drift/SQLite is planned for routine persistence but not added yet.

## Architecture

Feature-first: `lib/features/<feature>/{domain,data,presentation}`.

- `domain/` is pure Dart (no Flutter imports): immutable models and scoring
  engines.
- `data/` holds repository interfaces and implementations.
- `presentation/` holds widgets, Riverpod providers and controllers.
  `<feature>_providers.dart` is the single place that wires concrete
  repositories/engines; tests override providers there.
- `lib/core/` holds code shared across features (`Score`, `RulesetVersion`,
  shared widgets). `lib/app/` holds the app shell, router and theme.

## Scoring rules (important)

- Never invent official FIG element values or competition rules.
- All catalogue data is currently **sample data** (`sample-v0`,
  `isOfficial: false`), with names starting `Sample `. Keep it in
  `data/sample_*.dart`, separate from engines.
- Scores use `Score` (integer hundredths), never `double`.
- Every element, routine and engine carries a ruleset id; engines reject
  mismatched data.
- `ProvisionalDbScoringEngine` only sums values. Real rules go in a new
  `DbScoringEngine` implementation, swapped in via `dbScoringEngineProvider`.
- Keep DB and DA logic in separate features.
- The UI must label totals as provisional while any notice is present.

## Tests

Mirror `lib/` under `test/`. Widget tests use fixtures from
`test/features/db_calculator/test_data.dart` rather than sample data.
