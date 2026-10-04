import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/permission_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// Riverpod provider that exposes a [PermissionChecker] derived from the
/// current user's privilege codes.
///
/// Automatically updates when the user profile changes (login, logout,
/// subscription upgrade/downgrade).
///
/// Usage in any ConsumerWidget:
/// ```dart
///   final perms = ref.watch(permissionProvider);
///   if (perms.canExportPdf) { /* ... */ }
///   if (perms.isAdmin) { /* ... */ }
/// ```
final permissionProvider = Provider<PermissionChecker>((ref) {
  // Synchronously read from authProvider's cached user profile so privilege codes
  // on F5 refresh evaluate immediately without waiting for FutureProvider.
  final authUser = ref.watch(authProvider.select((s) => s.user));
  final userProfile = authUser ?? ref.watch(userProvider).asData?.value;
  return PermissionChecker(userProfile?.privilegeCodes ?? []);
});
