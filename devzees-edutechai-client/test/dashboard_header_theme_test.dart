import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/pages/dashboard/widgets/dashboard_header.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'DashboardHeader: Light theme uses vibrant purple for Growth Analytics icon and Sync All refreshing icon',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. LIGHT THEME TEST
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: DashboardHeader(
              isRefreshing: true,
              onRefresh: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Growth & Mastery Analytics icon is present with consistent brand primary color
    final autoGraphIconFinder = find.byIcon(Icons.auto_graph_rounded);
    expect(autoGraphIconFinder, findsOneWidget);
    final autoGraphIcon = tester.widget<Icon>(autoGraphIconFinder);
    expect(autoGraphIcon.color, AppColors.primary);

    // Verify Sync All refresh icon is purple in light theme when refreshing
    final syncIconFinder = find.byIcon(Icons.sync_rounded);
    expect(syncIconFinder, findsOneWidget);
    final syncIcon = tester.widget<Icon>(syncIconFinder);
    expect(syncIcon.color, AppColors.purple);
  });

  testWidgets(
      'DashboardHeader: Dark theme preserves cyan/blue accent for Growth Analytics icon and Sync All refreshing icon',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 2. DARK THEME TEST
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: DashboardHeader(
              isRefreshing: true,
              onRefresh: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Growth & Mastery Analytics icon in dark theme is also brand primary color
    final autoGraphIconFinder = find.byIcon(Icons.auto_graph_rounded);
    expect(autoGraphIconFinder, findsOneWidget);
    final autoGraphIcon = tester.widget<Icon>(autoGraphIconFinder);
    expect(autoGraphIcon.color, AppColors.primary);

    // Verify Sync All refresh icon in dark theme is cyan
    final syncIconFinder = find.byIcon(Icons.sync_rounded);
    expect(syncIconFinder, findsOneWidget);
    final syncIcon = tester.widget<Icon>(syncIconFinder);
    expect(syncIcon.color, const Color(0xFF22D3EE));
  });
}
