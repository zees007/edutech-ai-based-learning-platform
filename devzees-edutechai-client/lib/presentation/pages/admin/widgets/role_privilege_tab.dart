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
  bool _isPrivilegesExpanded = false;

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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                        _selectedPrivilegeIds = r.privileges.map((p) => p.id).toList();
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_editingRoleId != null) ...[
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _editingRoleId = null;
                          _roleNameController.clear();
                          _selectedPrivilegeIds = [];
                        });
                      },
                      icon: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                      label: Text('Cancel Edit', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Zoom / Expand in-place icon
                  IconButton(
                    tooltip: _isPrivilegesExpanded ? 'Collapse Privileges' : 'Zoom / Expand Privileges',
                    icon: Icon(
                      _isPrivilegesExpanded ? Icons.close_fullscreen : Icons.open_in_full,
                      size: 18,
                      color: _isPrivilegesExpanded ? AppColors.accentViolet : AppColors.textSecondary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: _isPrivilegesExpanded
                          ? AppColors.accentViolet.withValues(alpha: 0.15)
                          : AppColors.glassBase,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _isPrivilegesExpanded
                              ? AppColors.accentViolet.withValues(alpha: 0.4)
                              : AppColors.glassBorder,
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPrivilegesExpanded = !_isPrivilegesExpanded;
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  // Fullscreen dialog popup
                  IconButton(
                    tooltip: 'Open in Full Dialog Window',
                    icon: const Icon(Icons.fullscreen, size: 20),
                    color: AppColors.textSecondary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.glassBase,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                    onPressed: () => _openPrivilegeDialog(privilegesAsync),
                  ),
                ],
              ),
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
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Privilege Selection
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                'Assign Privileges (${_selectedPrivilegeIds.length} selected):',
                style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
              ),
              if (privilegesAsync.hasValue)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedPrivilegeIds =
                              privilegesAsync.value!.map((p) => p.id).toList();
                        });
                      },
                      child: Text('Select All',
                          style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedPrivilegeIds = [];
                        });
                      },
                      child: Text('Clear',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          privilegesAsync.when(
            data: (privileges) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                constraints: BoxConstraints(
                  maxHeight: _isPrivilegesExpanded ? 650 : 300,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassBase,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isPrivilegesExpanded
                        ? AppColors.accentViolet.withValues(alpha: 0.5)
                        : AppColors.glassBorder,
                  ),
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

  void _openPrivilegeDialog(AsyncValue<List<PrivilegeResponse>> privilegesAsync) {
    if (!privilegesAsync.hasValue) return;
    final allPrivs = privilegesAsync.value!;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.glassBorder),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.purple, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Assign Privileges (${_selectedPrivilegeIds.length} / ${allPrivs.length})',
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width > 700
                    ? 650
                    : double.maxFinite,
                height: 520,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              setState(() {
                                _selectedPrivilegeIds = allPrivs.map((p) => p.id).toList();
                              });
                            });
                          },
                          icon: const Icon(Icons.select_all, size: 16),
                          label: const Text('Select All'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.accentBlue),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              setState(() {
                                _selectedPrivilegeIds = [];
                              });
                            });
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear All'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.glassBase,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: SingleChildScrollView(
                          child: _PrivilegeTreeView(
                            allPrivileges: allPrivs,
                            selectedIds: _selectedPrivilegeIds,
                            onChanged: (newSelections) {
                              setDialogState(() {
                                setState(() {
                                  _selectedPrivilegeIds = newSelections;
                                });
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _PrivilegeExpandableCell extends StatefulWidget {
  final List<dynamic> privileges;

  const _PrivilegeExpandableCell({required this.privileges});

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
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: widget.privileges.map((p) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.code,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (p.name != null && p.name.toString().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            p.name,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
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
    required this.allPrivileges,
    required this.selectedIds,
    required this.onChanged,
  });

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

    void toggleRecursive(int nodeId) {
      if (isSelected) {
        if (!newSelections.contains(nodeId)) newSelections.add(nodeId);
      } else {
        newSelections.remove(nodeId);
      }
      
      final children = _tree[nodeId] ?? [];
      for (final child in children) {
        toggleRecursive(child.id);
      }
    }

    toggleRecursive(id);
    widget.onChanged(newSelections);
  }

  Widget _buildNode(PrivilegeResponse node, int depth) {
    final children = _tree[node.id] ?? [];
    final isSelected = widget.selectedIds.contains(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 14.0, top: 3, bottom: 3),
          child: InkWell(
            onTap: () => _toggleSelection(node.id, !isSelected),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (val) => _toggleSelection(node.id, val),
                      activeColor: AppColors.purple,
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.purple;
                        }
                        return AppColors.isDark
                            ? AppColors.surfaceDeep
                            : Colors.white;
                      }),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.purple
                            : (AppColors.isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF94A3B8)),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          node.code,
                          style: AppTextStyles.body2.copyWith(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: children.isNotEmpty
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (node.name.isNotEmpty &&
                            node.name.toLowerCase() != node.code.toLowerCase())
                          Text(
                            node.name,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
