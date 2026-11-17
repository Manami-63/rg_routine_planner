import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/guide.dart';

/// Remembers whether the guide is on and the routine being guided.
abstract interface class GuideStore {
  Future<GuideSettings> load();

  Future<void> save(GuideSettings settings);
}

/// Keeps the guide in shared_preferences (`guide_enabled`, `guide_active`):
/// a device setting, not routine data, so it stays out of the database and
/// out of shared and backed-up routines.
class SharedPreferencesGuideStore implements GuideStore {
  const SharedPreferencesGuideStore();

  static const _enabledKey = 'guide_enabled';
  static const _activeKey = 'guide_active';

  @override
  Future<GuideSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getString(_activeKey);
    GuideProgress? progress;
    if (active != null) {
      try {
        progress = GuideProgress.fromJson(jsonDecode(active));
      } on FormatException {
        progress = null;
      }
    }
    return GuideSettings(
      enabled: prefs.getBool(_enabledKey) ?? true,
      active: progress,
    );
  }

  @override
  Future<void> save(GuideSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, settings.enabled);
    final active = settings.active;
    if (active == null) {
      await prefs.remove(_activeKey);
    } else {
      await prefs.setString(_activeKey, jsonEncode(active.toJson()));
    }
  }
}
