import 'package:go_router/go_router.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/home_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      // Future routes (auth, learning, etc.) will go here
    ],
  );
}
