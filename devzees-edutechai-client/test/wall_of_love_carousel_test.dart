import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/wall_of_love_section.dart';
import 'package:devzees_edutechai_client/core/providers/feedback_provider.dart';
import 'package:devzees_edutechai_client/data/models/feedback/feedback_model.dart';

void main() {
  final mockTestimonials = [
    const PublicFeedbackModel(
      feedbackId: 'fb_1',
      name: 'Dr. John Doe',
      educationLevel: 'PhD',
      country: 'United Kingdom',
      avatarColor: Color(0xFF2B68F6),
      quote: 'This platform transformed how I conduct complex research synthesis.',
      topicTag: 'I want to learn spring boot from begining to advanace level step by step. How create a microservice in spring boot?',
      avatarInitial: 'JD',
      rating: 5,
    ),
    const PublicFeedbackModel(
      feedbackId: 'fb_2',
      name: 'Alice Smith',
      educationLevel: 'Undergraduate',
      country: 'Canada',
      avatarColor: Color(0xFF10B981),
      quote: 'The Socratic dialogue pushes me to understand first principles rather than memorizing formulas.',
      topicTag: 'Quantum Computing & Algorithms',
      avatarInitial: 'AS',
      rating: 5,
    ),
    const PublicFeedbackModel(
      feedbackId: 'fb_3',
      name: 'Bob Lee',
      educationLevel: 'Graduate',
      country: 'Japan',
      avatarColor: Color(0xFFF59E0B),
      quote: 'Interactive graph visualization makes structural biology concepts effortless to digest.',
      topicTag: 'Biomolecular Structures',
      avatarInitial: 'BL',
      rating: 4,
    ),
  ];

  group('WallOfLoveSection 3D Cylindrical Carousel Tests', () {
    testWidgets('renders testimonials from publicTestimonialsProvider and verifies solidified dimensions', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            publicTestimonialsProvider.overrideWith((ref) => Future.value(mockTestimonials)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: WallOfLoveSection(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Check header and headlines
      expect(find.text('STUDENT & RESEARCHER REPUTATION'), findsOneWidget);
      expect(find.text('Loved by Ambitious Learners Worldwide'), findsOneWidget);

      // Check rendered names
      expect(find.text('Dr. John Doe'), findsOneWidget);

      // Check verbatim long topic tag is present in the tree
      expect(
        find.textContaining('I want to learn spring boot from begining to advanace level'),
        findsOneWidget,
      );

      // Verify card solidified sizing: cards in the viewport have width 370 and height 290
      final cardFinder = find.byWidgetPredicate(
        (widget) => widget is AnimatedContainer && widget.constraints?.minWidth == 370 && widget.constraints?.minHeight == 290,
      );
      expect(cardFinder, findsWidgets);
    });

    testWidgets('chevron controls navigate to next and previous testimonials', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            publicTestimonialsProvider.overrideWith((ref) => Future.value(mockTestimonials)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: WallOfLoveSection(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Find chevron right icon and tap
      final chevronRight = find.byIcon(Icons.chevron_right_rounded);
      expect(chevronRight, findsOneWidget);

      await tester.tap(chevronRight);
      await tester.pumpAndSettle();

      // Second testimonial card should now be spotlighted
      expect(find.text('Alice Smith'), findsOneWidget);

      // Find chevron left icon and tap to return to first
      final chevronLeft = find.byIcon(Icons.chevron_left_rounded);
      expect(chevronLeft, findsOneWidget);

      await tester.tap(chevronLeft);
      await tester.pumpAndSettle();

      expect(find.text('Dr. John Doe'), findsOneWidget);
    });
  });
}

