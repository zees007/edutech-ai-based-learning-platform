import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/sidebar/learning_sidebar.dart';

void main() {
  testWidgets('Start New Journey button calls onClose when on mobile', (WidgetTester tester) async {
    bool closed = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LearningSidebar(
              expanded: true,
              isMobile: true,
              scrollController: ScrollController(),
              onToggle: () {},
              onClose: () {
                closed = true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    // Find the 'Start New Journey' button
    final newJourneyButton = find.text('Start New Journey');
    expect(newJourneyButton, findsOneWidget);

    // Tap the button
    await tester.tap(newJourneyButton);
    await tester.pump();

    // Verify onClose was called immediately
    expect(closed, isTrue);
  });
}
