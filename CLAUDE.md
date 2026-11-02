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
  `RgSymbol`, shared widgets). `lib/app/` holds the app shell, router and theme.

## Persistence

- `lib/core/database/`: Drift `AppDatabase` and tables. Table/column names
  mirror a future MySQL schema. Dates are stored as ISO-8601 text
  (`build.yaml`), always in UTC (the repository converts); the UI shows
  local time. Bump `schemaVersion` and add a migration on any change, with a
  test in `test/core/database/` that upgrades a hand-written old schema.
- `features/routines/`: `Routine` (id = UUID, name, apparatus, level,
  free-text `notes`, optional `music`, `danceStepTimes`, timestamps, `db`
  and `da` content) and `RoutineRepository`
  (`DriftRoutineRepository`). Shared pieces live here too: `RoutineLoader`
  (loading/errors/ruleset), `RoutineDetailsForm` (name, apparatus, level;
  used for New routine and Edit details), `duplicateRoutine` and
  `SaveStatusIndicator`.
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
- Flow: Home -> `/routines` (My routines) -> `/routines/:id` (routine
  page, `features/routine_editor/`). My routines can be searched (name and
  notes) and filtered by apparatus and level (`RoutineFilter`, reset when
  the screen closes). New routine opens the details form
  first (apparatus required for new routines). The routine page shows the
  name and "apparatus · level" in its app bar (edit with the pencil), and
  tabs DB | R | DA | Notes | Music (`RoutineTab`; `?tab=risks|da|notes|music`
  opens another tab). DB, R and DA each have their own add button; `RoutineTotalBar` below shows DB + DA = the
  provisional total and the open tab's breakdown. The tab widgets live in
  their features (`db_tabs.dart`, `da_tab.dart`). DB, risks and DA are
  listed in performance order and reordered with a drag handle.
- `RoutineScore` (`routine_editor/domain/`) is DB + DA for a routine, with
  its level's limits (`DbCountLimits.of`, `daMaxCounted`). My routines
  shows each routine's total (`savedRoutineScoreProvider`, keyed by id and
  `updatedAt`). The routine page builds it from `dbScoreResultProvider` and
  `daScoreResultProvider` in the widget: a provider combining them is
  refreshed while the page resumes after a full-screen form, which
  Riverpod rejects.
- Music (`features/music/`): `RoutineMusic` stores the file name of the
  app's own copy (in the app support `music/` folder, never a full path)
  and the title the user sees. `MusicLibrary` adds, copies and deletes
  copies: replacing or removing music deletes the old copy, Duplicate
  gives the new routine its own copy, deleting a routine deletes its copy
  (`deleteRoutine`). `MusicPicker` (file_picker) and `MusicPlayer`
  (just_audio) are wrapped so widget tests use the fakes in
  `test/features/music/fake_music.dart` (`pumpDbCalculator` sets them up).
  `MusicPlayerControls` (Music tab and Play mode) has a playback speed
  (0.5×-1×, for learning; not saved, back to 1× when the routine is opened
  again). Music times are always in music time, whatever the speed.
