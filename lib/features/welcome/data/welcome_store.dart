import 'package:shared_preferences/shared_preferences.dart';

/// The version of the welcome screen. Bump it to show the welcome screen
/// again to everyone once, e.g. after a big change to the app.
const welcomeVersion = 1;

/// Remembers which welcome screen version the user has seen, so it shows on
/// the first launch only.
abstract interface class WelcomeStore {
  /// 0 when the user has never seen a welcome screen.
  Future<int> seenVersion();

  Future<void> markSeen(int version);
}

/// Keeps the version in shared_preferences (`welcome_version`): a device
/// setting, not routine data, so it stays out of the database.
class SharedPreferencesWelcomeStore implements WelcomeStore {
  const SharedPreferencesWelcomeStore();

  static const _key = 'welcome_version';

  @override
  Future<int> seenVersion() async =>
      (await SharedPreferences.getInstance()).getInt(_key) ?? 0;

  @override
  Future<void> markSeen(int version) async =>
      (await SharedPreferences.getInstance()).setInt(_key, version);
}

/// Whether to open the app on the welcome screen.
Future<bool> needsWelcome(WelcomeStore store) async =>
    await store.seenVersion() < welcomeVersion;
