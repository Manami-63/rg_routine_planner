import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/da_calculator/presentation/da_calculator_screen.dart';
import '../features/db_calculator/presentation/db_calculator_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/routines/presentation/routines_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const routines = '/routines';
  static String dbCalculator(String routineId) => '/routines/$routineId/db';
  static String daCalculator(String routineId) => '/routines/$routineId/da';
}

/// Created per [ProviderScope], so each widget test gets a fresh router
/// instead of sharing navigation state through a global.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Nested routes give each screen a back button to its parent:
          // calculator (DB or DA) -> my routines -> home.
          GoRoute(
            path: 'routines',
            builder: (context, state) => const RoutinesScreen(),
            routes: [
              GoRoute(
                path: ':id/db',
                builder: (context, state) =>
                    DbCalculatorScreen(routineId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: ':id/da',
                builder: (context, state) =>
                    DaCalculatorScreen(routineId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
