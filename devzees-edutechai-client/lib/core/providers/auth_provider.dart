import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth/login_request.dart';
import '../../data/models/auth/user_create_request.dart';
import '../../data/models/auth/user_current_profile_response.dart';
import '../services/auth_service.dart';
import 'active_session_provider.dart';
import 'learning_provider.dart';
import 'gamification_provider.dart';
import 'user_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Represents the high-level lifecycle state of the user's authentication session.
enum AuthStatus {
  /// Cold boot / F5 refresh — currently verifying session cookie via GET /auth/me
  initial,

  /// Valid session verified with the backend, user profile is available
  authenticated,

  /// No valid session, cookie expired/revoked, or user signed out
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final bool isLoading;
  final String? error;
  final String? loadingMessage;
  final UserCurrentProfileResponse? user;

  AuthState({
    this.status = AuthStatus.initial,
    this.isLoading = false,
    this.error,
    this.loadingMessage,
    this.user,
  });

  /// Convenience boolean for backward-compatibility with existing widgets/guards
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// True during cold start / F5 refresh before auth/me returns
  bool get isInitial => status == AuthStatus.initial;

  /// True when the user is explicitly signed out or unauthenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? loadingMessage,
    UserCurrentProfileResponse? user,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      loadingMessage: loadingMessage,
      user: clearUser ? null : (user ?? this.user),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);

    // Automatically verify session cookie on app startup / page refresh (F5)
    Future.microtask(() => tryRestoreSession());

    return AuthState(status: AuthStatus.initial);
  }

  /// Restores session on cold boot or browser refresh (F5) by verifying the HTTP-only
  /// or client cookie against the `/auth/me` endpoint.
  Future<bool> tryRestoreSession() async {
    try {
      final profile = await _authService.getMe();
      if (profile != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: profile,
          isLoading: false,
          clearError: true,
        );
        return true;
      }
    } catch (_) {
      // 401 or network drop — treat as unauthenticated session
    }

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      isLoading: false,
    );
    return false;
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      loadingMessage: 'Authenticating...',
      clearError: true,
    );
    try {
      final request = LoginRequest(email: email, password: password);
      final success = await _authService.login(request);
      if (success) {
        state = state.copyWith(loadingMessage: 'Loading profile...');
        UserCurrentProfileResponse? profile;
        try {
          profile = await _authService.getMe();
        } catch (_) {
          // Proceed with login even if initial profile fetch has a minor hiccup
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: profile,
          isLoading: false,
          clearError: true,
        );

        ref.invalidate(userProvider);
        return true;
      }
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        error: 'Login failed.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? mobileNumber,
    String? country,
  }) async {
    state = state.copyWith(
      isLoading: true,
      loadingMessage: 'Initializing Agent Workspace...',
      clearError: true,
    );
    try {
      final request = UserCreateRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        mobile: mobileNumber,
        country: country,
      );
      final success = await _authService.createUser(request);
      state = state.copyWith(isLoading: false);
      if (success) {
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Registration failed.');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, loadingMessage: 'Signing out...');
    await _authService.logout();
    state = AuthState(status: AuthStatus.unauthenticated); // Reset auth state entirely
    
    // Invalidate user-specific state to clear data for next login
    ref.invalidate(userProvider);
    ref.invalidate(activeSessionProvider);
    ref.invalidate(sessionsProvider);
    ref.invalidate(gamificationEventProvider);
    ref.invalidate(journeyCompleteProvider);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
