import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/welcome/data/welcome_store.dart';
import 'features/welcome/presentation/welcome_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Routine music plays like a music app (e.g. even in silent mode).
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  final showWelcome = await needsWelcome(const SharedPreferencesWelcomeStore());
  runApp(
    ProviderScope(
      overrides: [startWithWelcomeProvider.overrideWithValue(showWelcome)],
      child: const RgRoutinePlannerApp(),
    ),
  );
}
