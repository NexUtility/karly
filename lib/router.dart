import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'features/calculator/presentation/calculator_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/settings/presentation/settings_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: CalculatorScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, _) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
