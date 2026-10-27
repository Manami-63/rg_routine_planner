# RG Routine Planner

Flutter app for rhythmic gymnastics gymnasts and coaches: plan routines, pick
difficulty elements (DB, later DA), and see provisional difficulty totals.

## Commands

- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `dart run build_runner build --delete-conflicting-outputs` after changing
  Drift tables (generated `*.g.dart` files are committed)

## Stack

Flutter, Riverpod 3 (non-generated APIs: `Provider`, `FutureProvider`,
`NotifierProvider`), go_router, Material 3, Drift (SQLite). Code generation
is used only for Drift; no Freezed or Riverpod generators. A Laravel/MySQL
backend is planned later; none exists yet.

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

## Persistence

- `lib/core/database/`: Drift `AppDatabase` and tables. Table/column names
  mirror a future MySQL schema. Dates are stored as ISO-8601 text
  (`build.yaml`), always in UTC (the repository converts); the UI shows
  local time. Bump `schemaVersion` and add a migration on any change, with a
  test in `test/core/database/` that upgrades a hand-written old schema.
- `features/routines/`: `Routine` (id = UUID, name, apparatus, level,
  timestamps, `db` content) and `RoutineRepository`
  (`DriftRoutineRepository`).
- Routines store catalogue ids, never values; values resolve from the
  current catalogue on load. Missing ids, or a different ruleset, load as
  `.unknown(...)` placeholders that keep the id so re-saving loses nothing.
- `DbRoutine` is only the DB content (ruleset, elements with matching
  `elementOptions`, risks). Name,
  apparatus and level live on `Routine`. Edit via
  `routineControllerProvider`; DB helpers are the `DbRoutineEditing`
  extension in `db_routine_providers.dart`.
- Flow: Home -> `/routines` (My routines) -> `/routines/:id/db` (calculator).
- `routineControllerProvider(id)` is an auto-disposing async family: loads
  by id, saves every change (name debounced 500 ms), flushes a pending save
  on dispose, and reports `routineSaveStatusProvider(id)`. Automatic retry
  is off; screens offer a manual Retry. DB widgets take a `routineId`.
- Repository tests use `AppDatabase(NativeDatabase.memory())`. Widget and
  controller tests use `FakeRoutineRepository` (Drift's live queries leave
  timers that widget tests reject). `pumpDbCalculator` in
  `test/features/db_calculator/pump_db_calculator.dart` sets up the screen.

## Scoring rules (important)

- Never invent official FIG element values or competition rules.
- Catalogue data is the FIG Code of Points 2025-2028 (`fig-2025`,
  `data/fig_*.dart`), transcribed from the CoP tables with page/section
  references. It stays `isOfficial: false` until the user has checked the
  transcription. Element names are "code · short description" (the CoP has
  no names). Keep data separate from engines.
- Scores use `Score` (integer hundredths), never `double`.
- Every element, routine and engine carries a ruleset id; engines reject
  mismatched data.
- `ProvisionalDbScoringEngine` only sums the values of what counts. Real
  rules go in a new `DbScoringEngine` implementation, swapped in via
  `dbScoringEngineProvider`.
- Each DB in a routine has `DbElementOptions`: flat foot, slow turn,
  additional rotations (only where the `DbElement` flags allow them) and a
  `manualValue` that replaces the calculated value.
  `DbScoringEngine.elementValue` applies them (CoP #10.3, #10.9,
  #12.2.5-12.2.8); counting ranks by these values. Users can add custom
  elements (`DbElement.custom`, id `custom`) with a manual value, e.g. a DB
  newly approved by FIG.
- Risks (R) are part of DB but modelled separately (`domain/risk.dart`): a
  rotation option (2 rotations 0.20, + 0.10 each) plus criteria, valued
  additively by `DbScoringEngine.riskValue` (CoP #4.2, #4.8-4.10). Each
  criterion has a `RiskPhase` (throw/rotations/catch) and the apparatus it
  applies to; the builder filters by the routine's apparatus. The UI shows
  body difficulties and risks as two tabs with a breakdown.
- `DbCatalogueRepository` serves both element and risk catalogues so they
  always share one ruleset.
- Keep DB and DA logic in separate features.
- Competition levels live in `features/levels/` (shared by DB and DA).
  `LevelRequirements` has DB, risk (R) and DA `CountLimit`s plus
  `requiredBodyGroups`. FIG Senior/Junior presets (`fig_levels.dart`) set
  maximums only, from the FIG CoP 2025-2028 (confirmed by the user; also in
  the Gymnastics Victoria 2026 handbook p.60). Never add other official
  numbers without a source. "Non-FIG level" lets users enter their own
  maximums, optional minimums and required body groups.
- A maximum means "only this many count", never "cannot add more":
  highest-valued N DB, first N risks, first N DA (`DifficultyCategory`).
  `DbCounting` picks what counts; the engine sums only that. Uncounted items
  stay in the routine, greyed out as "Not counted".
- Body groups are required among all DB, counted or not (CoP #2.3.2);
  FIG presets require all three, 0.30 per missing group.
- Count checks and missing body groups are advisory notices, never
  blocking. Penalties are never calculated or deducted (too many causes the
  app cannot see); the UI only warns "you may get a penalty".
- A routine has an optional `Apparatus` (Freehand, Rope, Hoop, Ball, Clubs,
  Ribbon). Levels can have separate `freehandRequirements`
  (`requirementsFor(apparatus)`). Freehand has no risks or DA: risks cannot
  be built and existing ones are not counted.
- The UI must label totals as provisional while any notice is present.

## Tests

Mirror `lib/` under `test/`. Widget tests use fixtures from
`test/features/db_calculator/test_data.dart` rather than catalogue data.
