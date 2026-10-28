# RG Routine Planner

Flutter app for rhythmic gymnastics gymnasts and coaches: plan routines, pick
difficulty elements (DB) and apparatus difficulties (DA), and see
provisional difficulty totals.

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
  timestamps, `db` and `da` content) and `RoutineRepository`
  (`DriftRoutineRepository`). Shared calculator pieces live here too:
  `RoutineLoader` (loading/errors/ruleset), `RoutineDetailsFields` (DB/DA
  page switch, name, apparatus, level) and `SaveStatusIndicator`.
- Routines store catalogue ids, never values; values resolve from the
  current catalogue on load. Missing ids, or a different ruleset, load as
  `.unknown(...)` placeholders that keep the id so re-saving loses nothing.
- `DbRoutine` is only the DB content (ruleset, elements with matching
  `elementOptions`, risks). Name,
  apparatus and level live on `Routine`. Edit via
  `routineControllerProvider`; DB helpers are the `DbRoutineEditing`
  extension in `db_routine_providers.dart`.
- `DaRoutine` is the DA content (ruleset, `DaElement`s in performance
  order). DA helpers are `DaRoutineEditing` in `da_routine_providers.dart`.
- Flow: Home -> `/routines` (My routines) -> `/routines/:id/db` or
  `/routines/:id/da` (calculators; the header switches between them with
  `context.go`, so Back returns to My routines).
- `routineControllerProvider(id)` is an auto-disposing async family: loads
  by id, saves every change (name debounced 500 ms), flushes a pending save
  on dispose, and reports `routineSaveStatusProvider(id)`. Automatic retry
  is off; screens offer a manual Retry. DB and DA widgets take a
  `routineId`.
- Repository tests use `AppDatabase(NativeDatabase.memory())`. Widget and
  controller tests use `FakeRoutineRepository` (Drift's live queries leave
  timers that widget tests reject). `pumpDbCalculator` in
  `test/features/db_calculator/pump_db_calculator.dart` sets up the screen
  (`pumpDaCalculator` likewise for DA).

## Scoring rules (important)

- Never invent official FIG element values or competition rules.
- Catalogue data is the FIG Code of Points 2025-2028 (`fig-2025`,
  `data/fig_*.dart`), transcribed from the CoP tables with page/section
  references. The user has checked the DB and risk transcription, so it is
  `isOfficial: true`; the DA tables (added later) still need their check.
  Correct any value only from the CoP. Element names
  are "code · short description" (the CoP has no names). Keep data
  separate from engines.
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
  #12.2.5-12.2.8); counting ranks by these values. `seriesCount` makes one
  entry a series of identical DB, each counting as 1 DB (#2.4.3, #8.10,
  #12.8; only where `canBeInSeries`). Repeating an element (same id, not
  custom) is not valid and worth nothing (#2.4.2), unless the entry has a
  manual value, which is how users handle levels with other rules. Users can add custom
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
- Keep DB and DA logic in separate features (`features/da_calculator/`).
- A DA is a `DaBase` (FIG tables #5.8-5.11, Junior Rope #7.3, in
  `data/fig_da_bases.dart` with criteria patterns per table row) plus
  `DaCriterion`s; "N/A" criteria cannot be chosen. 1 base needs 2 criteria;
  a "catch from a high throw" base (`startsCombination`) may take a 2nd base
  with 1 criterion during both, worth the highest base + 0.10 (#5.1.3,
  #5.3). `DaScoringEngine.calculate` gives each entry a `DaStatus`: not a
  DA (too few criteria, other apparatus, unknown base) uses no counted DA;
  not valid (identical repetition #5.6.2, 4th pre-acrobatic rotation
  #5.4.7) uses one but adds nothing. The first N DA count (#5.2.1). More
  than 3 in a row on the floor is only a warning (#5.4.6). A manual value
  (or a custom DA) replaces the value and the checks.
- Competition levels live in `features/levels/` (shared by DB and DA).
  `LevelRequirements` has DB, risk (R) and DA `CountLimit`s plus
  `requiredBodyGroups`. FIG Senior/Junior presets (`fig_levels.dart`) set
  maximums only, from the FIG CoP 2025-2028 (confirmed by the user; also in
  the Gymnastics Victoria 2026 handbook p.60). Never add other official
  numbers without a source. "Non-FIG level" lets users enter their own
  maximums, optional minimums and required body groups. The level is one
  choice per routine, but each page edits only its own numbers
  (`LevelSelector.categories`: DB and R plus body groups on the DB page, DA
  on the DA page).
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
  (`requirementsFor(apparatus)`). Freehand has no risks or DA: they cannot
  be built and existing ones are not counted.
- The UI must label totals as provisional while any notice is present.

## Tests

Mirror `lib/` under `test/`. Widget tests use fixtures from
`test/features/db_calculator/test_data.dart` and
`test/features/da_calculator/test_data.dart` rather than catalogue data.
