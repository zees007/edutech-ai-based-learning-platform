import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/theme/theme_palette.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/app_theme.dart';
import 'package:devzees_edutechai_client/core/providers/theme_provider.dart';
import 'package:devzees_edutechai_client/presentation/widgets/theme_toggle_button.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('EduTech AI Palette and Theme Specifications', () {
    test('Light theme matches user specifications', () {
      final light = AppThemeColors.light;
      expect(light.scaffoldBackground, const Color(0xFFF6F8FC));
      expect(light.surface, const Color(0xFFFFFFFF));
      expect(light.surfaceSubtle, const Color(0xFFF3F3F5));
      expect(light.border, const Color(0xFFE5E7EB));
      expect(light.textPrimary, const Color(0xFF2B2D42));
      expect(light.textSecondary, const Color(0xFF8E92A4));
      expect(light.trackNeutral, const Color(0xFFD9DBE9));
    });

    test('Dark theme matches user specifications', () {
      final dark = AppThemeColors.dark;
      expect(dark.scaffoldBackground, const Color(0xFF0B0C13));
      expect(dark.surface, const Color(0xFF11121D));
      expect(dark.surfaceSubtle, const Color(0xFF11121D));
      expect(dark.border, const Color(0x0DFFFFFF));
      expect(dark.textPrimary, const Color(0xFFFFFFFF));
      expect(dark.textSecondary, const Color(0xFF94A3B8));
      expect(dark.trackNeutral, const Color(0xFF1A1B2D));
    });

    test('Shared brand accents and gradients match specification', () {
      expect(AppColors.primary, const Color(0xFF2B68F6));
      expect(AppColors.accentBlue, const Color(0xFF2B68F6));
      expect(AppColors.accentViolet, const Color(0xFF6B47EB));
      expect(AppColors.accentMagenta, const Color(0xFFB838EE));

      expect(AppColors.primaryGradient.colors[0], const Color(0xFF1F6CFA));
      expect(AppColors.primaryGradient.colors[1], const Color(0xFFC839F6));
    });

    test('Dynamic AppColors responds immediately to setBrightness', () {
      AppColors.setBrightness(Brightness.light);
      expect(AppColors.isDark, isFalse);
      expect(AppColors.background, const Color(0xFFF6F8FC));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.textPrimary, const Color(0xFF2B2D42));

      AppColors.setBrightness(Brightness.dark);
      expect(AppColors.isDark, isTrue);
      expect(AppColors.background, const Color(0xFF0B0C13));
      expect(AppColors.surface, const Color(0xFF11121D));
      expect(AppColors.textPrimary, const Color(0xFFFFFFFF));
    });

    test('AppTheme light and dark ThemeData have correct extensions and brightness', () {
      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.scaffoldBackgroundColor, const Color(0xFFF6F8FC));
      expect(lightTheme.extension<AppThemeColors>(), isNotNull);

      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF0B0C13));
      expect(darkTheme.extension<AppThemeColors>(), isNotNull);
    });
  });

  group('ThemeToggleButton Widget', () {
    testWidgets('renders and toggles theme mode on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final mode = ref.watch(themeModeProvider);
              return MaterialApp(
                themeMode: mode,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                home: const Scaffold(
                  body: Center(
                    child: ThemeToggleButton(),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // By default themeMode is dark
      expect(find.byType(ThemeToggleButton), findsOneWidget);
      expect(find.byKey(const ValueKey('dark_icon')), findsOneWidget);

      // Tap the toggle button to switch to light mode
      await tester.tap(find.byType(ThemeToggleButton));
      await tester.pumpAndSettle();

      // Now should show light mode icon and AppColors is not dark
      expect(find.byKey(const ValueKey('light_icon')), findsOneWidget);
      expect(AppColors.isDark, isFalse);

      // Tap again to switch back to dark mode
      await tester.tap(find.byType(ThemeToggleButton));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dark_icon')), findsOneWidget);
      expect(AppColors.isDark, isTrue);
    });
  });

  group('Scoped Theme & Industry-Level Architecture', () {
    testWidgets('AppColors.of(context) retrieves correct theme from InheritedTheme', (tester) async {
      late AppThemeColors resolvedColors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              resolvedColors = AppColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(resolvedColors.scaffoldBackground, AppThemeColors.light.scaffoldBackground);
    });

    testWidgets('Scoped Theme(data: AppTheme.darkTheme) isolates HomePage subtree as dark even in Light mode', (tester) async {
      late AppThemeColors globalColors;
      late AppThemeColors scopedColors;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: Column(
            children: [
              Builder(
                builder: (context) {
                  globalColors = AppColors.of(context);
                  return const Text('Global Light Page');
                },
              ),
              Theme(
                data: AppTheme.darkTheme,
                child: Builder(
                  builder: (context) {
                    scopedColors = AppColors.of(context);
                    return const Text('Scoped Dark HomePage');
                  },
                ),
              ),
            ],
          ),
        ),
      );

      // Global context remains Light
      expect(globalColors.scaffoldBackground, AppThemeColors.light.scaffoldBackground);
      // Scoped HomePage context is strictly Dark
      expect(scopedColors.scaffoldBackground, AppThemeColors.dark.scaffoldBackground);
    });
  });
}
