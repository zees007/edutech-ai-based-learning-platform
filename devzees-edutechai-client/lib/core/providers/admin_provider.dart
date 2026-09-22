import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/admin/paginated_user_response.dart';
import '../../data/models/admin/paginated_role_response.dart';
import '../../data/models/admin/privilege_response.dart';
import '../../data/models/admin/role_create_request.dart';
import '../../data/models/admin/subscription_update_request.dart';
import '../../data/models/admin/user_response.dart';
import '../services/admin_service.dart';

// ─── Service Provider ─────────────────────────────────────────────
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

// ─── User Management State ────────────────────────────────────────

class AdminUsersState {
  final PaginatedUserResponse? data;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int page;
  final String? sortBy;
  final bool isDesc;

  AdminUsersState({
    this.data,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.page = 0,
    this.sortBy,
    this.isDesc = false,
  });

  AdminUsersState copyWith({
    PaginatedUserResponse? data,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? page,
    String? sortBy,
    bool? isDesc,
  }) {
    return AdminUsersState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      sortBy: sortBy ?? this.sortBy,
      isDesc: isDesc ?? this.isDesc,
    );
  }
}

class AdminUsersNotifier extends Notifier<AdminUsersState> {
  Timer? _debounce;

  @override
  AdminUsersState build() {
    ref.onDispose(() => _debounce?.cancel());
    return AdminUsersState();
  }

  Future<void> loadUsers({int size = 50}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(adminServiceProvider);
      final result = await service.searchUsers(
        page: state.page,
        size: size,
        lookupText: state.searchQuery.isEmpty ? null : state.searchQuery,
        sortBy: state.sortBy,
        isDesc: state.isDesc,
      );
      state = state.copyWith(data: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query, page: 0);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      loadUsers();
    });
  }

  void setPage(int newPage) {
    state = state.copyWith(page: newPage);
    loadUsers();
  }

  void setSort(String field) {
    if (state.sortBy == field) {
      // Toggle desc if same field
      state = state.copyWith(isDesc: !state.isDesc, page: 0);
    } else {
      // New field, default to asc
      state = state.copyWith(sortBy: field, isDesc: false, page: 0);
    }
    loadUsers();
  }

  Future<void> assignRoles(String userId, List<String> roleIds) async {
    try {
      final service = ref.read(adminServiceProvider);
      await service.assignUserRoles(userId, roleIds);
      await loadUsers(); // Refresh list
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}

final adminUsersProvider =
    NotifierProvider<AdminUsersNotifier, AdminUsersState>(() {
  return AdminUsersNotifier();
});

// ─── Role Management State ────────────────────────────────────────

class AdminRolesState {
  final PaginatedRoleResponse? data;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int page;
  final String? sortBy;
  final bool isDesc;

  AdminRolesState({
    this.data, 
    this.isLoading = false, 
    this.error,
    this.searchQuery = '',
    this.page = 0,
    this.sortBy,
    this.isDesc = false,
  });

  AdminRolesState copyWith({
    PaginatedRoleResponse? data,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? page,
    String? sortBy,
    bool? isDesc,
  }) {
    return AdminRolesState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      sortBy: sortBy ?? this.sortBy,
      isDesc: isDesc ?? this.isDesc,
    );
  }
}

class AdminRolesNotifier extends Notifier<AdminRolesState> {
  Timer? _debounce;

  @override
  AdminRolesState build() {
    ref.onDispose(() => _debounce?.cancel());
    return AdminRolesState();
  }

  Future<void> loadRoles({int size = 50}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(adminServiceProvider);
      final result = await service.searchRoles(
        page: state.page, 
        size: size,
        lookupText: state.searchQuery.isEmpty ? null : state.searchQuery,
        sortBy: state.sortBy,
        isDesc: state.isDesc,
      );
      state = state.copyWith(data: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query, page: 0);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      loadRoles();
    });
  }

  void setPage(int newPage) {
    state = state.copyWith(page: newPage);
    loadRoles();
  }

  void setSort(String field) {
    if (state.sortBy == field) {
      state = state.copyWith(isDesc: !state.isDesc, page: 0);
    } else {
      state = state.copyWith(sortBy: field, isDesc: false, page: 0);
    }
    loadRoles();
  }

  Future<void> createRole(RoleCreateRequest request) async {
    try {
      final service = ref.read(adminServiceProvider);
      await service.createRole(request);
      await loadRoles(); // Refresh list
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}

final adminRolesProvider =
    NotifierProvider<AdminRolesNotifier, AdminRolesState>(() {
  return AdminRolesNotifier();
});

// ─── Privileges Provider ──────────────────────────────────────────

final adminPrivilegesProvider =
    FutureProvider<List<PrivilegeResponse>>((ref) async {
  final service = ref.read(adminServiceProvider);
  return await service.getAllPrivileges();
});

// ─── Analytics / Metrics ──────────────────────────────────────────

class AdminMetrics {
  final int totalUsers;
  final int freeCount;
  final int proCount;
  final int ultraCount;
  final int totalRoles;

  AdminMetrics({
    required this.totalUsers,
    required this.freeCount,
    required this.proCount,
    required this.ultraCount,
    required this.totalRoles,
  });

  factory AdminMetrics.fromJson(Map<String, dynamic> json) {
    return AdminMetrics(
      totalUsers: json['total_users'] as int? ?? 0,
      freeCount: json['free_count'] as int? ?? 0,
      proCount: json['pro_count'] as int? ?? 0,
      ultraCount: json['ultra_count'] as int? ?? 0,
      totalRoles: json['total_roles'] as int? ?? 0,
    );
  }
}

final adminMetricsProvider = FutureProvider<AdminMetrics>((ref) async {
  final service = ref.read(adminServiceProvider);
  final data = await service.getAdminMetrics();
  return AdminMetrics.fromJson(data);
});

// ─── Subscription Tier Update ─────────────────────────────────────

Future<void> updateUserSubscription(
  AdminService service,
  String userId,
  SubscriptionUpdateRequest request,
) async {
  await service.updateSubscriptionTier(userId, request);
}
