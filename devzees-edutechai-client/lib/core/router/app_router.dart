import 'package:go_router/go_router.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/home_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/auth/auth_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/learning_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
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
    ],
  );
}
