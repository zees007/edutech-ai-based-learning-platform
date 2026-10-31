import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/pages/home/home_page.dart';

void main() {
  testWidgets('reproduce resize error on HomePage with scrolling and multiple breakpoints', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
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

    // Scroll through the page to mount all sections
    for (double offset = 0; offset <= 5000; offset += 600) {
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 100));

      // Resize at various scroll positions
      final widths = [1200.0, 1000.0, 800.0, 750.0, 500.0, 380.0, 1200.0];
      for (final w in widths) {
        tester.view.physicalSize = Size(w, 850);
        await tester.pump(const Duration(milliseconds: 50));
      }
    }
  });
}
