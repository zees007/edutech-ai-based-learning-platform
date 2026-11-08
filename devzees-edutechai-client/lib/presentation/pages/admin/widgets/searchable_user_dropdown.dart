import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/admin/user_response.dart';
import 'tier_badge.dart';

/// Searchable user dropdown component for Admin management.
/// Displays an interactive trigger field with current user details,
/// and opens a searchable popover overlay for instant filtering across users.
class SearchableUserDropdown extends StatefulWidget {
  final List<AdminUserResponse> users;
  final AdminUserResponse? selectedUser;
  final ValueChanged<AdminUserResponse?> onUserSelected;
  final String hintText;
  final Future<List<AdminUserResponse>> Function(String query)? onSearchRemote;
  final bool isEnabled;

  const SearchableUserDropdown({
    super.key,
    required this.users,
    required this.selectedUser,
    required this.onUserSelected,
    this.hintText = 'Search and select a user to manage roles...',
    this.onSearchRemote,
    this.isEnabled = true,
  });

  @override
  State<SearchableUserDropdown> createState() => _SearchableUserDropdownState();
}

class _SearchableUserDropdownState extends State<SearchableUserDropdown> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<AdminUserResponse> _filteredUsers = [];
  bool _isRemoteSearching = false;
  Timer? _debounceTimer;

  // Callback to trigger re-renders inside the overlay's StatefulBuilder
  void Function(void Function())? _overlaySetState;

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(widget.users);
  }

  @override
  void didUpdateWidget(covariant SearchableUserDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.users != oldWidget.users && _searchController.text.trim().isEmpty) {
      _filteredUsers = List.from(widget.users);
      _overlaySetState?.call(() {});
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.isEnabled) return;
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _filteredUsers = List.from(widget.users);
    _searchController.clear();
    _isOpen = true;

    final overlay = Overlay.of(context);
    final renderBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final triggerSize = renderBox.size;
    final triggerOffset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - (triggerOffset.dy + triggerSize.height);
    final openUpwards = spaceBelow < 300 && triggerOffset.dy > 300;

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            // Full-screen backdrop to dismiss on click outside
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
              ),
            ),
            // Positioned popover attached to trigger
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(
                0,
                openUpwards ? -350 : triggerSize.height + 6,
              ),
              child: Material(
                color: Colors.transparent,
                child: StatefulBuilder(
                  builder: (context, setOverlayState) {
                    _overlaySetState = setOverlayState;

                    return Container(
                      width: triggerSize.width,
                      constraints: const BoxConstraints(
                        maxHeight: 340,
                        minHeight: 120,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.popoverBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.purple.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.55),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Search Header
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDeep.withValues(alpha: 0.8),
                                border: Border(
                                  bottom: BorderSide(color: AppColors.glassBorder),
                                ),
                              ),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.glassBase,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  autofocus: true,
                                  style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                                  onChanged: (text) => _onSearchQueryChanged(text, setOverlayState),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Search by name, email, or mobile...',
                                    hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.purple),
                                    suffixIcon: _isRemoteSearching
                                        ? const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.purple,
                                              ),
                                            ),
                                          )
                                        : _searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  _onSearchQueryChanged('', setOverlayState);
                                                },
                                              )
                                            : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ),

                            // Filtered User List
                            Flexible(
                              child: _filteredUsers.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.person_search_outlined,
                                            size: 36,
                                            color: AppColors.textMuted.withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _searchController.text.isNotEmpty
                                                ? 'No users match "${_searchController.text.trim()}"'
                                                : 'No users found',
                                            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Try searching by first name, last name, or email',
                                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      shrinkWrap: true,
                                      itemCount: _filteredUsers.length,
                                      separatorBuilder: (context, index) => Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: AppColors.glassBorder.withValues(alpha: 0.3),
                                      ),
                                      itemBuilder: (context, index) {
                                        final user = _filteredUsers[index];
                                        final isSelected = widget.selectedUser?.id == user.id;

                                        return _UserTile(
                                          user: user,
                                          isSelected: isSelected,
                                          onTap: () {
                                            widget.onUserSelected(user);
                                            _closeDropdown();
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() {});
  }

  void _onSearchQueryChanged(String text, void Function(void Function()) setOverlayState) {
    final query = text.trim().toLowerCase();

    // Instant local filtering
    if (query.isEmpty) {
      _filteredUsers = List.from(widget.users);
    } else {
      _filteredUsers = widget.users.where((u) {
        final fullName = '${u.firstName} ${u.lastName}'.toLowerCase();
        final email = u.email.toLowerCase();
        final mobile = u.mobile?.toLowerCase() ?? '';
        return fullName.contains(query) || email.contains(query) || mobile.contains(query);
      }).toList();
    }
    setOverlayState(() {});

    // Remote query debounce if enabled
    if (widget.onSearchRemote != null && query.isNotEmpty) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
        setOverlayState(() => _isRemoteSearching = true);
        try {
          final remoteResults = await widget.onSearchRemote!(query);
          if (!mounted) return;
          final existingIds = _filteredUsers.map((u) => u.id).toSet();
          for (final r in remoteResults) {
            if (!existingIds.contains(r.id)) {
              _filteredUsers.add(r);
              existingIds.add(r.id);
            }
          }
        } catch (_) {
          // Keep local results
        } finally {
          if (mounted) {
            setOverlayState(() => _isRemoteSearching = false);
          }
        }
      });
    }
  }

  void _closeDropdown() {
    _removeOverlay();
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _removeOverlay() {
    _overlaySetState = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.selectedUser;

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: widget.isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          key: _triggerKey,
          onTap: _toggleDropdown,
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.glassBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isOpen ? AppColors.purple : AppColors.glassBorder,
                width: _isOpen ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                if (user == null) ...[
                  Icon(
                    Icons.person_search_outlined,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.hintText,
                      style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  // User Initials Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.purple.withValues(alpha: 0.25),
                    child: Text(
                      _getInitials(user),
                      style: AppTextStyles.captionBold.copyWith(
                        color: AppColors.purple,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Email
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
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user.roles.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.purple.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  user.roles.where((r) => !r.retired).map((r) => r.name).join(', '),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.purple,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          user.email,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Clear Button
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: AppColors.textMuted,
                    hoverColor: AppColors.rose.withValues(alpha: 0.2),
                    tooltip: 'Deselect user',
                    onPressed: () {
                      widget.onUserSelected(null);
                    },
                  ),
                ],
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: _isOpen ? AppColors.purple : AppColors.textMuted,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(AdminUserResponse user) {
    final first = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : '';
    if (first.isEmpty && last.isEmpty) return 'U';
    return '$first$last';
  }
}

class _UserTile extends StatefulWidget {
  final AdminUserResponse user;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final rolesStr = u.roles.where((r) => !r.retired).map((r) => r.name).join(', ');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.purple.withValues(alpha: 0.18)
                : _isHovered
                    ? AppColors.surfaceSubtle.withValues(alpha: 0.2)
                    : Colors.transparent,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.isSelected
                    ? AppColors.purple
                    : AppColors.purple.withValues(alpha: 0.2),
                child: Text(
                  '${u.firstName.isNotEmpty ? u.firstName[0].toUpperCase() : ''}${u.lastName.isNotEmpty ? u.lastName[0].toUpperCase() : ''}',
                  style: AppTextStyles.captionBold.copyWith(
                    color: widget.isSelected ? Colors.white : AppColors.purple,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${u.firstName} ${u.lastName}',
                            style: AppTextStyles.body2.copyWith(
                              color: widget.isSelected ? AppColors.purple : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TierBadge(tier: u.subscription?.tier ?? 'free'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      u.email,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (rolesStr.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Roles: $rolesStr',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.purple,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
