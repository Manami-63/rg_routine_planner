import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db_calculator/domain/db_routine.dart';
import '../../levels/domain/competition_level.dart';
import '../domain/routine.dart';
import 'routine_providers.dart';

/// Thrown when the requested routine does not exist (e.g. it was deleted).
class RoutineNotFoundException implements Exception {
  const RoutineNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'Routine $id not found';
}

enum SaveStatus { saved, saving, failed }

/// One controller per routine id ("family"), loaded from the repository.
///
/// `autoDispose`: when the calculator screen closes, the controller is
/// disposed and any pending save is written immediately.
final routineControllerProvider = AsyncNotifierProvider.autoDispose
    .family<RoutineController, Routine, String>(
      RoutineController.new,
      // A missing routine will not appear by retrying; real errors get a
      // manual Retry button instead of a long automatic back-off.
      retry: (_, _) => null,
    );

/// The loaded routine. Only watch this once [routineControllerProvider] has
/// data (the calculator screen handles loading and errors first).
final routineProvider = Provider.autoDispose.family<Routine, String>(
  (ref, id) => ref.watch(routineControllerProvider(id)).requireValue,
);

/// Shown in the app bar so users can trust automatic saving.
final routineSaveStatusProvider = NotifierProvider.autoDispose
    .family<SaveStatusNotifier, SaveStatus, String>(SaveStatusNotifier.new);

class SaveStatusNotifier extends Notifier<SaveStatus> {
  SaveStatusNotifier(this.routineId);

  final String routineId;

  @override
  SaveStatus build() => SaveStatus.saved;

  void set(SaveStatus status) => state = status;
}

class RoutineController extends AsyncNotifier<Routine> {
  RoutineController(this.routineId);

  final String routineId;

  /// Typing pauses this long before the name is saved.
  static const nameSaveDelay = Duration(milliseconds: 500);

  Timer? _debounce;

  /// The routine waiting for a debounced save, if any. Kept in a field
  /// because `state` must not be read while the notifier is disposing.
  Routine? _pending;

  /// Saves run one after another, so an older save can never overwrite a
  /// newer one.
  Future<void> _saveChain = Future.value();

  @override
  Future<Routine> build() async {
    final repository = ref.watch(routineRepositoryProvider);
    ref.onDispose(() {
      // Flush a pending (debounced) save when leaving the screen.
      _debounce?.cancel();
      final pending = _pending;
      if (pending != null) {
        _saveChain = _saveChain.then((_) => repository.saveRoutine(pending));
      }
    });

    final routine = await repository.fetchRoutine(routineId);
    if (routine == null) throw RoutineNotFoundException(routineId);
    return routine;
  }

  void rename(String name) =>
      _update((routine) => routine.rename(name), debounce: true);

  void selectLevel(CompetitionLevel? level) =>
      _update((routine) => routine.withLevel(level));

  /// Applies a change to the DB content. DB-specific helpers live in the
  /// DB calculator feature (see `DbRoutineEditing`).
  void updateDb(DbRoutine Function(DbRoutine db) change) =>
      _update((routine) => routine.withDb(change(routine.db)));

  /// Saves now, e.g. to retry after a failure.
  void saveNow() => _save();

  void _update(Routine Function(Routine) change, {bool debounce = false}) {
    final updated = change(state.requireValue)
        .withUpdatedAt(DateTime.now().toUtc());
    state = AsyncData(updated);

    _debounce?.cancel();
    if (debounce) {
      _pending = updated;
      _setStatus(SaveStatus.saving);
      _debounce = Timer(nameSaveDelay, _save);
    } else {
      _save();
    }
  }

  void _save() {
    _debounce?.cancel();
    _pending = null;
    final routine = state.requireValue;
    final repository = ref.read(routineRepositoryProvider);
    _setStatus(SaveStatus.saving);
    _saveChain = _saveChain
        .then((_) => repository.saveRoutine(routine))
        .then(
          (_) => _setStatus(SaveStatus.saved),
          onError: (Object _) => _setStatus(SaveStatus.failed),
        );
  }

  void _setStatus(SaveStatus status) {
    // A save can finish after the screen (and this controller) is gone.
    if (!ref.mounted) return;
    ref.read(routineSaveStatusProvider(routineId).notifier).set(status);
  }
}
