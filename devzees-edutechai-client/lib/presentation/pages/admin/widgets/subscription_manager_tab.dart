import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/admin/subscription_tier_model.dart';
import '../../../../data/models/admin/subscription_update_request.dart';
import '../../../../data/models/admin/user_response.dart';
import '../../../widgets/center_toast.dart';
import '../../../widgets/gradient_button.dart';
import '../../../widgets/shimmer_loading.dart';
import 'admin_data_table.dart';
import 'searchable_user_dropdown.dart';
import 'tier_badge.dart';
import 'package:devzees_edutechai_client/core/theme/theme_palette.dart';

/// Subscription & Tier Manager hub with dual tabs:
/// Tab 0: User Subscriptions (assign/change user tier dynamically)
/// Tab 1: Subscription Tiers CRUD (manage commercial plans, limits, and role bindings)
class SubscriptionManagerTab extends ConsumerStatefulWidget {
  const SubscriptionManagerTab({super.key});

  @override
  ConsumerState<SubscriptionManagerTab> createState() =>
      _SubscriptionManagerTabState();
}

class _SubscriptionManagerTabState
    extends ConsumerState<SubscriptionManagerTab> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _formKey = GlobalKey();

  int _activeSubTab = 0; // 0 = User Subscriptions, 1 = Subscription Tiers

  AdminUserResponse? _selectedUser;
  String? _selectedUserId;
  String _selectedTier = 'free';
  String _selectedStatus = 'active';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUsersProvider.notifier).loadUsers();
      ref.read(adminTiersProvider.notifier).loadTiers(includeRetired: true);
      ref.read(adminRolesProvider.notifier).loadRoles(size: 100);
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
        _selectedTier = user.subscription?.tier.toLowerCase() ?? 'free';
        _selectedStatus = user.subscription?.status.toLowerCase() ?? 'active';
      }
    });
  }

  void _selectUserFromTable(AdminUserResponse user) {
    _selectUser(user);
    if (_formKey.currentContext != null) {
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-Tab Segmented Selector
          _buildSegmentedHeader(),
          const SizedBox(height: 24),

          if (_activeSubTab == 0)
            _buildUserSubscriptionsView()
          else
            _buildTierPlansCrudView(),
        ],
      ),
    );
  }

  // ─── Header & Segmented Tabs ─────────────────────────────────────────

  Widget _buildSegmentedHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSegmentButton(
          tabIndex: 0,
          label: 'User Subscriptions',
          icon: Icons.people_alt_outlined,
        ),
        const SizedBox(width: 12),
        _buildSegmentButton(
          tabIndex: 1,
          label: 'Subscription Tiers (Plans)',
          icon: Icons.loyalty_outlined,
        ),
      ],
    );
  }

  Widget _buildSegmentButton({
    required int tabIndex,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _activeSubTab == tabIndex;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      opaque: true,
      child: InkWell(
        onTap: () {
          setState(() => _activeSubTab = tabIndex);
        },
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.purple.withValues(alpha: 0.18)
                : (context.isDarkMode ? const Color(0x0DFFFFFF) : const Color(0x0A000000)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.purple : context.appColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.purpleLight : context.appColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.subtitle2.copyWith(
                  color: isSelected ? context.appColors.textPrimary : context.appColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TAB 0: USER SUBSCRIPTIONS ───────────────────────────────────────

  Widget _buildUserSubscriptionsView() {
    final usersState = ref.watch(adminUsersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Subscription Directory',
          style: AppTextStyles.h4.copyWith(color: context.appColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'View and manage user subscription tiers with automatic role synchronization',
          style: AppTextStyles.body2.copyWith(color: context.appColors.textSecondary),
        ),
        const SizedBox(height: 24),

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
          color: context.appColors.border,
        ),
        const SizedBox(height: 24),

        // Tier Update Section
        Text(
          'Upgrade / Change User Subscription Tier',
          style: AppTextStyles.h4.copyWith(color: context.appColors.textPrimary),
        ),
        const SizedBox(height: 16),
        if (usersState.data != null)
          _buildTierUpdateForm(usersState.data!.items),
      ],
    );
  }

  Widget _buildSubscriptionTable(AdminUsersState state) {
    final users = state.data!.items;
    return AdminDataTable(
      columns: const [
        'Name',
        'Email',
        'Current Tier',
        'Status',
        'Assigned Roles',
        'Actions',
      ],
      columnWidths: const [1.5, 2.0, 1.0, 1.0, 2.0, 1.0],
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
        final rolesStr = u.roles
            .where((r) => !r.retired)
            .map((r) => r.name)
            .join(', ');
        return [
          Text(
            '${u.firstName} ${u.lastName}',
            style: AppTextStyles.body2.copyWith(color: context.appColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            u.email,
            style: AppTextStyles.caption.copyWith(
              color: context.appColors.textSecondary,
            ),
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
                color: status == 'active'
                    ? AppColors.accentGreen
                    : AppColors.accentAmber,
              ),
            ),
          ),
          Text(
            rolesStr.isEmpty ? 'None' : rolesStr,
            style: AppTextStyles.caption.copyWith(
              color: context.appColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Center(
            child: Tooltip(
              message: 'Upgrade / Change Tier',
              child: InkWell(
                onTap: () => _selectUserFromTable(u),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_calendar_rounded,
                        size: 14,
                        color: AppColors.purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Change',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildTierUpdateForm(List<AdminUserResponse> users) {
    final tiersState = ref.watch(adminTiersProvider);
    final activeTiers = tiersState.tiers.where((t) => !t.retired).toList();

    // Prepare dropdown items with safety fallback
    final List<DropdownMenuItem<String>> tierMenuItems;
    if (activeTiers.isNotEmpty) {
      tierMenuItems = activeTiers.map((t) {
        return DropdownMenuItem<String>(
          value: t.slug,
          child: Text('${t.name} (${t.slug.toUpperCase()})'),
        );
      }).toList();
      if (!tierMenuItems.any((item) => item.value == _selectedTier)) {
        tierMenuItems.add(
          DropdownMenuItem<String>(
            value: _selectedTier,
            child: Text('${_selectedTier.toUpperCase()} (Current/Custom)'),
          ),
        );
      }
    } else {
      // No active tiers loaded — show current selection only as a fallback.
      tierMenuItems = [
        DropdownMenuItem<String>(
          value: _selectedTier,
          child: Text('${_selectedTier.toUpperCase()} (No tiers loaded)'),
        ),
      ];
    }

    return Container(
      key: _formKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select User:',
            style: AppTextStyles.label.copyWith(color: context.appColors.textSecondary),
          ),
          const SizedBox(height: 8),

          SearchableUserDropdown(
            users: users,
            selectedUser: _selectedUser,
            onUserSelected: _selectUser,
          ),
          const SizedBox(height: 16),

          if (_selectedUser != null) ...[
            _buildSelectedUserDetails(_selectedUser!),
            const SizedBox(height: 20),

            Row(
              children: [
                // Dynamic Tier Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Subscription Tier:',
                        style: AppTextStyles.label.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: (context.isDarkMode ? const Color(0x0DFFFFFF) : const Color(0x0A000000)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.appColors.border),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedTier,
                          isExpanded: true,
                          dropdownColor: context.appColors.popoverBackground,
                          underline: const SizedBox.shrink(),
                          style: AppTextStyles.body2.copyWith(
                            color: context.appColors.textPrimary,
                          ),
                          items: tierMenuItems,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedTier = value);
                            }
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
                        style: AppTextStyles.label.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: (context.isDarkMode ? const Color(0x0DFFFFFF) : const Color(0x0A000000)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.appColors.border),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          dropdownColor: context.appColors.popoverBackground,
                          underline: const SizedBox.shrink(),
                          style: AppTextStyles.body2.copyWith(
                            color: context.appColors.textPrimary,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'canceled', child: Text('Canceled')),
                            DropdownMenuItem(value: 'expired', child: Text('Expired')),
                            DropdownMenuItem(value: 'past_due', child: Text('Past Due')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedStatus = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GradientButton(
              height: 48,
              isLoading: _isUpdating,
              icon: Icons.sync,
              iconFirst: true,
              text: 'Apply Tier Change & Sync Role',
              onPressed: () => _confirmAndApplyTierChange(users),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedUserDetails(AdminUserResponse user) {
    final initials =
        '${user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : ''}${user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : ''}';
    final tier = user.subscription?.tier ?? 'free';
    final status = user.subscription?.status ?? 'active';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border.withValues(alpha: 0.6)),
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
                        style: AppTextStyles.subtitle2.copyWith(
                          color: context.appColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == 'active'
                            ? AppColors.accentGreen.withValues(alpha: 0.15)
                            : AppColors.accentAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: status == 'active'
                              ? AppColors.accentGreen
                              : AppColors.accentAmber,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CURRENT TIER',
                style: AppTextStyles.caption.copyWith(
                  color: context.appColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              TierBadge(tier: tier),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndApplyTierChange(List<AdminUserResponse> users) async {
    final user =
        _selectedUser ?? users.firstWhere((u) => u.id == _selectedUserId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.popoverBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Tier Change',
          style: AppTextStyles.subtitle1.copyWith(color: context.appColors.textPrimary),
        ),
        content: Text(
          'Change ${user.firstName} ${user.lastName}\'s subscription to ${_selectedTier.toUpperCase()} ($_selectedStatus)?\n\nThis will automatically synchronize their database roles and grant corresponding privileges.',
          style: AppTextStyles.body2.copyWith(color: context.appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: context.appColors.textSecondary),
            ),
          ),
          GradientButton(
            height: 38,
            text: 'Apply',
            onPressed: () => Navigator.of(ctx).pop(true),
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
      await service.updateSubscriptionTier(user.id, request);
      await ref.read(adminUsersProvider.notifier).loadUsers();
      await ref.read(adminTiersProvider.notifier).loadTiers(includeRetired: true);

      final updatedUsers = ref.read(adminUsersProvider).data?.items ?? [];
      final match = updatedUsers.where((u) => u.id == user.id);
      if (match.isNotEmpty) {
        setState(() {
          _selectedUser = match.first;
          _selectedTier =
              match.first.subscription?.tier.toLowerCase() ?? _selectedTier;
          _selectedStatus =
              match.first.subscription?.status.toLowerCase() ?? _selectedStatus;
        });
      }

      if (mounted) {
        CenterToast.showSuccess(
          context,
          'Updated ${user.email} to ${_selectedTier.toUpperCase()}. Roles & privileges synchronized!',
          title: 'Subscription Updated',
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
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // ─── TAB 1: SUBSCRIPTION TIERS (PLANS CRUD) ──────────────────────────

  Widget _buildTierPlansCrudView() {
    final tiersState = ref.watch(adminTiersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Plans & Tiers',
                  style: AppTextStyles.h4.copyWith(color: context.appColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create custom commercial plans, configure pricing and limits, and bind to database roles.',
                  style: AppTextStyles.body2.copyWith(color: context.appColors.textSecondary),
                ),
              ],
            ),
            GradientButton(
              height: 42,
              icon: Icons.add_circle_outline_rounded,
              iconFirst: true,
              text: '+ Create New Tier',
              onPressed: () => _showCreateTierDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (tiersState.isLoading && tiersState.tiers.isEmpty)
          const ShimmerLoading(child: ShimmerBox(height: 300))
        else if (tiersState.error != null)
          _buildErrorCard(tiersState.error!)
        else if (tiersState.tiers.isEmpty)
          _buildEmptyTiersCard()
        else
          _buildTiersTable(tiersState.tiers),
      ],
    );
  }

  Widget _buildTiersTable(List<SubscriptionTierModel> tiers) {
    return AdminDataTable(
      columns: const [
        'Tier Name',
        'Slug',
        'Bound Role',
        'Price (Mo / Yr)',
        'Sessions Quota',
        'Follow-ups',
        'YouTube',
        'Streak XP',
        'Subscribers',
        'Actions',
      ],
      columnWidths: const [1.8, 1.0, 1.4, 1.3, 1.2, 1.1, 1.0, 1.0, 1.0, 1.3],
      rows: tiers.map<List<Widget>>((t) {
        return [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.name,
                style: AppTextStyles.body2.copyWith(
                  color: context.appColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (t.description != null && t.description!.isNotEmpty)
                Text(
                  t.description!,
                  style: AppTextStyles.caption.copyWith(color: context.appColors.textSecondary, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
          TierBadge(tier: t.slug),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
            ),
            child: Text(
              t.roleName ?? 'None',
              style: AppTextStyles.badge.copyWith(color: AppColors.purpleLight),
            ),
          ),
          Text(
            '\$${t.priceMonthly.toInt()} / \$${t.priceAnnual.toInt()}',
            style: AppTextStyles.body2.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold),
          ),
          _buildLimitChip(
            isUnlimited: t.isUnlimitedSessions,
            limitText: '${t.monthlySessionLimit ?? 0}/mo',
          ),
          _buildLimitChip(
            isUnlimited: t.isUnlimitedFollowUps,
            limitText: '${t.followUpLimitPerStep ?? 0}/step',
          ),
          _buildLimitChip(
            isUnlimited: t.isUnlimitedYoutube,
            limitText: '${t.youtubeLimitPerStep ?? 0}/step',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${t.streakMultiplier}x',
              style: AppTextStyles.caption.copyWith(color: AppColors.accentAmber, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '${t.activeSubscribersCount} users',
            style: AppTextStyles.caption.copyWith(color: context.appColors.textSecondary),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.purpleLight),
                tooltip: 'Edit Tier',
                onPressed: () => _showEditTierDialog(context, t),
              ),
              if (t.slug != 'free')
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.rose),
                  tooltip: 'Retire Tier',
                  onPressed: () => _confirmRetireTier(context, t),
                ),
            ],
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildLimitChip({required bool isUnlimited, required String limitText}) {
    if (isUnlimited) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.accentGreen.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Unlimited',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.accentGreen,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );
    }
    return Text(
      limitText,
      style: AppTextStyles.caption.copyWith(color: context.appColors.textSecondary),
    );
  }

  Widget _buildEmptyTiersCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (context.isDarkMode ? const Color(0x0DFFFFFF) : const Color(0x0A000000)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.loyalty_outlined, size: 48, color: context.appColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No Subscription Tiers Found',
            style: AppTextStyles.subtitle1.copyWith(color: context.appColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Click "+ Create New Tier" to define your first subscription plan.',
            style: AppTextStyles.body2.copyWith(color: context.appColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─── TIER CREATION & EDIT DIALOGS ────────────────────────────────────

  void _showCreateTierDialog(BuildContext context) {
    _showTierFormDialog(context: context);
  }

  void _showEditTierDialog(BuildContext context, SubscriptionTierModel tier) {
    _showTierFormDialog(context: context, existingTier: tier);
  }

  void _showTierFormDialog({
    required BuildContext context,
    SubscriptionTierModel? existingTier,
  }) {
    final bool isEdit = existingTier != null;
    final nameCtrl = TextEditingController(text: existingTier?.name ?? '');
    final slugCtrl = TextEditingController(text: existingTier?.slug ?? '');
    final descCtrl = TextEditingController(text: existingTier?.description ?? '');
    final priceMoCtrl = TextEditingController(text: existingTier?.priceMonthly.toString() ?? '19.0');
    final priceYrCtrl = TextEditingController(text: existingTier?.priceAnnual.toString() ?? '180.0');

    bool unlimitedSessions = existingTier?.isUnlimitedSessions ?? false;
    final sessionsCtrl = TextEditingController(
      text: existingTier?.monthlySessionLimit?.toString() ?? '25',
    );

    bool unlimitedFollowups = existingTier?.isUnlimitedFollowUps ?? false;
    final followupsCtrl = TextEditingController(
      text: existingTier?.followUpLimitPerStep?.toString() ?? '5',
    );

    bool unlimitedYoutube = existingTier?.isUnlimitedYoutube ?? false;
    final youtubeCtrl = TextEditingController(
      text: existingTier?.youtubeLimitPerStep?.toString() ?? '3',
    );

    final streakMultiplierCtrl = TextEditingController(
      text: existingTier?.streakMultiplier.toString() ?? '1.0',
    );

    bool isPublic = existingTier?.isPublic ?? true;

    final rolesState = ref.read(adminRolesProvider);
    final activeRoles = rolesState.data?.items.where((r) => !r.retired).toList() ?? [];
    String selectedRoleId = existingTier?.roleId ?? (activeRoles.isNotEmpty ? activeRoles.first.id : '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            backgroundColor: context.appColors.popoverBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 580,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Edit Subscription Tier' : 'Create New Subscription Tier',
                          style: AppTextStyles.subtitle1.copyWith(
                            color: context.appColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.appColors.textSecondary),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tier Name & Slug
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogTextField(
                            label: 'Tier Name',
                            controller: nameCtrl,
                            hint: 'e.g. Researcher Pro',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDialogTextField(
                            label: 'Slug Identifier',
                            controller: slugCtrl,
                            hint: 'e.g. researcher-pro',
                            enabled: !isEdit,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Bound Role Dropdown
                    Text('Bound Database Role (Grants Privileges):', style: AppTextStyles.caption.copyWith(color: context.appColors.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: (context.isDarkMode ? const Color(0x0DFFFFFF) : const Color(0x0A000000)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.appColors.border),
                      ),
                      child: DropdownButton<String>(
                        value: selectedRoleId.isNotEmpty && activeRoles.any((r) => r.id == selectedRoleId)
                            ? selectedRoleId
                            : (activeRoles.isNotEmpty ? activeRoles.first.id : null),
                        isExpanded: true,
                        dropdownColor: context.appColors.popoverBackground,
                        underline: const SizedBox.shrink(),
                        style: AppTextStyles.body2.copyWith(color: context.appColors.textPrimary),
                        items: activeRoles.map((r) {
                          return DropdownMenuItem(
                            value: r.id,
                            child: Text('${r.name} (${r.privileges.length} privileges)'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedRoleId = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Pricing
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogTextField(
                            label: 'Monthly Price (\$)',
                            controller: priceMoCtrl,
                            hint: '0.0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDialogTextField(
                            label: 'Annual Price (\$)',
                            controller: priceYrCtrl,
                            hint: '0.0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quota Limits Section
                    Text('Entitlements & Feature Limits:', style: AppTextStyles.label.copyWith(color: AppColors.purpleLight)),
                    const SizedBox(height: 10),

                    // Monthly Session Quota
                    _buildQuotaRow(
                      label: 'Monthly Sessions',
                      isUnlimited: unlimitedSessions,
                      controller: sessionsCtrl,
                      onToggle: (val) => setDialogState(() => unlimitedSessions = val),
                    ),
                    const SizedBox(height: 10),

                    // Follow-ups Quota
                    _buildQuotaRow(
                      label: 'Follow-ups / Step',
                      isUnlimited: unlimitedFollowups,
                      controller: followupsCtrl,
                      onToggle: (val) => setDialogState(() => unlimitedFollowups = val),
                    ),
                    const SizedBox(height: 10),

                    // YouTube Videos Quota
                    _buildQuotaRow(
                      label: 'YouTube Videos / Step',
                      isUnlimited: unlimitedYoutube,
                      controller: youtubeCtrl,
                      onToggle: (val) => setDialogState(() => unlimitedYoutube = val),
                    ),
                    const SizedBox(height: 14),

                    // Daily Streak Multiplier
                    _buildDialogTextField(
                      label: 'Daily Streak XP Multiplier (e.g. 1.0, 1.5, 2.0)',
                      controller: streakMultiplierCtrl,
                      hint: '1.0',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 14),

                    // Public Catalog Switch
                    Row(
                      children: [
                        Switch(
                          value: isPublic,
                          activeThumbColor: AppColors.purpleLight,
                          onChanged: (val) => setDialogState(() => isPublic = val),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Show on Public Pricing Page',
                          style: AppTextStyles.body2.copyWith(color: context.appColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Cancel', style: AppTextStyles.button.copyWith(color: context.appColors.textSecondary)),
                        ),
                        const SizedBox(width: 12),
                        GradientButton(
                          height: 42,
                          text: isEdit ? 'Save Changes' : 'Create Tier',
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            final slug = slugCtrl.text.trim().toLowerCase();
                            if (name.isEmpty || slug.isEmpty || selectedRoleId.isEmpty) {
                              CenterToast.showWarning(context, 'Name, Slug, and Bound Role are required.');
                              return;
                            }

                            final payload = {
                              'name': name,
                              'slug': slug,
                              'description': descCtrl.text.trim(),
                              'role_id': selectedRoleId,
                              'price_monthly': double.tryParse(priceMoCtrl.text.trim()) ?? 0.0,
                              'price_annual': double.tryParse(priceYrCtrl.text.trim()) ?? 0.0,
                              'currency': 'USD',
                              'monthly_session_limit': unlimitedSessions ? null : int.tryParse(sessionsCtrl.text.trim()),
                              'follow_up_limit_per_step': unlimitedFollowups ? null : int.tryParse(followupsCtrl.text.trim()),
                              'youtube_limit_per_step': unlimitedYoutube ? null : int.tryParse(youtubeCtrl.text.trim()),
                              'streak_multiplier': double.tryParse(streakMultiplierCtrl.text.trim()) ?? 1.0,
                              'is_public': isPublic,
                            };

                            bool success;
                            if (isEdit) {
                              success = await ref.read(adminTiersProvider.notifier).updateTier(existingTier.id, payload);
                            } else {
                              success = await ref.read(adminTiersProvider.notifier).createTier(payload);
                            }

                            if (success && ctx.mounted) {
                              Navigator.of(ctx).pop();
                              CenterToast.showSuccess(
                                context,
                                isEdit ? "Tier '$name' updated." : "Tier '$name' created successfully.",
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: context.appColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTextStyles.body2.copyWith(color: enabled ? context.appColors.textPrimary : context.appColors.textSecondary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.caption.copyWith(color: context.appColors.textSecondary),
            filled: true,
            fillColor: (context.isDarkMode ? const Color(0x0DFFFFFF) : const Color(0x0A000000)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.appColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.appColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotaRow({
    required String label,
    required bool isUnlimited,
    required TextEditingController controller,
    required ValueChanged<bool> onToggle,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(label, style: AppTextStyles.body2.copyWith(color: context.appColors.textPrimary)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isUnlimited,
              activeColor: AppColors.accentGreen,
              onChanged: (val) => onToggle(val ?? false),
            ),
            Text('Unlimited', style: AppTextStyles.caption.copyWith(color: context.appColors.textSecondary)),
          ],
        ),
        const SizedBox(width: 14),
        if (!isUnlimited)
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.body2.copyWith(color: context.appColors.textPrimary),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                filled: true,
                fillColor: (context.isDarkMode ? const Color(0x0DFFFFFF) : const Color(0x0A000000)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        else
          Text(
            '(No limit)',
            style: AppTextStyles.caption.copyWith(color: AppColors.accentGreen, fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  Future<void> _confirmRetireTier(BuildContext context, SubscriptionTierModel tier) async {
    if (tier.priceMonthly <= 0 && tier.priceAnnual <= 0) {
      CenterToast.showWarning(context, "The default free tier '${tier.name}' cannot be retired.");
      return;
    }

    if (tier.activeSubscribersCount > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.appColors.popoverBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Cannot Retire Tier', style: AppTextStyles.subtitle1.copyWith(color: AppColors.rose)),
          content: Text(
            "There are currently ${tier.activeSubscribersCount} active subscribers on '${tier.name}'. Please reassign them to another tier in User Subscriptions before retiring.",
            style: AppTextStyles.body2.copyWith(color: context.appColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK', style: AppTextStyles.button.copyWith(color: context.appColors.textPrimary)),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.popoverBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Retire Tier', style: AppTextStyles.subtitle1.copyWith(color: AppColors.rose)),
        content: Text(
          "Are you sure you want to retire tier '${tier.name}' (${tier.slug})? It will no longer be visible or purchasable.",
          style: AppTextStyles.body2.copyWith(color: context.appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: context.appColors.textSecondary)),
          ),
          GradientButton(
            height: 38,
            text: 'Retire Tier',
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(adminTiersProvider.notifier).retireTier(tier.id);
      if (success && context.mounted) {
        CenterToast.showSuccess(context, "Tier '${tier.name}' retired.");
      }
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
            onPressed: () {
              ref.read(adminUsersProvider.notifier).loadUsers();
              ref.read(adminTiersProvider.notifier).loadTiers(includeRetired: true);
            },
            child: Text(
              'Retry',
              style: AppTextStyles.button.copyWith(color: AppColors.rose),
            ),
          ),
        ],
      ),
    );
  }
}
