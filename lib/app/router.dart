import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/db_calculator/presentation/db_calculator_screen.dart';
import '../features/home/presentation/home_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const dbCalculator = '/db-calculator';
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
          // Nested under home, so the calculator gets a back button.
          GoRoute(
            path: 'db-calculator',
            builder: (context, state) => const DbCalculatorScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
