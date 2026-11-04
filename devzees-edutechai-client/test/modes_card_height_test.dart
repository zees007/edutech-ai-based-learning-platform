import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/widgets/modes_and_levels_section.dart';

void main() {
  for (final width in [320.0, 360.0, 375.0, 390.0, 414.0, 768.0, 1200.0]) {
    testWidgets('Mode cards have 0px height difference on width $width', (tester) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ModesAndLevelsSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final h0 = tester.getSize(find.byKey(const ValueKey<int>(0))).height;
      await tester.tap(find.text('Deep Dive Mode'));
      await tester.pumpAndSettle();
      final h1 = tester.getSize(find.byKey(const ValueKey<int>(1))).height;
      await tester.tap(find.text('Bite-Sized Mode'));
      await tester.pumpAndSettle();
      final h2 = tester.getSize(find.byKey(const ValueKey<int>(2))).height;

      expect(h0, equals(h1));
      expect(h1, equals(h2));
    });
  }

  testWidgets('Swipe gestures change mode smoothly on mobile', (tester) async {
    tester.view.physicalSize = const Size(375, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ModesAndLevelsSection(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<int>(0)), findsOneWidget);

    // Swipe left -> changes to Deep Dive Mode (index 1)
    await tester.fling(find.byKey(const ValueKey<int>(0)), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<int>(1)), findsOneWidget);

    // Swipe left again -> changes to Bite-Sized Mode (index 2)
    await tester.fling(find.byKey(const ValueKey<int>(1)), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<int>(2)), findsOneWidget);

    // Swipe right -> changes back to Deep Dive Mode (index 1)
    await tester.fling(find.byKey(const ValueKey<int>(2)), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<int>(1)), findsOneWidget);
  });
}
