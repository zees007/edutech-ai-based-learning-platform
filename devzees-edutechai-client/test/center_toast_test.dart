import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/presentation/widgets/center_toast.dart';

void main() {
  tearDown(() {
    CenterToast.dismiss();
  });

  testWidgets('CenterToast.showError renders at center bottom with premium UI badge, title and message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    CenterToast.showError(
                      context,
                      'Invalid email address or password.',
                      title: 'Authentication Failed',
                    );
                  },
                  child: const Text('Show Error'),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Tap button to show error toast
    await tester.tap(find.text('Show Error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320)); // Advance entrance animation

    // Verify premium badge tag, title and error message appear
    expect(find.text('ERROR'), findsOneWidget);
    expect(find.text('Authentication Failed'), findsOneWidget);
    expect(find.text('Invalid email address or password.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

    // Verify center-bottom positioning
    final toastFinder = find.byType(Dismissible);
    expect(toastFinder, findsOneWidget);
    final toastCenter = tester.getCenter(toastFinder);
    final screenCenter = tester.getCenter(find.byType(Scaffold));

    // Horizontal center should match screen center (within 1.0px)
    expect((toastCenter.dx - screenCenter.dx).abs(), lessThan(1.0));
    // Vertical center should be at bottom (significantly lower than screen center)
    expect(toastCenter.dy, greaterThan(screenCenter.dy));

    // Tap close button to dismiss
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320)); // Exit animation

    // Toast should be removed
    expect(find.text('Authentication Failed'), findsNothing);
  });

  testWidgets('CenterToast stays visible for 6 seconds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CenterToast.showError(
                    context,
                    'Invalid email address or password.',
                    title: 'Authentication Failed',
                  );
                },
                child: const Text('Show Error'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('Authentication Failed'), findsOneWidget);

    // At 4 seconds (4000ms), it should STILL be visible!
    await tester.pump(const Duration(milliseconds: 4000));
    expect(find.text('Authentication Failed'), findsOneWidget);

    // At > 6 seconds total, it animates out and disappears
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Authentication Failed'), findsNothing);
  });

  testWidgets('CenterToast.showSuccess stays visible for 4.5 seconds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CenterToast.showSuccess(
                    context,
                    'Action completed successfully.',
                    title: 'Success',
                  );
                },
                child: const Text('Show Success'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Success'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Action completed successfully.'), findsOneWidget);

    // At 3 seconds (3000ms), it should STILL be visible!
    await tester.pump(const Duration(milliseconds: 3000));
    expect(find.text('Action completed successfully.'), findsOneWidget);

    // At > 4.5 seconds total, it animates out and disappears
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Action completed successfully.'), findsNothing);
  });

  testWidgets('CenterToast is responsive on mobile viewport', (tester) async {
    // Set small mobile size: 360 x 640
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    CenterToast.showError(
                      context,
                      'Invalid credentials provided.',
                    );
                  },
                  child: const Text('Trigger Mobile Toast'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger Mobile Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('Invalid credentials provided.'), findsOneWidget);

    final toastSize = tester.getSize(find.byType(Dismissible));
    // Toast should be mobile friendly (less than screen width 360, leaving margins)
    expect(toastSize.width, lessThan(360));
    expect(toastSize.width, greaterThan(260));
  });

  testWidgets('CenterToast elevates above virtual keyboard in center bottom', (tester) async {
    // Set mobile viewport with keyboard inset (e.g. viewInsets.bottom = 250)
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    CenterToast.showError(
                      context,
                      'Authentication Failed',
                    );
                  },
                  child: const Text('Trigger Keyboard Toast'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger Keyboard Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('Authentication Failed'), findsOneWidget);
    final toastCenter = tester.getCenter(find.byType(Dismissible));

    // Toast center must be positioned above the 250px keyboard (i.e. Y < 812 - 250)
    expect(toastCenter.dy, lessThan(812 - 250));
    // And still horizontally centered
    expect((toastCenter.dx - (375 / 2)).abs(), lessThan(1.0));
  });
}
