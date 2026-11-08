import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/pages/admin/widgets/feedback_management_tab.dart';
import 'package:devzees_edutechai_client/presentation/pages/admin/widgets/admin_data_table.dart';
import 'package:devzees_edutechai_client/core/providers/feedback_provider.dart';
import 'package:devzees_edutechai_client/data/models/feedback/feedback_model.dart';

class MockAdminFeedbackNotifier extends AdminFeedbackNotifier {
  final AdminFeedbackState _initialState;
  MockAdminFeedbackNotifier(this._initialState);

  @override
  AdminFeedbackState build() => _initialState;

  @override
  Future<void> loadFeedbacks({String? status, String? query, int? page}) async {}

  @override
  Future<bool> updateStatus({
    required String feedbackId,
    required String newStatus,
    String? adminNotes,
  }) async {
    return true;
  }
}

void main() {
  final mockItems = [
    const AdminFeedbackModel(
      id: 1,
      feedbackId: 'fb_uuid_123456789',
      sessionId: 'sess_987654321',
      userId: 'usr_1',
      userName: 'Alexander Hamilton',
      userEmail: 'alexander.hamilton@example.com',
      educationLevel: 'Undergraduate',
      country: 'United States',
      rating: 5,
      quote: 'The Socratic dialogue method with autonomous hints completely reshaped how I master quantum mechanics concepts.',
      topicTag: 'Quantum Mechanics & Hilbert Spaces',
      isPublicConsent: true,
      status: 'pending',
      adminNotes: 'Excellent testimonial candidate for quantum cohort.',
    ),
    const AdminFeedbackModel(
      id: 2,
      feedbackId: 'fb_uuid_223456789',
      sessionId: 'sess_887654321',
      userId: 'usr_2',
      userName: 'Marie Curie',
      userEmail: 'marie.curie@example.com',
      educationLevel: 'Postgraduate / PhD',
      country: 'France',
      rating: 5,
      quote: 'Outstanding step-by-step guidance on radiochemistry experiments.',
      topicTag: 'Radiochemistry',
      isPublicConsent: true,
      status: 'featured',
      adminNotes: 'Featured on homepage hero.',
    ),
  ];

  final mockMetrics = const AdminFeedbackSummaryMetrics(
    totalCount: 42,
    pendingCount: 15,
    featuredCount: 8,
    archivedCount: 19,
    averageRating: 4.8,
  );

  final mockState = AdminFeedbackState(
    isLoading: false,
    items: mockItems,
    total: 42,
    metrics: mockMetrics,
    selectedStatus: 'pending',
  );

  group('FeedbackManagementTab Mobile Responsiveness Tests', () {
    testWidgets('renders cleanly on mobile (375x812) without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminFeedbackProvider.overrideWith(() => MockAdminFeedbackNotifier(mockState)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FeedbackManagementTab(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no overflow exception occurred
      expect(tester.takeException(), isNull);

      // Verify section header is rendered
      expect(find.text('Feedback & Testimonials Moderation'), findsOneWidget);

      // Verify KPI metrics cards render
      expect(find.text('Total Reviews'), findsOneWidget);
      expect(find.text('Pending Review'), findsOneWidget);
      expect(find.text('Featured on Homepage'), findsOneWidget);
      expect(find.text('42'), findsNWidgets(2)); // in KPI card and "All" chip badge
      expect(find.text('15'), findsNWidgets(2)); // in KPI card and "Pending" chip badge

      // Verify status filter chips are rendered
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('🌟 Featured'), findsOneWidget);
      expect(find.text('Archived'), findsNWidgets(2)); // in KPI card and filter chip
      expect(find.text('All'), findsOneWidget);

      // Verify search input is present
      expect(find.byType(TextField), findsOneWidget);

      // Verify AdminDataTable is rendered with horizontal swipe hint
      expect(find.byType(AdminDataTable), findsOneWidget);
      expect(find.text('Swipe horizontally for all columns'), findsOneWidget);

      // Verify table headers exist in the scrollable view
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Topic'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);

      // Verify student details
      expect(find.text('Alexander Hamilton'), findsOneWidget);
      expect(find.text('Marie Curie'), findsOneWidget);
    });

    testWidgets('renders cleanly on narrow mobile (360x640) without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminFeedbackProvider.overrideWith(() => MockAdminFeedbackNotifier(mockState)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FeedbackManagementTab(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('horizontal scroll works on AdminDataTable on mobile', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminFeedbackProvider.overrideWith(() => MockAdminFeedbackNotifier(mockState)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FeedbackManagementTab(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll vertical page down slightly so table is visible in viewport
      final verticalScrollables = find.byWidgetPredicate(
        (w) => w is Scrollable && (w.axisDirection == AxisDirection.down || w.axisDirection == AxisDirection.up),
      );
      await tester.drag(verticalScrollables.first, const Offset(0, -350));
      await tester.pumpAndSettle();

      // Find horizontal scrollable inside AdminDataTable
      final horizontalScrollables = find.byWidgetPredicate(
        (w) => w is Scrollable && (w.axisDirection == AxisDirection.right || w.axisDirection == AxisDirection.left),
      );
      expect(horizontalScrollables, findsWidgets);

      // Drag horizontally to reveal rightmost columns
      await tester.drag(horizontalScrollables.last, const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('opens moderation dialog on mobile without overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminFeedbackProvider.overrideWith(() => MockAdminFeedbackNotifier(mockState)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FeedbackManagementTab(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll vertically so table is in viewport
      final verticalScrollables = find.byWidgetPredicate(
        (w) => w is Scrollable && (w.axisDirection == AxisDirection.down || w.axisDirection == AxisDirection.up),
      );
      await tester.drag(verticalScrollables.first, const Offset(0, -400));
      await tester.pumpAndSettle();

      // Scroll horizontally to reach actions column
      final horizontalScrollables = find.byWidgetPredicate(
        (w) => w is Scrollable && (w.axisDirection == AxisDirection.right || w.axisDirection == AxisDirection.left),
      );
      await tester.drag(horizontalScrollables.last, const Offset(-700, 0));
      await tester.pumpAndSettle();

      // Tap the View Details icon button on the first row
      final viewDetailsButton = find.byTooltip('Review Details & Moderation').first;
      await tester.tap(viewDetailsButton);
      await tester.pumpAndSettle();

      // Verify dialog is opened
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Moderation & Admin Notes'), findsOneWidget);
      expect(find.text('Internal Administrative Notes'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Verify no overflow in dialog
      expect(tester.takeException(), isNull);
    });
  });
}
