import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/admin/subscription_update_request.dart';
import '../../../../data/models/admin/user_response.dart';
import '../../../widgets/shimmer_loading.dart';
import 'admin_data_table.dart';
import 'tier_badge.dart';

/// Subscription Tier Manager tab.
class SubscriptionManagerTab extends ConsumerStatefulWidget {
  const SubscriptionManagerTab({super.key});

  @override
  ConsumerState<SubscriptionManagerTab> createState() => _SubscriptionManagerTabState();
}

class _SubscriptionManagerTabState extends ConsumerState<SubscriptionManagerTab> {
  String? _selectedUserId;
  String _selectedTier = 'free';
  String _selectedStatus = 'active';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUsersProvider.notifier).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(adminUsersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Tier Management',
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'View and manage user subscription tiers with automatic role synchronization',
            style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          // Subscription Table
          if (usersState.isLoading && usersState.data == null)
            const ShimmerLoading(child: ShimmerBox(height: 300))
          else if (usersState.error != null)
            _buildErrorCard(usersState.error!)
          else if (usersState.data != null)
            _buildSubscriptionTable(usersState),

          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.glassBorder,
          ),
          const SizedBox(height: 24),

          // Tier Update Section
          Text(
            'Upgrade / Change User Subscription Tier',
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          if (usersState.data != null)
            _buildTierUpdateForm(usersState.data!.items),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTable(AdminUsersState state) {
    final users = state.data!.items;
    return AdminDataTable(
      columns: const ['Name', 'Email', 'Current Tier', 'Status', 'Assigned Roles'],
      columnWidths: const [1.5, 2.0, 1.0, 1.0, 2.5],
      sortBy: state.sortBy,
      isDesc: state.isDesc,
      onSort: (colName) {
        String field = colName.toLowerCase();
        if (colName == 'Name') field = 'first_name';
        if (colName == 'Current Tier') field = 'tier';
        if (colName == 'Status') field = 'status';
        ref.read(adminUsersProvider.notifier).setSort(field);
      },
      currentPage: state.page,
      totalPages: state.data!.totalPages,
      onPageChanged: (newPage) {
        ref.read(adminUsersProvider.notifier).setPage(newPage);
      },
      rows: users.map<List<Widget>>((u) {
        final tier = u.subscription?.tier ?? 'free';
        final status = u.subscription?.status ?? 'active';
        final rolesStr = u.roles.where((r) => !r.retired).map((r) => r.name).join(', ');
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
          TierBadge(tier: tier),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: status == 'active'
                  ? AppColors.accentGreen.withValues(alpha: 0.1)
                  : AppColors.accentAmber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toUpperCase(),
              style: AppTextStyles.badge.copyWith(
                color: status == 'active' ? AppColors.accentGreen : AppColors.accentAmber,
              ),
            ),
          ),
          Text(
            rolesStr.isEmpty ? 'None' : rolesStr,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildTierUpdateForm(List<AdminUserResponse> users) {
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
            'Select User:',
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
                    _selectedTier = user.subscription?.tier.toLowerCase() ?? 'free';
                    _selectedStatus = user.subscription?.status.toLowerCase() ?? 'active';
                  }
                });
              },
            ),
          ),
          if (_selectedUserId != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                // Tier Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Tier:',
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
                          value: _selectedTier,
                          isExpanded: true,
                          dropdownColor: AppColors.popoverBackground,
                          underline: const SizedBox.shrink(),
                          style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                          items: const [
                            DropdownMenuItem(value: 'free', child: Text('FREE Tier')),
                            DropdownMenuItem(value: 'pro', child: Text('PRO Tier')),
                            DropdownMenuItem(value: 'ultra', child: Text('ULTRA Tier')),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedTier = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Status Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status:',
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
                          value: _selectedStatus,
                          isExpanded: true,
                          dropdownColor: AppColors.popoverBackground,
                          underline: const SizedBox.shrink(),
                          style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'canceled', child: Text('Canceled')),
                            DropdownMenuItem(value: 'expired', child: Text('Expired')),
                            DropdownMenuItem(value: 'past_due', child: Text('Past Due')),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedStatus = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Confirmation Dialog + Apply Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : () => _confirmAndApplyTierChange(users),
                icon: _isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync, size: 20),
                label: Text(
                  'Apply Tier Change & Sync Role',
                  style: AppTextStyles.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmAndApplyTierChange(List<AdminUserResponse> users) async {
    final user = users.firstWhere((u) => u.id == _selectedUserId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.popoverBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Tier Change',
          style: AppTextStyles.subtitle1.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Change ${user.firstName} ${user.lastName}\'s subscription to ${_selectedTier.toUpperCase()} ($_selectedStatus)?\n\nThis will automatically synchronize their database roles.',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Apply', style: AppTextStyles.button),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUpdating = true);
    try {
      final service = ref.read(adminServiceProvider);
      final request = SubscriptionUpdateRequest(
        tier: _selectedTier,
        status: _selectedStatus,
      );
      await service.updateSubscriptionTier(_selectedUserId!, request);
      // Refresh users list
      await ref.read(adminUsersProvider.notifier).loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Updated ${user.email} to ${_selectedTier.toUpperCase()}. Roles synchronized!',
            ),
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
      if (mounted) setState(() => _isUpdating = false);
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
            child: Text(error, style: AppTextStyles.body2.copyWith(color: AppColors.rose)),
          ),
          TextButton(
            onPressed: () => ref.read(adminUsersProvider.notifier).loadUsers(),
            child: Text('Retry', style: AppTextStyles.button.copyWith(color: AppColors.rose)),
          ),
        ],
      ),
    );
  }
}
