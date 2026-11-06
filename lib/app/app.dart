import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/routines/presentation/routine_actions.dart';
import '../features/routines/presentation/routine_providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class RgRoutinePlannerApp extends ConsumerStatefulWidget {
  const RgRoutinePlannerApp({super.key});

  @override
  ConsumerState<RgRoutinePlannerApp> createState() =>
      _RgRoutinePlannerAppState();
}

class _RgRoutinePlannerAppState extends ConsumerState<RgRoutinePlannerApp> {
  // A routine file can be opened on any screen.
  final _messenger = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // After the first frame, so a file that launched the app has a messenger.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(routineFileTransferProvider).onFileOpened(_import);
    });
  }

  void _import(String path) {
    final messenger = _messenger.currentState;
    if (messenger == null) return;
    importRoutineFile(
      ref,
      () => ref.read(routineFileTransferProvider).readOpened(path),
      messenger: messenger,
      router: ref.read(routerProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RG Routine Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      scaffoldMessengerKey: _messenger,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
