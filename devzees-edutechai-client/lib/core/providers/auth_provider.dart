import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth/login_request.dart';
import '../../data/models/auth/user_create_request.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? loadingMessage;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.loadingMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? loadingMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      loadingMessage: loadingMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    return AuthState();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, loadingMessage: 'Authenticating...', error: null);
    try {
      final request = LoginRequest(email: email, password: password);
      final success = await _authService.login(request);
      if (success) {
        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Login failed.');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
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
    state = state.copyWith(isLoading: true, loadingMessage: 'Initializing Agent Workspace...', error: null);
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
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
