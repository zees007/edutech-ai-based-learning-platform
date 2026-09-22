import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/admin/user_response.dart';
import '../../../widgets/shimmer_loading.dart';
import 'admin_data_table.dart';
import 'tier_badge.dart';

/// User Directory & Role Assignment tab.
class UserDirectoryTab extends ConsumerStatefulWidget {
  const UserDirectoryTab({super.key});

  @override
  ConsumerState<UserDirectoryTab> createState() => _UserDirectoryTabState();
}

class _UserDirectoryTabState extends ConsumerState<UserDirectoryTab> {
  String? _selectedUserId;
  List<String> _selectedRoleIds = [];
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
  Widget build(BuildContext context) {
    final usersState = ref.watch(adminUsersProvider);
    final rolesState = ref.watch(adminRolesProvider);

    return SingleChildScrollView(
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
            'Search, view, and manage user role assignments',
            style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 16),

          // Count
          if (usersState.data != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Showing ${usersState.data!.items.length} of ${usersState.data!.total} users',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
            ),

          // Users Table
          if (usersState.isLoading && usersState.data == null)
            const ShimmerLoading(child: ShimmerBox(height: 300))
          else if (usersState.error != null)
            _buildErrorCard(usersState.error!)
          else if (usersState.data != null)
            _buildUsersTable(usersState),

          const SizedBox(height: 32),

          // Role Assignment Section
          if (usersState.data != null && usersState.data!.items.isNotEmpty) ...[
            Container(
              width: double.infinity,
              height: 1,
              color: AppColors.glassBorder,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage User Roles',
                  style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(
                  width: 250,
                  child: _buildRoleSearchBar(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRoleAssignment(usersState.data!.items, rolesState),
          ],
        ],
      ),
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
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
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
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.glassBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(adminRolesProvider.notifier).updateSearch(value);
        },
        style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search roles...',
          hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildUsersTable(AdminUsersState state) {
    final users = state.data!.items;
    return AdminDataTable(
      columns: const ['Name', 'Email', 'Country', 'Tier', 'Roles', 'Status', 'Created'],
      columnWidths: const [1.5, 2.0, 1.0, 0.8, 2.0, 0.8, 1.2],
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
        return [
          Text(
            '${u.firstName} ${u.lastName}',
            style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
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
        ];
      }).toList(),
    );
  }

  Widget _buildRoleAssignment(
    List<AdminUserResponse> users,
    AdminRolesState rolesState,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Dropdown
          Text(
            'Select User to Update Roles:',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.glassBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: DropdownButton<String>(
              value: _selectedUserId,
              isExpanded: true,
              dropdownColor: AppColors.popoverBackground,
              underline: const SizedBox.shrink(),
              hint: Text(
                'Choose a user...',
                style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
              ),
              style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
              items: users.map((u) {
                return DropdownMenuItem(
                  value: u.id,
                  child: Text('${u.firstName} ${u.lastName} (${u.email})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value;
                  if (value != null) {
                    final user = users.firstWhere((u) => u.id == value);
                    _selectedRoleIds =
                        user.roles.where((r) => !r.retired).map((r) => r.id).toList();
                  }
                });
              },
            ),
          ),
          if (_selectedUserId != null && rolesState.data != null) ...[
            const SizedBox(height: 16),
            Text(
              'Assigned Roles:',
              style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: rolesState.data!.items.map((role) {
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
                  selectedColor: AppColors.purple.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.purple,
                  backgroundColor: AppColors.glassBase,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.purple.withValues(alpha: 0.5)
                        : AppColors.glassBorder,
                  ),
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _isSavingRoles ? null : _saveRoleAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSavingRoles
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
          ],
        ],
      ),
    );
  }

  Future<void> _saveRoleAssignment() async {
    if (_selectedUserId == null) return;
    setState(() => _isSavingRoles = true);
    try {
      await ref
          .read(adminUsersProvider.notifier)
          .assignRoles(_selectedUserId!, _selectedRoleIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Roles updated successfully!'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.rose,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
