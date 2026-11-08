import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/providers/admin_provider.dart';
import 'package:devzees_edutechai_client/data/models/admin/user_response.dart';
import 'package:devzees_edutechai_client/data/models/admin/role_response.dart';
import 'package:devzees_edutechai_client/data/models/admin/paginated_user_response.dart';
import 'package:devzees_edutechai_client/data/models/admin/paginated_role_response.dart';
import 'package:devzees_edutechai_client/presentation/pages/admin/widgets/searchable_user_dropdown.dart';
import 'package:devzees_edutechai_client/presentation/pages/admin/widgets/user_directory_tab.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final dummyRoleAdmin = RoleResponse(
    id: 'role-admin',
    name: 'Administrator',
    privileges: [],
    createdAt: DateTime(2025, 1, 1),
  );

  final dummyRoleStudent = RoleResponse(
    id: 'role-student',
    name: 'Student',
    privileges: [],
    createdAt: DateTime(2025, 1, 1),
  );

  final dummyUser1 = AdminUserResponse(
    id: 'user-1',
    firstName: 'Alice',
    lastName: 'Smith',
    email: 'alice@example.com',
    country: 'US',
    roles: [dummyRoleAdmin],
    createdAt: DateTime(2025, 1, 1),
  );

  final dummyUser2 = AdminUserResponse(
    id: 'user-2',
    firstName: 'Bob',
    lastName: 'Jones',
    email: 'bob@example.com',
    country: 'CA',
    roles: [dummyRoleStudent],
    createdAt: DateTime(2025, 1, 2),
  );

  group('SearchableUserDropdown Widget Tests', () {
    testWidgets('Renders placeholder and hint when no user is selected', (tester) async {
      AdminUserResponse? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchableUserDropdown(
              users: [dummyUser1, dummyUser2],
              selectedUser: selected,
              hintText: 'Select a user...',
              onUserSelected: (u) => selected = u,
            ),
          ),
        ),
      );

      expect(find.text('Select a user...'), findsOneWidget);
      expect(find.byIcon(Icons.person_search_outlined), findsOneWidget);
    });

    testWidgets('Opens overlay on tap and filters users by search query', (tester) async {
      AdminUserResponse? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: SearchableUserDropdown(
                users: [dummyUser1, dummyUser2],
                selectedUser: selected,
                hintText: 'Select a user...',
                onUserSelected: (u) => selected = u,
              ),
            ),
          ),
        ),
      );

      // Tap trigger to open dropdown
      await tester.tap(find.text('Select a user...'));
      await tester.pumpAndSettle();

      // Both users should be visible
      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('Bob Jones'), findsOneWidget);

      // Type "bob" in search box
      await tester.enterText(find.byType(TextField), 'bob');
      await tester.pumpAndSettle();

      // Alice should be filtered out, Bob should remain
      expect(find.text('Alice Smith'), findsNothing);
      expect(find.text('Bob Jones'), findsOneWidget);

      // Tap Bob Jones to select
      await tester.tap(find.text('Bob Jones'));
      await tester.pumpAndSettle();

      expect(selected, equals(dummyUser2));
    });

    testWidgets('Displays selected user and clears on clicking close icon', (tester) async {
      AdminUserResponse? selected = dummyUser1;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SearchableUserDropdown(
                  users: [dummyUser1, dummyUser2],
                  selectedUser: selected,
                  onUserSelected: (u) {
                    setState(() => selected = u);
                  },
                ),
              ),
            );
          },
        ),
      );

      // Verify selected user name and email
      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);

      // Click clear button
      final clearButton = find.byTooltip('Deselect user');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(selected, isNull);
    });
  });

  group('UserDirectoryTab Layout & Role Management First', () {
    testWidgets('Displays Manage User Roles first followed by User Directory', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final mockUsers = PaginatedUserResponse(
        items: [dummyUser1, dummyUser2],
        total: 2,
        page: 0,
        size: 50,
        totalPages: 1,
      );

      final mockRoles = PaginatedRoleResponse(
        items: [dummyRoleAdmin, dummyRoleStudent],
        total: 2,
        page: 0,
        size: 50,
        totalPages: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminUsersProvider.overrideWith(() => _MockAdminUsersNotifier(mockUsers)),
            adminRolesProvider.overrideWith(() => _MockAdminRolesNotifier(mockRoles)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UserDirectoryTab(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header
      expect(find.text('User Directory & Role Assignment'), findsOneWidget);

      // "Manage User Roles" should be present
      expect(find.text('Manage User Roles'), findsOneWidget);

      // "User Directory" section title should also be present
      expect(find.text('User Directory'), findsOneWidget);

      // Verify layout order: Manage User Roles appears before User Directory in Y position
      final manageRolesFinder = find.text('Manage User Roles');
      final userDirectoryFinder = find.text('User Directory');

      final manageRolesTop = tester.getTopLeft(manageRolesFinder).dy;
      final userDirectoryTop = tester.getTopLeft(userDirectoryFinder).dy;

      expect(manageRolesTop, lessThan(userDirectoryTop),
          reason: 'Manage User Roles section MUST appear above the User Directory table');

      // Table shows users and "Manage" action buttons
      expect(find.text('Manage'), findsNWidgets(2));

      // Initially no user is selected
      expect(find.text('No User Selected'), findsOneWidget);

      // Tap first "Manage" button on Alice Smith's row
      await tester.tap(find.text('Manage').first);
      await tester.pumpAndSettle();

      // Now Alice Smith should be selected in Manage User Roles
      expect(find.text('No User Selected'), findsNothing);
      expect(find.text('Assigned System Roles:'), findsOneWidget);
      expect(find.text('Save Role Assignments'), findsOneWidget);

      // Alice's table action button now displays "Selected"
      expect(find.text('Selected'), findsOneWidget);
    });
  });
}

class _MockAdminUsersNotifier extends AdminUsersNotifier {
  final PaginatedUserResponse _initialData;
  _MockAdminUsersNotifier(this._initialData);

  @override
  AdminUsersState build() {
    return AdminUsersState(data: _initialData);
  }

  @override
  Future<void> loadUsers({int size = 50}) async {}
}

class _MockAdminRolesNotifier extends AdminRolesNotifier {
  final PaginatedRoleResponse _initialData;
  _MockAdminRolesNotifier(this._initialData);

  @override
  AdminRolesState build() {
    return AdminRolesState(data: _initialData);
  }

  @override
  Future<void> loadRoles({int size = 50}) async {}
}
