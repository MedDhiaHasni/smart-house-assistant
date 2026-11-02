import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/climate/presentation/screens/climate_screen.dart';
import '../../features/conflicts/presentation/screens/conflicts_screen.dart';
import '../../features/context/presentation/screens/context_viewer_screen.dart';
import '../../features/dashboard/presentation/screens/main_navigation_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/energy/presentation/screens/energy_screen.dart';
import '../../features/explain/presentation/screens/explain_screen.dart';
import '../../features/modes/presentation/screens/modes_screen.dart';
import '../../features/rooms/presentation/screens/rooms_screen.dart';
import '../../features/rooms/presentation/screens/room_detail_screen.dart';
import '../../features/rules/presentation/screens/rule_editor_screen.dart';
import '../../features/routines/presentation/screens/routines_screen.dart';
import '../../features/routines/presentation/screens/routine_detail_screen.dart';
import '../../features/security/presentation/screens/security_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/timeline/presentation/screens/timeline_screen.dart';
import '../di/providers.dart';
import 'auth_guard.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) =>
        AuthGuard.redirect(isAuthenticated: isAuthenticated, state: state),
    routes: [
      GoRoute(
        name: RouteNames.splash,
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: RouteNames.login,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigationScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.dashboard,
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.rooms,
                path: '/rooms',
                builder: (context, state) => const RoomsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.routines,
                path: '/routines',
                builder: (context, state) => const RoutinesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.timeline,
                path: '/timeline',
                builder: (context, state) => const TimelineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: RouteNames.settings,
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: RouteNames.security,
        path: '/security',
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        name: RouteNames.climate,
        path: '/climate',
        builder: (context, state) => const ClimateScreen(),
      ),
      GoRoute(
        name: RouteNames.energy,
        path: '/energy',
        builder: (context, state) => const EnergyScreen(),
      ),
      GoRoute(
        name: RouteNames.routineDetail,
        path: '/routine/:id',
        builder: (context, state) => RoutineDetailScreen(
          routineId: state.pathParameters['id'] ?? 'good_morning',
        ),
      ),
      GoRoute(
        name: RouteNames.explain,
        path: '/explain',
        builder: (context, state) => const ExplainScreen(),
      ),
      GoRoute(
        name: RouteNames.roomDetail,
        path: '/room/:id',
        builder: (context, state) => RoomDetailScreen(
          roomId: state.pathParameters['id'] ?? 'living_room',
        ),
      ),
      GoRoute(
        name: RouteNames.ruleEditor,
        path: '/rules',
        builder: (context, state) => const RuleEditorScreen(),
      ),
      GoRoute(
        name: RouteNames.modes,
        path: '/modes',
        builder: (context, state) => const ModesScreen(),
      ),
      GoRoute(
        name: RouteNames.context,
        path: '/context',
        builder: (context, state) => const ContextViewerScreen(),
      ),
      GoRoute(
        name: RouteNames.conflicts,
        path: '/conflicts',
        builder: (context, state) => const ConflictsScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
