import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devzees_edutechai_client/core/providers/onboarding_provider.dart';
import 'package:devzees_edutechai_client/core/router/app_router.dart';
import 'package:devzees_edutechai_client/core/services/api_client.dart';
import 'package:devzees_edutechai_client/core/theme/app_theme.dart';

import 'package:devzees_edutechai_client/core/providers/theme_provider.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.initCookieJar();
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Read the router once and cache it. The GoRouter instance is kept alive
  // by ref.keepAlive() inside appRouterProvider, so this reference stays valid
  // for the entire app lifetime. Using ref.read (not ref.watch) prevents
  // MaterialApp.router from being rebuilt when auth state changes, which would
  // destroy the Navigator overlay and any active CenterToast entries.
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = ref.read(appRouterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // Sync static AppColors adapter with active theme mode
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);
    AppColors.setBrightness(isDark ? Brightness.dark : Brightness.light);

    return MaterialApp.router(
      title: 'EduTech AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOutCubic,
      routerConfig: _router,
    );
  }
}
