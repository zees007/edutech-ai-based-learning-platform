import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/permission_service.dart';
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
  final userProfile = ref.watch(userProvider).asData?.value;
  return PermissionChecker(userProfile?.privilegeCodes ?? []);
});
