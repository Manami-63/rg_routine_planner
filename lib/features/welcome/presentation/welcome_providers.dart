import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/welcome_store.dart';
import 'intro_video.dart';

// Wiring for the welcome screen. Widget tests override the store and the
// video (the video plugin does not run in tests).

final welcomeStoreProvider = Provider<WelcomeStore>(
  (ref) => const SharedPreferencesWelcomeStore(),
);

/// Whether the app opens on the welcome screen. `main` reads the store
/// before the app starts and overrides this.
final startWithWelcomeProvider = Provider<bool>((ref) => false);

final introVideoProvider = Provider<Widget>((ref) => const IntroVideo());
