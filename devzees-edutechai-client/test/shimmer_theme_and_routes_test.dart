import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/core/theme/app_theme.dart';
import 'package:devzees_edutechai_client/presentation/pages/admin/widgets/admin_loading_skeleton.dart';
import 'package:devzees_edutechai_client/presentation/pages/auth/auth_page.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/video_curator_shimmer.dart';
import 'package:devzees_edutechai_client/presentation/pages/subscription/subscription_page.dart';
import 'package:devzees_edutechai_client/presentation/widgets/shimmer_app_shell.dart';
import 'package:devzees_edutechai_client/presentation/widgets/shimmer_loading.dart';

class _MockAuthNotifier extends AuthNotifier {
  final AuthState initialState;
  _MockAuthNotifier(this.initialState);

  @override
  AuthState build() => initialState;

  void setStatus(AuthStatus status) {
    state = state.copyWith(status: status);
  }
}

Widget _themedApp({
  required ThemeMode themeMode,
  required Widget home,
  List<dynamic> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: home,
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ShimmerAppShell variants & theme support', () {
    for (final variant in ShimmerShellVariant.values) {
      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        testWidgets(
          'renders $variant on desktop (${themeMode.name}) without overflow or outer Scaffold ShaderMask',
          (tester) async {
            tester.view.physicalSize = const Size(1280, 800);
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(
              _themedApp(
                themeMode: themeMode,
                home: ShimmerAppShell(variant: variant),
              ),
            );
            await tester.pump(const Duration(milliseconds: 250));

            expect(tester.takeException(), isNull);
            expect(find.byType(ShimmerLoading), findsWidgets);
            // Verify ShimmerLoading is inside Scaffold (never wrapping SafeArea/Scaffold)
            final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
            expect(scaffold.body, isA<SafeArea>());
            expect((scaffold.body as SafeArea).child, isNot(isA<ShimmerLoading>()));
          },
        );

        testWidgets(
          'renders $variant on mobile (${themeMode.name}) without overflow',
          (tester) async {
            tester.view.physicalSize = const Size(375, 812);
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(
              _themedApp(
                themeMode: themeMode,
                home: ShimmerAppShell(variant: variant),
              ),
            );
            await tester.pump(const Duration(milliseconds: 250));

            expect(tester.takeException(), isNull);
            expect(find.byType(ShimmerLoading), findsWidgets);
          },
        );
      }
    }
  });

  group('AuthPage and SubscriptionPage refresh skeletons', () {
    testWidgets(
      'AuthPage renders refresh skeleton while authState.isInitial and swaps to form when unauthenticated',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _themedApp(
            themeMode: ThemeMode.light,
            overrides: [
              authProvider.overrideWith(
                () => _MockAuthNotifier(AuthState(status: AuthStatus.initial)),
              ),
            ],
            home: const AuthPage(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byKey(const ValueKey('auth_refresh_skeleton_desktop')), findsOneWidget);
        expect(find.byKey(const ValueKey('auth_form_body')), findsNothing);
        expect(tester.takeException(), isNull);

        final container = ProviderScope.containerOf(
          tester.element(find.byType(AuthPage)),
        );
        (container.read(authProvider.notifier) as _MockAuthNotifier)
            .setStatus(AuthStatus.unauthenticated);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byKey(const ValueKey('auth_form_body')), findsOneWidget);
        expect(find.byKey(const ValueKey('auth_refresh_skeleton_desktop')), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'SubscriptionPage renders ShimmerAppShell(subscription) while authState.isInitial',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _themedApp(
            themeMode: ThemeMode.light,
            overrides: [
              authProvider.overrideWith(
                () => _MockAuthNotifier(AuthState(status: AuthStatus.initial)),
              ),
            ],
            home: const SubscriptionPage(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byKey(const ValueKey('subscription_shimmer_skeleton')), findsOneWidget);
        final shell = tester.widget<ShimmerAppShell>(find.byType(ShimmerAppShell));
        expect(shell.variant, ShimmerShellVariant.subscription);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Theme-adapted component shimmers', () {
    for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
        'VideoCuratorShimmer and AdminTableSkeleton render cleanly in ${themeMode.name} mode',
        (tester) async {
          tester.view.physicalSize = const Size(1000, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _themedApp(
              themeMode: themeMode,
              home: const Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      VideoCuratorShimmer(),
                      SizedBox(height: 16),
                      AdminTableSkeleton(showMetricsRow: true, showSearchBar: true),
                      SizedBox(height: 16),
                      AdminCompactSectionSkeleton(),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 250));
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
