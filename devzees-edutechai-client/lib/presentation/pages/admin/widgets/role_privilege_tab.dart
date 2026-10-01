import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/admin/privilege_response.dart';
import '../../../../data/models/admin/role_create_request.dart';
import '../../../../data/models/admin/role_edit_request.dart';
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
  String? _editingRoleId;

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
          _buildRoleForm(privilegesAsync),

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
          columns: const ['Role Name', 'Privileges', 'Assigned Privileges', 'Created', 'Actions'],
          columnWidths: const [1.2, 2.5, 2.3, 1.0, 0.8],
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.accentBlue, size: 18),
                    onPressed: () {
                      setState(() {
                        _editingRoleId = r.id;
                        _roleNameController.text = r.name;
                        _selectedPrivilegeIds = r.privileges.map((p) => p.id as int).toList();
                      });
                    },
                    tooltip: 'Edit Role',
                  ),
                ],
              ),
            ];
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoleForm(AsyncValue<List<PrivilegeResponse>> privilegesAsync) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _editingRoleId == null ? 'Create New Role' : 'Edit Role',
                style: AppTextStyles.subtitle1.copyWith(color: AppColors.textPrimary),
              ),
              if (_editingRoleId != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _editingRoleId = null;
                      _roleNameController.clear();
                      _selectedPrivilegeIds = [];
                    });
                  },
                  icon: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                  label: Text('Cancel Edit', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                )
            ],
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
            data: (privileges) {
              return Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: AppColors.glassBase,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: _PrivilegeTreeView(
                    allPrivileges: privileges,
                    selectedIds: _selectedPrivilegeIds,
                    onChanged: (newSelections) {
                      setState(() {
                        _selectedPrivilegeIds = newSelections;
                      });
                    },
                  ),
                ),
              );
            },
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
              onPressed: _isCreating ? null : _submitRole,
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
                  : Text(_editingRoleId == null ? 'Create Role' : 'Update Role', style: AppTextStyles.button),
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

  Future<void> _submitRole() async {
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
      if (_editingRoleId == null) {
        final request = RoleCreateRequest(
          name: name,
          privilegeIds: _selectedPrivilegeIds,
        );
        await ref.read(adminRolesProvider.notifier).createRole(request);
      } else {
        final request = RoleEditRequest(
          name: name,
          privilegeIds: _selectedPrivilegeIds,
        );
        await ref.read(adminRolesProvider.notifier).editRole(_editingRoleId!, request);
      }
      
      _editingRoleId = null;
      _roleNameController.clear();
      _selectedPrivilegeIds = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role "$name" saved successfully!'),
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

class _PrivilegeTreeView extends StatefulWidget {
  final List<PrivilegeResponse> allPrivileges;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;

  const _PrivilegeTreeView({
    Key? key,
    required this.allPrivileges,
    required this.selectedIds,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<_PrivilegeTreeView> createState() => _PrivilegeTreeViewState();
}

class _PrivilegeTreeViewState extends State<_PrivilegeTreeView> {
  // Map of parentId -> list of children
  late Map<int?, List<PrivilegeResponse>> _tree;

  @override
  void initState() {
    super.initState();
    _buildTree();
  }

  @override
  void didUpdateWidget(covariant _PrivilegeTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allPrivileges != widget.allPrivileges) {
      _buildTree();
    }
  }

  void _buildTree() {
    _tree = {};
    for (final p in widget.allPrivileges) {
      if (!_tree.containsKey(p.parentId)) {
        _tree[p.parentId] = [];
      }
      _tree[p.parentId]!.add(p);
    }
  }

  void _toggleSelection(int id, bool? selected) {
    final newSelections = List<int>.from(widget.selectedIds);
    final bool isSelected = selected ?? false;

    if (isSelected) {
      if (!newSelections.contains(id)) newSelections.add(id);
    } else {
      newSelections.remove(id);
    }
    
    // Optional: if checking parent, maybe don't auto-check children if we want them granular.
    // For now, simple independent checkboxes in a tree structure.
    
    widget.onChanged(newSelections);
  }

  Widget _buildNode(PrivilegeResponse node, int depth) {
    final children = _tree[node.id] ?? [];
    final isSelected = widget.selectedIds.contains(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 24.0, top: 4, bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (val) => _toggleSelection(node.id, val),
                  activeColor: AppColors.purple,
                  side: const BorderSide(color: AppColors.glassBorder),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                node.code,
                style: AppTextStyles.body2.copyWith(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: children.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  node.name,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (children.isNotEmpty)
          ...children.map((c) => _buildNode(c, depth + 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rootNodes = _tree[null] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rootNodes.map((node) => _buildNode(node, 0)).toList(),
    );
  }
}
