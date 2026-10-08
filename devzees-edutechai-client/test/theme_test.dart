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
      expect(light.scaffoldBackground, const Color(0xFFECE8E8));
      expect(light.surface, const Color(0xFFFFFFFF));
      expect(light.surfaceSubtle, const Color(0xFFF3F3F5));
      expect(light.border, const Color(0xFFE5E7EB));
      expect(light.textPrimary, const Color(0xFF2B2D42));
      expect(light.textSecondary, const Color(0xFF8E92A4));
      expect(light.trackNeutral, const Color(0xFFD9DBE9));
    });

    test('Dark theme matches user specifications', () {
      final dark = AppThemeColors.dark;
      expect(dark.scaffoldBackground, const Color(0xFF121316));
      expect(dark.surface, const Color(0xFF1C1E24));
      expect(dark.surfaceSubtle, const Color(0xFF272A33));
      expect(dark.border, const Color(0xFF333742));
      expect(dark.textPrimary, const Color(0xFFFFFFFF));
      expect(dark.textSecondary, const Color(0xFF8F94A6));
      expect(dark.trackNeutral, const Color(0xFF2C2F3A));
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
      expect(AppColors.background, const Color(0xFFECE8E8));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.textPrimary, const Color(0xFF2B2D42));

      AppColors.setBrightness(Brightness.dark);
      expect(AppColors.isDark, isTrue);
      expect(AppColors.background, const Color(0xFF121316));
      expect(AppColors.surface, const Color(0xFF1C1E24));
      expect(AppColors.textPrimary, const Color(0xFFFFFFFF));
    });

    test('AppTheme light and dark ThemeData have correct extensions and brightness', () {
      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.scaffoldBackgroundColor, const Color(0xFFECE8E8));
      expect(lightTheme.extension<AppThemeColors>(), isNotNull);

      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF121316));
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
}
