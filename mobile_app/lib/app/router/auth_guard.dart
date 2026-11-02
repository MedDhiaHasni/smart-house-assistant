import 'package:go_router/go_router.dart';

abstract final class AuthGuard {
  static String? redirect({
    required bool isAuthenticated,
    required GoRouterState state,
  }) {
    final isLoginRoute =
        state.matchedLocation == '/login' || state.matchedLocation == '/splash';
    if (!isAuthenticated && !isLoginRoute) return '/login';
    if (isAuthenticated && isLoginRoute) return '/';
    return null;
  }
}
