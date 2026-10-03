import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/core/providers/permission_provider.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/home_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/auth/auth_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/learning_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/admin/admin_page.dart';

/// Bridges Riverpod's AuthNotifier state into GoRouter's Listenable-based refresh mechanism.
class AppRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  AppRouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.status != next.status) {
          notifyListeners();
        }
      },
    );
  }

  /// Evaluates authentication state on navigation and refresh:
  /// - `initial`: preserves exact current route without premature redirect
  /// - `authenticated`: redirects away from `/auth` to `/learning`
  /// - `unauthenticated`: guards protected routes (`/learning`, `/admin`) and redirects to `/auth`
  /// - `/admin`: additionally requires admin privileges
  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final location = state.matchedLocation;
    final isAuthRoute = location == '/auth';
    final isHomeRoute = location == '/';
    final isAdminRoute = location == '/admin';

    // 1. Session verification in-flight (cold boot / F5 refresh)
    // Preserves the user's exact requested URL.
    if (authState.isInitial) {
      return null;
    }

    final isAuthenticated = authState.isAuthenticated;

    // 2. Authenticated user visiting /auth -> send to primary workspace
    if (isAuthenticated) {
      if (isAuthRoute) {
        return '/learning';
      }

      // 2b. Admin route privilege guard — redirect non-admins to /learning
      if (isAdminRoute) {
        final perms = _ref.read(permissionProvider);
        if (!perms.isAdmin) {
          return '/learning';
        }
      }

      return null;
    }

    // 3. Unauthenticated user accessing protected routes -> send to /auth
    if (!isAuthenticated) {
      if (!isAuthRoute && !isHomeRoute) {
        return '/auth';
      }
    }

    return null;
  }
}

final appRouterNotifierProvider = Provider<AppRouterNotifier>((ref) {
  return AppRouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(appRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/learning',
        name: 'learning',
        builder: (context, state) => const LearningPage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminPage(),
      ),
    ],
  );
});

class AppRouter {
  static final routerProvider = appRouterProvider;
}
