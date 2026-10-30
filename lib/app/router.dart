import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/routine_editor/presentation/routine_screen.dart';
import '../features/routines/presentation/routines_screen.dart';
import '../features/welcome/presentation/welcome_providers.dart';
import '../features/welcome/presentation/welcome_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const routines = '/routines';
  static const welcome = '/welcome';

  /// The routine page, opened on [tab].
  static String routine(String routineId, [RoutineTab tab = RoutineTab.db]) =>
      tab == RoutineTab.db
      ? '/routines/$routineId'
      : '/routines/$routineId?tab=${tab.name}';
}

/// Created per [ProviderScope], so each widget test gets a fresh router
/// instead of sharing navigation state through a global.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: ref.read(startWithWelcomeProvider)
        ? AppRoutes.welcome
        : AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Nested routes give each screen a back button to its parent:
          // routine -> my routines -> home.
          GoRoute(
            path: 'routines',
            builder: (context, state) => const RoutinesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => RoutineScreen(
                  routineId: state.pathParameters['id']!,
                  initialTab: RoutineTab.fromName(
                    state.uri.queryParameters['tab'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      // Top level: no back button on the first launch; "Get started" goes
      // home, or back when opened from Home.
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
