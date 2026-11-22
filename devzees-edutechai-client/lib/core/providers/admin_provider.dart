import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/admin/paginated_user_response.dart';
import '../../data/models/admin/paginated_role_response.dart';
import '../../data/models/admin/privilege_response.dart';
import '../../data/models/admin/role_create_request.dart';
import '../../data/models/admin/role_edit_request.dart';
import '../../data/models/admin/subscription_update_request.dart';
import '../../data/models/admin/system_setting_model.dart';
import '../../data/models/admin/setting_update_request.dart';
import '../../data/models/admin/subscription_tier_model.dart';
import '../services/admin_service.dart';
import '../services/subscription_service.dart';
import 'auth_provider.dart';

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
    ref.listen(currentUserIdProvider, (previous, next) {
      if (previous != next) state = AdminUsersState();
    });
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
    ref.listen(currentUserIdProvider, (previous, next) {
      if (previous != next) state = AdminRolesState();
    });
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

  Future<void> editRole(String roleId, RoleEditRequest request) async {
    try {
      final service = ref.read(adminServiceProvider);
      await service.editRole(roleId, request);
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
  final Map<String, int> tierCounts;
  final Map<String, String> tierNames;

  AdminMetrics({
    required this.totalUsers,
    required this.freeCount,
    required this.proCount,
    required this.ultraCount,
    required this.totalRoles,
    this.tierCounts = const {},
    this.tierNames = const {},
  });

  factory AdminMetrics.fromJson(Map<String, dynamic> json) {
    final free = (json['free_count'] ?? json['freeCount']) as int? ?? 0;
    final pro = (json['pro_count'] ?? json['proCount']) as int? ?? 0;
    final ultra = (json['ultra_count'] ?? json['ultraCount']) as int? ?? 0;

    final rawTierCounts = (json['tier_counts'] ?? json['tierCounts']) as Map<String, dynamic>? ?? {};
    final tierCounts = rawTierCounts.map((k, v) => MapEntry(k.toString().toLowerCase(), (v as num).toInt()));

    final rawTierNames = (json['tier_names'] ?? json['tierNames']) as Map<String, dynamic>? ?? {};
    final tierNames = rawTierNames.map((k, v) => MapEntry(k.toString().toLowerCase(), v.toString()));

    // Fallback if tier_counts wasn't sent
    if (tierCounts.isEmpty) {
      tierCounts['free'] = free;
      tierCounts['pro'] = pro;
      tierCounts['ultra'] = ultra;
    }
    if (tierNames.isEmpty) {
      tierNames['free'] = 'Free Tier';
      tierNames['pro'] = 'Pro Subscribers';
      tierNames['ultra'] = 'Ultra Subscribers';
    }

    return AdminMetrics(
      totalUsers: (json['total_users'] ?? json['totalUsers']) as int? ?? 0,
      freeCount: free,
      proCount: pro,
      ultraCount: ultra,
      totalRoles: (json['total_roles'] ?? json['totalRoles']) as int? ?? 0,
      tierCounts: tierCounts,
      tierNames: tierNames,
    );
  }
}

final adminMetricsProvider = FutureProvider<AdminMetrics>((ref) async {
  ref.watch(currentUserIdProvider);
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

// ─── System Settings State & Notifier ─────────────────────────────

class AdminSettingsState {
  final List<SystemSettingModel> items;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;
  final SystemSettingModel? selectedSetting;
  final String searchQuery;

  AdminSettingsState({
    this.items = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.selectedSetting,
    this.searchQuery = '',
  });

  AdminSettingsState copyWith({
    List<SystemSettingModel>? items,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    SystemSettingModel? selectedSetting,
    bool clearSelected = false,
    String? searchQuery,
  }) {
    return AdminSettingsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      selectedSetting: clearSelected ? null : (selectedSetting ?? this.selectedSetting),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<SystemSettingModel> get filteredItems {
    if (searchQuery.trim().isEmpty) return items;
    final q = searchQuery.toLowerCase().trim();
    return items.where((s) {
      return s.code.toLowerCase().contains(q) ||
          s.value.toLowerCase().contains(q);
    }).toList();
  }
}

class AdminSettingsNotifier extends Notifier<AdminSettingsState> {
  @override
  AdminSettingsState build() {
    ref.listen(currentUserIdProvider, (previous, next) {
      if (previous != next) state = AdminSettingsState();
    });
    return AdminSettingsState();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(adminServiceProvider);
      final items = await service.getAllSettings();
      
      SystemSettingModel? nextSelected;
      if (state.selectedSetting != null) {
        nextSelected = items.firstWhere(
          (s) => s.code == state.selectedSetting!.code,
          orElse: () => items.isNotEmpty ? items.first : state.selectedSetting!,
        );
      } else if (items.isNotEmpty) {
        nextSelected = items.first;
      }

      state = state.copyWith(
        items: items,
        isLoading: false,
        selectedSetting: nextSelected,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void selectSetting(SystemSettingModel setting) {
    state = state.copyWith(
      selectedSetting: setting,
      error: null,
      successMessage: null,
    );
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> updateSetting(String code, String value, int? orderNumber) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
      final service = ref.read(adminServiceProvider);
      final updated = await service.updateSetting(
        code,
        SettingUpdateRequest(value: value, orderNumber: orderNumber),
      );

      final updatedList = state.items.map((s) {
        return s.code == updated.code ? updated : s;
      }).toList();

      state = state.copyWith(
        items: updatedList,
        selectedSetting: updated,
        isSaving: false,
        successMessage: "Setting '$code' updated successfully!",
      );
      final upper = code.toUpperCase();
      if (upper.contains('PRO_') ||
          upper.contains('ULTRA_') ||
          upper.contains('PRICE') ||
          upper.contains('MONTHLY') ||
          upper.contains('ANNUALLY') ||
          upper.contains('YEARLY') || upper.contains('PROMO') || upper.contains('COUPON')) {
        ref.invalidate(pricingCatalogProvider);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final adminSettingsProvider =
    NotifierProvider<AdminSettingsNotifier, AdminSettingsState>(() {
  return AdminSettingsNotifier();
});

// ─── Dynamic Subscription Tiers State & Notifier ────────────────────

class AdminTiersState {
  final List<SubscriptionTierModel> tiers;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;
  final SubscriptionTierModel? selectedTier;

  AdminTiersState({
    this.tiers = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.selectedTier,
  });

  AdminTiersState copyWith({
    List<SubscriptionTierModel>? tiers,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    SubscriptionTierModel? selectedTier,
    bool clearSelected = false,
  }) {
    return AdminTiersState(
      tiers: tiers ?? this.tiers,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      selectedTier: clearSelected ? null : (selectedTier ?? this.selectedTier),
    );
  }
}

class AdminTiersNotifier extends Notifier<AdminTiersState> {
  @override
  AdminTiersState build() {
    ref.listen(currentUserIdProvider, (previous, next) {
      if (previous != next) state = AdminTiersState();
    });
    return AdminTiersState();
  }

  void selectTier(SubscriptionTierModel? tier) {
    state = state.copyWith(selectedTier: tier, clearSelected: tier == null);
  }

  Future<void> loadTiers({bool includeRetired = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(adminServiceProvider);
      final tiers = await service.getSubscriptionTiers(includeRetired: includeRetired);
      state = state.copyWith(
        tiers: tiers,
        isLoading: false,
        selectedTier: state.selectedTier != null
            ? tiers.firstWhere(
                (t) => t.id == state.selectedTier!.id,
                orElse: () => tiers.isNotEmpty ? tiers.first : state.selectedTier!,
              )
            : (tiers.isNotEmpty ? tiers.first : null),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> createTier(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
      final service = ref.read(adminServiceProvider);
      final newTier = await service.createSubscriptionTier(data);
      final updatedList = [...state.tiers, newTier];
      state = state.copyWith(
        tiers: updatedList,
        selectedTier: newTier,
        isSaving: false,
        successMessage: "Subscription tier '${newTier.name}' created successfully!",
      );
      ref.invalidate(pricingCatalogProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateTier(String tierId, Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
      final service = ref.read(adminServiceProvider);
      final updated = await service.updateSubscriptionTierDetails(tierId, data);
      final updatedList = state.tiers.map((t) => t.id == tierId ? updated : t).toList();
      state = state.copyWith(
        tiers: updatedList,
        selectedTier: updated,
        isSaving: false,
        successMessage: "Subscription tier '${updated.name}' updated successfully!",
      );
      ref.invalidate(pricingCatalogProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> retireTier(String tierId) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
      final service = ref.read(adminServiceProvider);
      await service.retireSubscriptionTier(tierId);
      final updatedList = state.tiers.where((t) => t.id != tierId).toList();
      state = state.copyWith(
        tiers: updatedList,
        clearSelected: state.selectedTier?.id == tierId,
        isSaving: false,
        successMessage: 'Subscription tier retired successfully.',
      );
      ref.invalidate(pricingCatalogProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final adminTiersProvider =
    NotifierProvider<AdminTiersNotifier, AdminTiersState>(() {
  return AdminTiersNotifier();
});

