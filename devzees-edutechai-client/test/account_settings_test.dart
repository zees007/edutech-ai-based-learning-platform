import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/core/services/permission_service.dart';
import 'package:devzees_edutechai_client/data/models/auth/user_current_profile_response.dart';
import 'package:devzees_edutechai_client/presentation/widgets/account_settings_dialog.dart';

class MockAuthNotifier extends AuthNotifier {
  final UserCurrentProfileResponse? initialUser;
  MockAuthNotifier({this.initialUser});

  @override
  AuthState build() {
    return AuthState(
      status: initialUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: initialUser,
    );
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PermissionChecker — Change Password & User Management', () {
    test('User with ET_CHANGE_PASSWORD has canChangePassword == true', () {
      final perms = PermissionChecker(['ET_CHANGE_PASSWORD', 'ET_VIEW_USER']);
      expect(perms.canChangePassword, isTrue);
      expect(perms.canEditUser, isFalse);
    });

    test('User with ET_ALL has universal canChangePassword == true', () {
      final perms = PermissionChecker(['ET_ALL']);
      expect(perms.canChangePassword, isTrue);
      expect(perms.canEditUser, isTrue);
      expect(perms.isSuperAdmin, isTrue);
    });

    test('User without ET_CHANGE_PASSWORD has canChangePassword == false', () {
      final perms = PermissionChecker(['ET_VIEW_SUBSCRIPTION']);
      expect(perms.canChangePassword, isFalse);
    });
  });

  group('AccountSettingsDialog — Widget Tests', () {
    final mockUser = UserCurrentProfileResponse(
      id: 'test-user-id-123',
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      country: 'United Kingdom',
      mobile: '+44 7700 900077',
      createdAt: DateTime.now(),
      roles: ['Free'],
      privilegeCodes: ['ET_CHANGE_PASSWORD'],
    );

    testWidgets('Renders Profile tab with user details pre-populated', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => MockAuthNotifier(initialUser: mockUser)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    AccountSettingsDialog.show(context, initialTab: 0);
                  },
                  child: const Text('Open Settings'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open Dialog
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      // Verify Header & Tabs
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);

      // Verify Profile form fields
      expect(find.text('FIRST NAME *'), findsOneWidget);
      expect(find.text('LAST NAME *'), findsOneWidget);
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('Opens directly to Security tab when initialTab is 1', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => MockAuthNotifier(initialUser: mockUser)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    AccountSettingsDialog.show(context, initialTab: 1);
                  },
                  child: const Text('Open Security'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Security'));
      await tester.pumpAndSettle();

      // Verify Security fields are visible
      expect(find.text('CURRENT PASSWORD *'), findsOneWidget);
      expect(find.text('NEW PASSWORD * (min 6 characters)'), findsOneWidget);
      expect(find.text('CONFIRM NEW PASSWORD *'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);
      expect(find.text('Active Sessions'), findsOneWidget);
      expect(find.text('Sign Out Everywhere'), findsOneWidget);
    });
  });
}
