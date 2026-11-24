import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/data/models/dashboard/dashboard_response.dart';
import 'package:devzees_edutechai_client/presentation/pages/dashboard/widgets/dashboard_kpi_cards.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const testSummary = DashboardSummary(
    totalSessions: 10,
    completedSessions: 8,
    completionRate: 80.0,
    totalStepsMastered: 16,
    totalStudyMinutes: 150,
    averageQuizScoreOverall: 88.5,
  );

  Widget createWidget({
    required double width,
    required double height,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: const DashboardKpiCards(summary: testSummary),
          ),
        ),
      ),
    );
  }

  group('DashboardKpiCards Concentric Rings & KPI Tests', () {
    testWidgets('renders side-by-side desktop view with 4 KPI cards and center mastery score', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget(width: 1000, height: 400));
      await tester.pumpAndSettle();

      // Check all 4 KPI titles exist
      expect(find.text('Active Study Time'), findsOneWidget);
      expect(find.text('Journeys Completed'), findsOneWidget);
      expect(find.text('Milestones Mastered'), findsOneWidget);
      expect(find.text('Period Quiz Accuracy'), findsOneWidget);

      // Check values
      expect(find.text('2h 30m'), findsOneWidget);
      expect(find.text('8 / 10'), findsOneWidget);
      expect(find.text('16 Steps'), findsOneWidget);
      expect(find.text('88.5%'), findsOneWidget);

      // Check center composite score label
      expect(find.text('OVERALL PROGRESS'), findsOneWidget);
      expect(find.text('Active Rings'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders tablet view showing all 4 KPI cards without overflow', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget(width: 720, height: 600));
      await tester.pumpAndSettle();

      expect(find.text('Active Study Time'), findsOneWidget);
      expect(find.text('Journeys Completed'), findsOneWidget);
      expect(find.text('Milestones Mastered'), findsOneWidget);
      expect(find.text('Period Quiz Accuracy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders mobile view in 2x2 compact grid cleanly', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget(width: 375, height: 600));
      await tester.pumpAndSettle();

      expect(find.text('Active Study Time'), findsOneWidget);
      expect(find.text('Journeys Completed'), findsOneWidget);
      expect(find.text('Milestones Mastered'), findsOneWidget);
      expect(find.text('Period Quiz Accuracy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap interaction focuses metric in center and tap again resets', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget(width: 1000, height: 400));
      await tester.pumpAndSettle();

      expect(find.text('OVERALL PROGRESS'), findsOneWidget);
      expect(find.text('Active Rings'), findsOneWidget);

      // Tap on 'Active Study Time' card
      await tester.tap(find.text('Active Study Time'));
      await tester.pumpAndSettle();

      expect(find.text('STUDY TIME'), findsOneWidget);
      expect(find.text('Metric Focused'), findsOneWidget);

      // Tap again to toggle back to default composite
      await tester.tap(find.text('Active Study Time'));
      await tester.pumpAndSettle();

      expect(find.text('OVERALL PROGRESS'), findsOneWidget);
      expect(find.text('Active Rings'), findsOneWidget);
    });

    testWidgets('renders cleanly in light mode', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget(width: 1000, height: 400, themeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      expect(find.text('Active Study Time'), findsOneWidget);
      expect(find.text('OVERALL PROGRESS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
