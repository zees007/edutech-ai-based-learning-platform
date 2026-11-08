import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/providers/admin_provider.dart';
import 'package:devzees_edutechai_client/presentation/pages/admin/widgets/analytics_tab.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final dummyMetrics = AdminMetrics(
    totalUsers: 22,
    freeCount: 19,
    proCount: 1,
    ultraCount: 2,
    totalRoles: 4,
  );

  testWidgets('AnalyticsTab renders metrics and reload icon at the LEFT side', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int fetchCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminMetricsProvider.overrideWith((ref) async {
            fetchCount++;
            return dummyMetrics;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AnalyticsTab(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Live badge
    expect(find.text('Platform Metrics & Subscription Distribution'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);

    // Verify Reload button exists
    final reloadFinder = find.byTooltip('Reload analytics');
    expect(reloadFinder, findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    // Verify Reload icon is at the LEFT side of the title (X position comparison)
    final reloadX = tester.getTopLeft(reloadFinder).dx;
    final titleX = tester.getTopLeft(find.text('Platform Metrics & Subscription Distribution')).dx;
    expect(reloadX, lessThan(titleX),
        reason: 'Reload button must be positioned to the left of the title');

    // Verify metric cards
    expect(find.text('Total Users'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('Free Tier'), findsOneWidget);
    expect(find.text('19'), findsOneWidget);
    expect(find.text('Pro Subscribers'), findsOneWidget);
    expect(find.text('Ultra Subscribers'), findsOneWidget);
    expect(find.text('System Roles'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    // Verify Subscription Tier Distribution section
    expect(find.text('Subscription Tier Distribution'), findsOneWidget);

    expect(fetchCount, equals(1));

    // Tap the Reload button
    await tester.tap(reloadFinder);
    await tester.pumpAndSettle();

    // Should have re-fetched
    expect(fetchCount, equals(2));
  });

  testWidgets('AnalyticsTab renders cleanly on mobile screen without overflow', (tester) async {
    // Standard mobile dimensions: 360 x 740
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminMetricsProvider.overrideWith((ref) async => dummyMetrics),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AnalyticsTab(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify reload button and title are visible on mobile
    expect(find.byTooltip('Reload analytics'), findsOneWidget);
    expect(find.text('Platform Metrics & Subscription Distribution'), findsOneWidget);
    expect(find.text('Total Users'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);

    // Verify no rendering overflow exceptions were thrown
    expect(tester.takeException(), isNull);
  });
}
