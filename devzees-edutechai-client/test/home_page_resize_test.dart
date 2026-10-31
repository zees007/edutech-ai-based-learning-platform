import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/home_page.dart';

void main() {
  testWidgets('reproduce resize error on HomePage', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Now simulate resizing the screen to mobile size (e.g. 500x800)
    tester.view.physicalSize = const Size(500, 800);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Now resize back to desktop
    tester.view.physicalSize = const Size(1400, 900);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  });
}

