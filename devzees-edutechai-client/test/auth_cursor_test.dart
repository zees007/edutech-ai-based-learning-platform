import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/presentation/pages/auth/widgets/auth_form_card.dart';
import 'package:devzees_edutechai_client/presentation/pages/auth/widgets/auth_canvas.dart';
import 'package:devzees_edutechai_client/presentation/widgets/center_toast.dart';

void main() {
  tearDown(() {
    CenterToast.dismiss();
  });

  group('Auth Pages Full Hand Cursor Tests', () {
    testWidgets('1. Sign In / Create Account Toggle items have click cursor and disabled selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SelectionArea(
                  child: AuthFormCard(
                    isLogin: true,
                    isMobile: false,
                    onToggleMode: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final signInTabFinder = find.ancestor(
        of: find.text('Sign In').first,
        matching: find.byType(MouseRegion),
      );
      expect(signInTabFinder, findsWidgets);
      final signInRegion = tester.widget<MouseRegion>(signInTabFinder.first);
      expect(signInRegion.cursor, SystemMouseCursors.click);
      expect(signInRegion.opaque, isTrue);

      final createAccountTabFinder = find.ancestor(
        of: find.text('Create Account').first,
        matching: find.byType(MouseRegion),
      );
      expect(createAccountTabFinder, findsWidgets);
      final createAccountRegion = tester.widget<MouseRegion>(createAccountTabFinder.first);
      expect(createAccountRegion.cursor, SystemMouseCursors.click);
      expect(createAccountRegion.opaque, isTrue);

      final disabledContainers = find.descendant(
        of: find.byType(AuthFormCard),
        matching: find.byType(SelectionContainer),
      );
      expect(disabledContainers, findsWidgets);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('2. Forgot Password? has click cursor, opaque behavior, and disabled selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SelectionArea(
                  child: AuthFormCard(
                    isLogin: true,
                    isMobile: false,
                    onToggleMode: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final forgotPasswordText = find.text('Forgot Password?');
      expect(forgotPasswordText, findsOneWidget);

      final mouseRegionFinder = find.ancestor(
        of: forgotPasswordText,
        matching: find.byType(MouseRegion),
      );
      expect(mouseRegionFinder, findsOneWidget);
      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
      expect(mouseRegion.cursor, SystemMouseCursors.click);
      expect(mouseRegion.opaque, isTrue);

      final gestureFinder = find.ancestor(
        of: forgotPasswordText,
        matching: find.byType(GestureDetector),
      );
      expect(gestureFinder, findsWidgets);
      final gestureDetector = tester.widget<GestureDetector>(gestureFinder.first);
      expect(gestureDetector.behavior, HitTestBehavior.opaque);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('3. Text "Sign Up for Free" under sign in form has click cursor and disabled selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SelectionArea(
                  child: AuthFormCard(
                    isLogin: true,
                    isMobile: false,
                    onToggleMode: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final signUpText = find.text('Sign Up for Free');
      expect(signUpText, findsOneWidget);

      final mouseRegionFinder = find.ancestor(
        of: signUpText,
        matching: find.byType(MouseRegion),
      );
      expect(mouseRegionFinder, findsOneWidget);
      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
      expect(mouseRegion.cursor, SystemMouseCursors.click);
      expect(mouseRegion.opaque, isTrue);

      final gestureFinder = find.ancestor(
        of: signUpText,
        matching: find.byType(GestureDetector),
      );
      final gestureDetector = tester.widget<GestureDetector>(gestureFinder.first);
      expect(gestureDetector.behavior, HitTestBehavior.opaque);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('4. Text "Sign In" under account creation form has click cursor and disabled selection', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SelectionArea(
                  child: AuthFormCard(
                    isLogin: false,
                    isMobile: false,
                    onToggleMode: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final signInLinkText = find.text('Sign In');
      expect(signInLinkText, findsNWidgets(2));

      final bottomSignInText = find.byWidgetPredicate(
        (w) => w is Text && w.data == 'Sign In' && w.style?.decoration == TextDecoration.underline,
      );
      expect(bottomSignInText, findsOneWidget);

      final mouseRegionFinder = find.ancestor(
        of: bottomSignInText,
        matching: find.byType(MouseRegion),
      );
      expect(mouseRegionFinder, findsOneWidget);
      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
      expect(mouseRegion.cursor, SystemMouseCursors.click);
      expect(mouseRegion.opaque, isTrue);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('5. Entry mode blocks in canvas have click cursor, opaque behavior, and trigger mode toggle', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool? selectedMode;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionArea(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  height: 900,
                  child: AuthCanvas(
                    isLogin: true,
                    onAuthModeChanged: (isLogin) => selectedMode = isLogin,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final returningLearnerText = find.text('RETURNING LEARNER');
      expect(returningLearnerText, findsOneWidget);

      final newLearnerText = find.text('NEW LEARNER');
      expect(newLearnerText, findsOneWidget);

      final returningRegion = tester.widget<MouseRegion>(
        find.ancestor(of: returningLearnerText, matching: find.byType(MouseRegion)).first,
      );
      expect(returningRegion.cursor, SystemMouseCursors.click);
      expect(returningRegion.opaque, isTrue);

      final newLearnerRegion = tester.widget<MouseRegion>(
        find.ancestor(of: newLearnerText, matching: find.byType(MouseRegion)).first,
      );
      expect(newLearnerRegion.cursor, SystemMouseCursors.click);
      expect(newLearnerRegion.opaque, isTrue);

      await tester.tap(newLearnerText);
      await tester.pump();
      expect(selectedMode, isFalse);
    });
  });
}
