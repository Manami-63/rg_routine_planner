import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the screen on, e.g. during a rehearsal in Play mode. Wraps the
/// plugin so widget tests can use a fake.
abstract interface class ScreenAwake {
  Future<void> enable();
  Future<void> disable();
}

class WakelockScreenAwake implements ScreenAwake {
  const WakelockScreenAwake();

  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}

final screenAwakeProvider = Provider<ScreenAwake>(
  (ref) => const WakelockScreenAwake(),
);
