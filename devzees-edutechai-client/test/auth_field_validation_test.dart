import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/presentation/pages/auth/widgets/auth_form_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/center_toast.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';

void main() {
  tearDown(() {
    CenterToast.dismiss();
  });

  testWidgets('Login form displays inline red errors for empty email and password', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AuthFormCard(
                isLogin: true,
                isMobile: false,
                onToggleMode: () {},
              ),
            ),
          ),
        ),
      ),
    );

    // 1. Submit with both fields empty -> should trigger inline red validation errors
    await tester.tap(find.byType(GradientButton));
    await tester.pump();

    // Verify inline field error messages appear beneath the inputs
    expect(find.text('Please enter your email address.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsOneWidget);

    // 2. Typing into email clears email error on user interaction
    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    await tester.pump();

    expect(find.text('Please enter your email address.'), findsNothing);
    expect(find.text('Please enter your password.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Sign up form highlights all required fields in red with inline error text', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AuthFormCard(
                isLogin: false, // Registration mode
                isMobile: false,
                onToggleMode: () {},
              ),
            ),
          ),
        ),
      ),
    );

    // Submit with all fields empty -> should show all required field errors simultaneously
    await tester.tap(find.byType(GradientButton));
    await tester.pump();

    expect(find.text('Please enter your first name.'), findsOneWidget);
    expect(find.text('Please enter your last name.'), findsOneWidget);
    expect(find.text('Please enter your email address.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
  });
}
