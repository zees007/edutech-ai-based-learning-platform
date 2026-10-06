import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/router/app_router.dart';
import 'package:devzees_edutechai_client/core/services/api_client.dart';
import 'package:devzees_edutechai_client/core/theme/app_theme.dart';

import 'package:devzees_edutechai_client/core/providers/theme_provider.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.initCookieJar();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Sync static AppColors adapter with active theme mode
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);
    AppColors.setBrightness(isDark ? Brightness.dark : Brightness.light);

    return MaterialApp.router(
      key: ValueKey(themeMode),
      title: 'EduTech AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
