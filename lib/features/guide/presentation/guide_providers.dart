import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/guide_store.dart';
import '../domain/guide.dart';

// Wiring for the guide. `main` reads the store before the app starts and
// overrides [initialGuideSettingsProvider]; without that (most tests) the
// guide is off. Guide tests override both providers.

final guideStoreProvider = Provider<GuideStore>(
  (ref) => const SharedPreferencesGuideStore(),
);

final initialGuideSettingsProvider = Provider<GuideSettings>(
  (ref) => GuideSettings.off,
);

final guideControllerProvider =
    NotifierProvider<GuideController, GuideSettings>(GuideController.new);

/// Changes the guide and saves every change.
class GuideController extends Notifier<GuideSettings> {
  @override
  GuideSettings build() => ref.read(initialGuideSettingsProvider);

  /// Guides [routineId] along [path], replacing any other routine's guide.
  void start(String routineId, GuidePath path) => _set(
    GuideSettings(
      enabled: state.enabled,
      active: GuideProgress(routineId: routineId, path: path),
    ),
  );

  /// Marks [step] of [routineId]'s guide as done.
  void tap(String routineId, GuideStep step) {
    final progress = state.forRoutine(routineId);
    if (progress == null) return;
    _set(
      GuideSettings(enabled: state.enabled, active: progress.withTapped(step)),
    );
  }

  /// Ends the current guide (finished or closed); new routines still
  /// offer it.
  void stop() => _set(GuideSettings(enabled: state.enabled));

  /// Turns offering the guide on or off. Off also ends the current guide.
  void setEnabled(bool enabled) => _set(
    GuideSettings(enabled: enabled, active: enabled ? state.active : null),
  );

  void _set(GuideSettings settings) {
    state = settings;
    // A failed save only means the guide may show again next time.
    ref.read(guideStoreProvider).save(settings).ignore();
  }
}