- Dance steps combinations (S, `features/dance_steps/`): no details, only
  an optional music time each (`Routine.danceStepTimes`; the count is its
  length), set with `DanceStepsCard` at the top of the DB tab. Levels have
  an optional `minDanceSteps` (FIG 2 and 0.30 per missing S, CoP #5.3.1
  p.108, Junior by annex #9.1 p.133; Non-FIG set in the level picker). S
  are artistry, not difficulty: a missing one is only a notice and never
  affects the total. `danceStepConflicts` (`dance_steps/domain/`) flags
  risks (high throws), DA and DB worth 0.20 or more marked within 8 s of an
  S's time (#5.2.1, #5.2.5), shown on the S card, the timeline rows and in
  Play mode (advisory, like all notices). Pre-acrobatic elements outside
  DA/R are not recorded, so not checked.
- Music times: each DB, risk, DA and S has an optional time
  (`DbRoutine.elementTimes`/`riskTimes`, `DaRoutine.times`, parallel to
  their lists and moved with them; `time_ms` columns and the
  `routine_dance_steps` table). `RoutineTimeline` (`routine_editor/domain/`)
  combines them; `TimelineSection` (shown by `MusicTab` below the player)
  has "Next DB/R/DA/S" buttons that mark the first unmarked item at the
  player position, and the marked items by time with ±0.1 s nudges.
  Setting a time puts the timed items of that kind in time order
  (`timeOrder`; untimed items keep their places), so the first N risks and
  DA follow the music.
  When every item of a kind is marked (or there are none) its button
  becomes "Add DB/R/DA/S", so a routine can be built from the music: it
  pauses the music, opens the usual picker for one item
  (`ElementPickerScreen.addOne`, `RiskBuilderSheet`, `DaBuilderSheet`) and
  marks the new item at the time of the tap. S have nothing to choose, so
  the music plays on. While still paused, adding the other kind makes a DB
  and DA together.
  The "Choose later" switch above the buttons (not saved) makes Add only
  mark the moment: the music plays on and a placeholder is added
  (`withPendingAdded`). `DbElement.pending`, `RiskRotationOption.pending` and
  `DaBase.pending` are stored with the id `pending`, like custom items, so
  no schema change. They show "Not chosen yet" and are chosen from the
  timeline's Choose button or by tapping their list row, which replaces them
  and keeps the time and cell (`replaceIndex`/`index`). A pending DB is
  worth nothing and is not counted as a DB; a pending risk or DA also adds
  nothing but holds its place, because the first N count.
- Floor locations: each DB, risk, DA and S can also have a `FloorCell`
  (`lib/core/floor/`: a 3 x 3 grid of the floor, front/judges at the
  bottom; corners and centre stand for the 5 zones of CoP #9.2.1.A),
  parallel to the times (`elementCells`, `riskCells`, `DaRoutine.cells`,
  `danceStepCells`; `floor_cell` columns hold 1-9). Cells are only kept
  for timed items (clearing a time clears its cell). Dragging a "Next"
  button onto `FloorMat` marks the time (taken at finger down) and the
  cell; a timeline row's grid button changes it. `floor_checks.dart`:
  zones visited, zones only crossed by a straight move between items
  (`FloorCell.crossedTo`, a guess), and 3+ Difficulties in a row in one
  cell (#9.4.1; R and jumps excluded, a DB and a DA together count as
  one). Shown by `FloorNotices` under the mat.
- DB and DA together ("in the same moment", #9.4.1): a DB and a DA with
  exactly the same time (`RoutineTimeline.partnerOf`; no stored link).
  A drop on the mat pauses the music; marking the other kind (tap or
  drop) before playing on gives it the dropped item's time. Nudges move
  both (`withTimeMoved`); a timeline row's link button splits (moves only
  that item 0.1 s) or pairs (takes the chosen item's time). Play mode shows
  a pair together ("DB 2 + DA 3", `PlayModeFrame.currentPartner`).
- Item colours (`ItemColours` in `routine_editor/presentation/`): DB
  blue, DA red, R amber, S green, a DB and a DA together purple. Each hue
  is harmonised towards the theme's primary (material_color_utilities)
  and taken at Material's custom-colour tones for light or dark, so they
  fit the plum theme but stay distinct. Used by the Next buttons, mat
  labels and timeline rows, and in Play mode. Add new kinds' hues there.
- Play mode (`PlayModeScreen`, opened from the timeline): full-screen and
  dark, sharing the routine page's player. `playModeFrameAt`
  (`routine_editor/domain/play_mode.dart`) decides what shows: each item
  for 3 s from its time, an S's 8 s countdown, and the next item. One
  fixed layout so nothing jumps: the current item (or the next, dimmed) at
  the top, a large floor mat (current cell filled, next cell outlined),
  the next item, then the player. During an S a see-through layer with the countdown covers the
  page. It keeps the
  screen on while open (`ScreenAwake` in `lib/core/device/`, wrapping
  wakelock_plus; widget tests get `FakeScreenAwake` from
  `pumpDbCalculator`).
- Sharing: `RoutineFile` (`routines/domain/`) is the `.rgroutine` file
  (JSON with a `format` number, bumped on a breaking change; ids, never
  values). Share (My routines and routine page menus) sends it through the
  system share sheet; Import routine (My routines app bar, also when empty)
  saves it as a new routine, which resolves its ids on load. If the routine
  has music, Share asks whether to include it (base64 in the file; the
  importer gets its own copy); its times always go. Opening a file from
  another app imports it the same way (`RgRoutinePlannerApp` listens; the
  channel `rg_routine_planner/opened_files` is in `AppDelegate.swift`,
  `SceneDelegate.swift` and `MainActivity.kt`). `RoutineFileTransfer` wraps share_plus
  and file_picker; widget tests use `FakeRoutineFileTransfer`.
- Welcome (`features/welcome/`): `WelcomeScreen` (`/welcome`) shows the
  intro video (`IntroVideo`, video_player, `assets/videos/intro.mp4`,
  muted and looping; an icon while the file is missing) and three short
  steps. It opens on the first launch: `main` reads `WelcomeStore`
  (shared_preferences `welcome_version`, not the database) and overrides
  `startWithWelcomeProvider`. Bump `welcomeVersion` to show it again once.
  Home's "How it works" opens it again. No login (planned as optional with
  the backend). Tests override `introVideoProvider` and use
  `FakeWelcomeStore`.
- `routineControllerProvider(id)` is an auto-disposing async family: loads
  by id, saves every change (name and notes debounced 500 ms), flushes a pending save
  on dispose, and reports `routineSaveStatusProvider(id)`. Automatic retry
  is off; screens offer a manual Retry. DB and DA widgets take a
  `routineId`.
- Repository tests use `AppDatabase(NativeDatabase.memory())`. Widget and
  controller tests use `FakeRoutineRepository` (Drift's live queries leave
  timers that widget tests reject). `pumpDbCalculator` in
  `test/features/db_calculator/pump_db_calculator.dart` sets up the routine
  page with fake DB and DA catalogues (`pumpDaCalculator` opens the DA
  tab).

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
  choice per routine, set in the details form, where the picker edits all
  numbers together. No other presets are planned (Australian levels were
  dropped): other levels are entered by users.
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

## Symbols

`RgSymbol` (`lib/core/symbols/`) is the shared FIG notation (CoP #3.3, #3.4,
criteria #5.4.3), redrawn as vectors by `RgSymbolView`, never copied from the
CoP images. Every catalogue DA base, DA criterion, risk criterion and DB has one. `DaSymbols` writes a DA like a coach's
sheet, "base (criteria)", only when every part has a symbol; otherwise the
name shows. Play mode shows the symbols instead of the name; lists show both.
`RiskSymbols`
writes a risk like a coach's sheet: throw criteria, "R3", rotation criteria,
catch criteria. `entrySymbols` picks the widget for a timeline entry. DB symbols each have their own drawing, so they are data:
`DbElement.symbolPath` holds a `SymbolPath` text from `fig_db_symbols.dart`
(every catalogue DB). Symbols are display only:
never store them or use them in scoring.

## Tests

Mirror `lib/` under `test/`. Widget tests use fixtures from
`test/features/db_calculator/test_data.dart` and
`test/features/da_calculator/test_data.dart` rather than catalogue data.
