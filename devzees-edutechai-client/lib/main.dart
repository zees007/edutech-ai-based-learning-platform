import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/core/router/app_router.dart';
import 'package:devzees_edutechai_client/core/services/api_client.dart';
import 'package:devzees_edutechai_client/core/theme/app_theme.dart';
import 'package:devzees_edutechai_client/presentation/widgets/shimmer_app_shell.dart';

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
    final isInitial = ref.watch(authProvider.select((s) => s.isInitial));

    return MaterialApp.router(
      title: 'EduTech AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        // High-fidelity shimmer skeleton screen during cold boot or F5 refresh
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: isInitial
              ? const ShimmerAppShell(key: ValueKey('shimmer_skeleton'))
              : KeyedSubtree(
                  key: const ValueKey('app_content'),
                  child: child ?? const SizedBox.shrink(),
                ),
        );
      },
    );
  }
}
