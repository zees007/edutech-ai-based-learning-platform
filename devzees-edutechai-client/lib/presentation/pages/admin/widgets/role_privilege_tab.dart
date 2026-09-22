import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/admin/privilege_response.dart';
import '../../../../data/models/admin/role_create_request.dart';
import '../../../widgets/shimmer_loading.dart';
import 'admin_data_table.dart';

/// Role & Privilege Matrix tab.
class RolePrivilegeTab extends ConsumerStatefulWidget {
  const RolePrivilegeTab({super.key});

  @override
  ConsumerState<RolePrivilegeTab> createState() => _RolePrivilegeTabState();
}

class _RolePrivilegeTabState extends ConsumerState<RolePrivilegeTab> {
  final _roleNameController = TextEditingController();
  List<int> _selectedPrivilegeIds = [];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminRolesProvider.notifier).loadRoles();
    });
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rolesState = ref.watch(adminRolesProvider);
    final privilegesAsync = ref.watch(adminPrivilegesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role & Privilege Management',
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Create roles, assign privileges, and view the system privilege matrix',
            style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          // Roles Table
          _buildRolesTable(rolesState),
          const SizedBox(height: 32),
          // Create Role Form
          _buildCreateRoleForm(privilegesAsync),

          const SizedBox(height: 32),

          // All Privileges Section
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.glassBorder,
          ),
          const SizedBox(height: 24),
          Text(
            'All Available Privilege Codes',
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildPrivilegesTable(privilegesAsync),
        ],
      ),
    );
  }

  Widget _buildRolesTable(AdminRolesState rolesState) {
    if (rolesState.isLoading && rolesState.data == null) {
      return const ShimmerLoading(child: ShimmerBox(height: 200));
    }
    if (rolesState.error != null) {
      return _buildErrorCard(rolesState.error!, () {
        ref.read(adminRolesProvider.notifier).loadRoles();
      });
    }

    final roles = rolesState.data?.items ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Roles Overview',
          style: AppTextStyles.subtitle1.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        AdminDataTable(
          columns: const ['Role Name', 'Privileges', 'Assigned Privileges', 'Created'],
          columnWidths: const [1.2, 2.8, 2.8, 1.0],
          sortBy: rolesState.sortBy,
          isDesc: rolesState.isDesc,
          onSort: (colName) {
            String field = colName.toLowerCase();
            if (colName == 'Role Name') field = 'name';
            if (colName == 'Created') field = 'created_at';
            ref.read(adminRolesProvider.notifier).setSort(field);
          },
          currentPage: rolesState.page,
          totalPages: rolesState.data!.totalPages,
          onPageChanged: (newPage) {
            ref.read(adminRolesProvider.notifier).setPage(newPage);
          },
          rows: roles.map<List<Widget>>((r) {
            final privNames = r.privileges.isNotEmpty
                ? r.privileges.map((p) => p.name).join(', ')
                : 'No Privileges';
            return [
              Text(
                r.name,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _PrivilegeExpandableCell(privileges: r.privileges),
              Text(
                privNames,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                _formatDate(r.createdAt),
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
            ];
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCreateRoleForm(AsyncValue<List<PrivilegeResponse>> privilegesAsync) {
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
          Text(
            'Create New Role',
            style: AppTextStyles.subtitle1.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          // Role Name
          Text(
            'Role Name *',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _roleNameController,
            style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Content Editor',
              hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.glassBase,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Privilege Selection
          Text(
            'Assign Privileges:',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          privilegesAsync.when(
            data: (privileges) => Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: privileges.map((p) {
                    final isSelected = _selectedPrivilegeIds.contains(p.id);
                    return FilterChip(
                      label: Text(p.code, style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPrivilegeIds.add(p.id);
                          } else {
                            _selectedPrivilegeIds.remove(p.id);
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
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ),
            ),
            loading: () => const ShimmerLoading(child: ShimmerBox(height: 80)),
            error: (err, _) => Text(
              'Failed to load privileges',
              style: AppTextStyles.caption.copyWith(color: AppColors.rose),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _createRole,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Create Role', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegesTable(AsyncValue<List<PrivilegeResponse>> privilegesAsync) {
    return privilegesAsync.when(
      data: (privileges) => AdminDataTable(
        columns: const ['ID', 'Code', 'Name', 'Order'],
        columnWidths: const [0.5, 2.0, 2.0, 0.5],
        rows: privileges.map<List<Widget>>((p) {
          return [
            Text(
              '${p.id}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
            Text(
              p.code,
              style: AppTextStyles.code.copyWith(fontSize: 12, color: AppColors.purple),
            ),
            Text(
              p.name,
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '${p.orderNumber}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ];
        }).toList(),
      ),
      loading: () => const ShimmerLoading(child: ShimmerBox(height: 200)),
      error: (err, _) => _buildErrorCard('Failed to load privileges', () {
        ref.invalidate(adminPrivilegesProvider);
      }),
    );
  }

  Future<void> _createRole() async {
    final name = _roleNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Role name is required'),
          backgroundColor: AppColors.rose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      final request = RoleCreateRequest(
        name: name,
        privilegeIds: _selectedPrivilegeIds,
      );
      await ref.read(adminRolesProvider.notifier).createRole(request);
      _roleNameController.clear();
      _selectedPrivilegeIds = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role "$name" created successfully!'),
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
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Widget _buildErrorCard(String error, VoidCallback onRetry) {
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
            onPressed: onRetry,
            child: Text('Retry', style: AppTextStyles.button.copyWith(color: AppColors.rose)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _PrivilegeExpandableCell extends StatefulWidget {
  final List<dynamic> privileges;

  const _PrivilegeExpandableCell({Key? key, required this.privileges}) : super(key: key);

  @override
  State<_PrivilegeExpandableCell> createState() => _PrivilegeExpandableCellState();
}

class _PrivilegeExpandableCellState extends State<_PrivilegeExpandableCell> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (widget.privileges.isNotEmpty) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.privileges.length}',
                  style: AppTextStyles.badge.copyWith(color: AppColors.purple),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.privileges.isNotEmpty) ...[
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.privileges.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          p.code,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentBlue,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          p.name,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
