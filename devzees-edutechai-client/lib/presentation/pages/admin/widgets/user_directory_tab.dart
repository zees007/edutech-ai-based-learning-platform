import 'package:flutter/material.dart';
import '../../../widgets/center_toast.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/admin/user_response.dart';
import '../../../widgets/shimmer_loading.dart';
import 'admin_data_table.dart';
import 'searchable_user_dropdown.dart';
import 'tier_badge.dart';

/// User Directory & Role Assignment tab.
/// Displays Manage User Role section first with a searchable user dropdown,
/// followed by the full User Directory table below.
class UserDirectoryTab extends ConsumerStatefulWidget {
  const UserDirectoryTab({super.key});

  @override
  ConsumerState<UserDirectoryTab> createState() => _UserDirectoryTabState();
}

class _UserDirectoryTabState extends ConsumerState<UserDirectoryTab> {
  final ScrollController _scrollController = ScrollController();

  AdminUserResponse? _selectedUser;
  String? _selectedUserId;
  List<String> _selectedRoleIds = [];
  String _roleSearchQuery = '';
  bool _isSavingRoles = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUsersProvider.notifier).loadUsers();
      ref.read(adminRolesProvider.notifier).loadRoles();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectUser(AdminUserResponse? user) {
    setState(() {
      _selectedUser = user;
      _selectedUserId = user?.id;
      if (user != null) {
        _selectedRoleIds =
            user.roles.where((r) => !r.retired).map((r) => r.id).toList();
      } else {
        _selectedRoleIds = [];
      }
    });
  }

  void _selectUserFromTable(AdminUserResponse user) {
    _selectUser(user);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _resetRoles() {
    if (_selectedUser != null) {
      setState(() {
        _selectedRoleIds = _selectedUser!.roles
            .where((r) => !r.retired)
            .map((r) => r.id)
            .toList();
      });
    }
  }

  bool get _hasUnsavedRoleChanges {
    if (_selectedUser == null) return false;
    final originalRoleIds = _selectedUser!.roles
        .where((r) => !r.retired)
        .map((r) => r.id)
        .toSet();
    final currentRoleIds = _selectedRoleIds.toSet();
    return originalRoleIds.length != currentRoleIds.length ||
        !originalRoleIds.containsAll(currentRoleIds);
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(adminUsersProvider);
    final rolesState = ref.watch(adminRolesProvider);
    final usersList = usersState.data?.items ?? [];

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'User Directory & Role Assignment',
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Assign system roles to users and manage platform directory accounts',
            style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          // ─── 1. Manage User Roles Section (First) ─────────────────────────
          _buildRoleAssignmentCard(usersList, rolesState),

          const SizedBox(height: 32),

          // Divider
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.glassBorder,
          ),

          const SizedBox(height: 28),

          // ─── 2. User Directory Table Section ──────────────────────────────
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Directory',
                    style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse, filter, and inspect registered users across the platform',
                    style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              if (usersState.data != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDeep.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    'Showing ${usersState.data!.items.length} of ${usersState.data!.total} users',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Directory Search Bar
          _buildSearchBar(),
          const SizedBox(height: 16),

          // Users Table
          if (usersState.isLoading && usersState.data == null)
            const ShimmerLoading(child: ShimmerBox(height: 300))
          else if (usersState.error != null)
            _buildErrorCard(usersState.error!)
          else if (usersState.data != null)
            _buildUsersTable(usersState),
        ],
      ),
    );
  }

  Widget _buildRoleAssignmentCard(
    List<AdminUserResponse> users,
    AdminRolesState rolesState,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage User Roles',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Select a user to review and update their assigned roles',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Selector Label
          Text(
            'Select User to Manage:',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          // Searchable User Dropdown
          SearchableUserDropdown(
            users: users,
            selectedUser: _selectedUser,
            hintText: 'Search or select a user to update roles...',
            onUserSelected: _selectUser,
            onSearchRemote: (query) async {
              final service = ref.read(adminServiceProvider);
              final result = await service.searchUsers(
                lookupText: query,
                size: 20,
              );
              return result.items;
            },
          ),

          const SizedBox(height: 16),

          // When a user is selected: Show user detail banner + role selection controls
          if (_selectedUser != null) ...[
            _buildSelectedUserDetails(_selectedUser!),
            const SizedBox(height: 20),

            // Roles Header with Search Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Assigned System Roles:',
                      style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                    ),
                    if (_hasUnsavedRoleChanges) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.purple.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'Unsaved changes',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.purple,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(
                  width: 220,
                  child: _buildRoleSearchBar(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Role Chips
            if (rolesState.isLoading && rolesState.data == null)
              const ShimmerLoading(child: ShimmerBox(height: 48))
            else if (rolesState.data != null)
              _buildRoleChips(rolesState.data!.items),

            const SizedBox(height: 20),

            // Actions Row
            Row(
              children: [
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    icon: _isSavingRoles
                        ? const SizedBox.shrink()
                        : const Icon(Icons.check, size: 18),
                    onPressed: _isSavingRoles ? null : _saveRoleAssignment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    label: _isSavingRoles
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Role Assignments',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
                if (_hasUnsavedRoleChanges) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.undo, size: 16),
                      label: Text('Reset', style: AppTextStyles.button),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.glassBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: _isSavingRoles ? null : _resetRoles,
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            // Empty placeholder state prompting the user to select a user
            _buildEmptyUserPrompt(),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedUserDetails(AdminUserResponse user) {
    final initials =
        '${user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : ''}${user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : ''}';
    final tier = user.subscription?.tier ?? 'free';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.purple.withValues(alpha: 0.25),
            child: Text(
              initials.isEmpty ? 'U' : initials,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${user.firstName} ${user.lastName}',
                        style: AppTextStyles.subtitle2.copyWith(color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.retired
                            ? AppColors.rose.withValues(alpha: 0.15)
                            : AppColors.accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.retired ? 'Retired' : 'Active',
                        style: AppTextStyles.badge.copyWith(
                          color: user.retired ? AppColors.rose : AppColors.accentGreen,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      user.email,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    if (user.mobile != null && user.mobile!.isNotEmpty)
                      Text(
                        '• ${user.mobile}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                      ),
                    if (user.country != null && user.country!.isNotEmpty)
                      Text(
                        '• ${user.country}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TierBadge(tier: tier),
        ],
      ),
    );
  }

  Widget _buildEmptyUserPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 38,
            color: AppColors.purple.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          Text(
            'No User Selected',
            style: AppTextStyles.subtitle2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              'Search and choose a user from the dropdown above, or click "Manage" on any user in the directory table below to view and update their system roles.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChips(List<dynamic> roles) {
    final query = _roleSearchQuery.trim().toLowerCase();
    final filteredRoles = roles.where((role) {
      if (query.isEmpty) return true;
      return role.name.toLowerCase().contains(query);
    }).toList();

    if (filteredRoles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No roles match "$_roleSearchQuery"',
          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filteredRoles.map((role) {
        final isSelected = _selectedRoleIds.contains(role.id);
        return FilterChip(
          label: Text(role.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedRoleIds.add(role.id);
              } else {
                _selectedRoleIds.remove(role.id);
              }
            });
          },
          selectedColor: AppColors.purple.withValues(alpha: 0.22),
          checkmarkColor: AppColors.purple,
          backgroundColor: AppColors.glassBase,
          side: BorderSide(
            color: isSelected
                ? AppColors.purple.withValues(alpha: 0.6)
                : AppColors.glassBorder,
          ),
          labelStyle: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.glassBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(adminUsersProvider.notifier).updateSearch(value);
        },
        style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search users by name, email, or mobile...',
          hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRoleSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.glassBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _roleSearchQuery = value;
          });
        },
        style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search roles...',
          hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 16),
          suffixIcon: _roleSearchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 14, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _roleSearchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        ),
      ),
    );
  }

  Widget _buildUsersTable(AdminUsersState state) {
    final users = state.data!.items;
    return AdminDataTable(
      columns: const ['Name', 'Email', 'Country', 'Tier', 'Roles', 'Status', 'Created', 'Actions'],
      columnWidths: const [1.4, 1.8, 0.9, 0.8, 1.8, 0.8, 1.1, 1.0],
      sortBy: state.sortBy,
      isDesc: state.isDesc,
      onSort: (colName) {
        String field = colName.toLowerCase();
        if (colName == 'Name') field = 'first_name';
        if (colName == 'Created') field = 'created_at';
        ref.read(adminUsersProvider.notifier).setSort(field);
      },
      currentPage: state.page,
      totalPages: state.data!.totalPages,
      onPageChanged: (newPage) {
        ref.read(adminUsersProvider.notifier).setPage(newPage);
      },
      rows: users.map<List<Widget>>((u) {
        final rolesStr = u.roles.where((r) => !r.retired).map((r) => r.name).join(', ');
        final tier = u.subscription?.tier ?? 'free';
        final isSelected = _selectedUserId == u.id;

        return [
          Text(
            '${u.firstName} ${u.lastName}',
            style: AppTextStyles.body2.copyWith(
              color: isSelected ? AppColors.purple : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            u.email,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            u.country ?? 'N/A',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
          TierBadge(tier: tier),
          Text(
            rolesStr.isEmpty ? 'None' : rolesStr,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: u.retired
                  ? AppColors.rose.withValues(alpha: 0.1)
                  : AppColors.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              u.retired ? 'Retired' : 'Active',
              style: AppTextStyles.badge.copyWith(
                color: u.retired ? AppColors.rose : AppColors.accentGreen,
              ),
            ),
          ),
          Text(
            _formatDate(u.createdAt),
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
          // Actions: Manage Roles button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: OutlinedButton.icon(
              icon: Icon(
                isSelected ? Icons.check : Icons.shield_outlined,
                size: 14,
                color: isSelected ? AppColors.accentGreen : AppColors.purple,
              ),
              label: Text(
                isSelected ? 'Selected' : 'Manage',
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.accentGreen : AppColors.purple,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: const Size(0, 30),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.accentGreen.withValues(alpha: 0.6)
                      : AppColors.purple.withValues(alpha: 0.4),
                ),
                backgroundColor: isSelected
                    ? AppColors.accentGreen.withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _selectUserFromTable(u),
            ),
          ),
        ];
      }).toList(),
    );
  }

  Future<void> _saveRoleAssignment() async {
    if (_selectedUserId == null) return;
    setState(() => _isSavingRoles = true);
    try {
      await ref
          .read(adminUsersProvider.notifier)
          .assignRoles(_selectedUserId!, _selectedRoleIds);

      final rolesState = ref.read(adminRolesProvider);
      if (_selectedUser != null && rolesState.data != null) {
        final assignedRoles = rolesState.data!.items
            .where((r) => _selectedRoleIds.contains(r.id))
            .toList();
        setState(() {
          _selectedUser = _selectedUser!.copyWith(roles: assignedRoles);
        });
      }

      if (mounted) {
        CenterToast.showSuccess(
          context,
          _selectedUser != null
              ? 'Roles updated successfully for ${_selectedUser!.firstName} ${_selectedUser!.lastName}!'
              : 'Roles updated successfully!',
          title: 'Roles Updated',
        );
      }
    } catch (e) {
      if (mounted) {
        CenterToast.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
          title: 'Update Error',
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingRoles = false);
    }
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.rose.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.rose),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.body2.copyWith(color: AppColors.rose),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(adminUsersProvider.notifier).loadUsers(),
            child: Text('Retry', style: AppTextStyles.button.copyWith(color: AppColors.rose)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
