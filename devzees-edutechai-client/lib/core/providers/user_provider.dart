import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth/user_current_profile_response.dart';
import 'auth_provider.dart';

final userProvider = FutureProvider<UserCurrentProfileResponse?>((ref) async {
  final authState = ref.watch(authProvider);

  // If authState already holds the profile (e.g. from tryRestoreSession or login), return it immediately
  if (authState.isAuthenticated && authState.user != null) {
    return authState.user;
  }

  // Not authenticated
  if (!authState.isAuthenticated) {
    return null;
  }

  // Fallback: fetch directly via AuthService if authenticated but profile not yet cached
  final authService = ref.watch(authServiceProvider);
  return await authService.getMe();
});
