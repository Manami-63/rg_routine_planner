import 'package:rg_routine_planner/core/device/screen_awake.dart';

/// Records whether the screen is being kept on.
class FakeScreenAwake implements ScreenAwake {
  var enabled = false;

  @override
  Future<void> enable() async => enabled = true;

  @override
  Future<void> disable() async => enabled = false;
}
