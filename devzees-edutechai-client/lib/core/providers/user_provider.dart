import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth/user_current_profile_response.dart';
import 'auth_provider.dart';

final userProvider = FutureProvider<UserCurrentProfileResponse?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getMe();
});
