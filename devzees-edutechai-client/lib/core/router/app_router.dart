import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/core/providers/permission_provider.dart';
import 'package:devzees_edutechai_client/core/providers/onboarding_provider.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/home_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/auth/auth_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/learning_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/admin/admin_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/onboarding/onboarding_page.dart';

/// Bridges Riverpod's AuthNotifier state into GoRouter's Listenable-based refresh mechanism.
class AppRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  AppRouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.status != next.status || previous?.user != next.user) {
          notifyListeners();
        }
      },
    );

    // Also listen to onboarding state changes to trigger router refresh
    _ref.listen<bool>(
      onboardingProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }

  /// Evaluates authentication state on navigation and refresh:
  /// - `initial`: preserves exact current route without premature redirect
  /// - `authenticated`: redirects away from `/auth` to `/learning`
  /// - `unauthenticated`: guards protected routes (`/learning`, `/admin`) and redirects to `/auth`
  /// - `/admin`: additionally requires admin privileges
  /// - `/onboarding`: mobile-only first-launch flow
  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final location = state.matchedLocation;
    final isAuthRoute = location == '/auth';
    final isHomeRoute = location == '/';
    final isAdminRoute = location == '/admin';
    final isOnboardingRoute = location == '/onboarding';

    // ── Onboarding logic (mobile only) ──
    if (!kIsWeb) {
      final hasSeenOnboarding = _ref.read(onboardingProvider);

      // First launch: redirect to onboarding if not yet seen (and unauthenticated)
      if (!hasSeenOnboarding && !isOnboardingRoute) {
        // Only redirect if auth is not in initial state and user is not authenticated
        if (!authState.isInitial && !authState.isAuthenticated) {
          return '/onboarding';
        }
      }

      // Already seen onboarding (or already authenticated): redirect away from /onboarding
      if ((hasSeenOnboarding || authState.isAuthenticated) && isOnboardingRoute) {
        return authState.isAuthenticated ? '/learning' : '/auth';
      }

      // Allow /onboarding when not yet seen
      if (!hasSeenOnboarding && isOnboardingRoute) {
        return null;
      }
    } else {
      // Web: never allow /onboarding
      if (isOnboardingRoute) {
        return '/';
      }
    }

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

      // On mobile (!kIsWeb), web marketing home page is bypassed
      if (!kIsWeb && isHomeRoute) {
        return '/learning';
      }

      // 2b. Admin route privilege guard — redirect non-admins to /learning
      if (isAdminRoute) {
        // If user profile is not yet available, keep route pending rehydration
        if (authState.user == null) {
          return null;
        }
        final perms = _ref.read(permissionProvider);
        if (!perms.isAdmin) {
          return '/learning';
        }
      }

      return null;
    }

    // 3. Unauthenticated user accessing protected routes -> send to /auth
    if (!isAuthenticated) {
      // On mobile (!kIsWeb), HomePage ('/') is not accessible; redirect directly to /auth
      if (!kIsWeb && isHomeRoute) {
        return '/auth';
      }

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
  final hasSeenOnboarding = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: kIsWeb
        ? '/'
        : (hasSeenOnboarding ? '/auth' : '/onboarding'),
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
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
