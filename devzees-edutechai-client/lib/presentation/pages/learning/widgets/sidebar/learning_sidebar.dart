import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../presentation/widgets/gradient_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/providers/learning_provider.dart';
import '../../../../../core/providers/active_session_provider.dart';
import 'sidebar_header.dart';
import 'sidebar_footer.dart';
import 'learning_history_list.dart';

class LearningSidebar extends ConsumerStatefulWidget {
  final bool expanded;
  final bool isMobile;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  const LearningSidebar({
    super.key,
    required this.expanded,
    required this.isMobile,
    required this.onToggle,
    required this.onClose,
  });

  @override
  ConsumerState<LearningSidebar> createState() => _LearningSidebarState();
}

class _LearningSidebarState extends ConsumerState<LearningSidebar> {
  bool _isHistoryExpanded = true;
  final GlobalKey _filterIconKey = GlobalKey();
  late final FocusNode _searchFocusNode;
  bool _isSearchHovered = false;
  bool _isSearchFocused = false;
  bool _isFilterHovered = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  void _onSearchFocusChanged() {
    if (mounted) {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SidebarHeader(
            expanded: widget.expanded,
            isMobile: widget.isMobile,
            onToggle: widget.onToggle,
            onClose: widget.onClose,
          ),
          const SizedBox(height: 16),
          _buildNewJourneyButton(expanded: widget.expanded),
          const SizedBox(height: 24),
          if (widget.expanded) ...[
            _buildHistoryHeader(),
            if (_isHistoryExpanded) ...[
              const SizedBox(height: 16),
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
            ],
          ],
          // History List
          if (widget.expanded)
            if (!_isHistoryExpanded)
              const Spacer()
            else
              Expanded(
                child: LearningHistoryList(
                  expanded: widget.expanded,
                ),
              )
          else
            Expanded(
              child: Column(
                children: [
                  InkWell(
                    onTap: widget.onToggle,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.history,
                        color: AppColors.isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          SidebarFooter(expanded: widget.expanded),
        ],
      ),
    );
  }

  void _handleStartNewJourney() {
    ref.read(activeSessionProvider.notifier).clearSession();
    if (widget.isMobile) {
      widget.onClose();
    } else if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
      Scaffold.of(context).closeDrawer();
    }
  }

  Widget _buildNewJourneyButton({required bool expanded}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: expanded
          ? GradientButton(
              text: 'Start New Journey',
              icon: Icons.edit_square,
              iconFirst: true,
              onPressed: _handleStartNewJourney,
              height: 48,
            )
          : InkWell(
              onTap: _handleStartNewJourney,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_square, color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildHistoryHeader() {
    final total = ref.watch(sessionsProvider).total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _isHistoryExpanded = !_isHistoryExpanded;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                'Learning History ($total)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Icon(
                _isHistoryExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final statusFilter = ref.watch(sessionsProvider).statusFilter;
    final bool isDark = AppColors.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isSearchHovered = true),
              onExit: (_) => setState(() => _isSearchHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 36,
                decoration: BoxDecoration(
                  color: (_isSearchFocused || _isSearchHovered)
                      ? (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.surface)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.surfaceSubtle),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (_isSearchFocused || _isSearchHovered)
                        ? (isDark ? AppColors.primary.withValues(alpha: 0.6) : AppColors.primary)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.border),
                    width: 1,
                  ),
                  boxShadow: (_isSearchFocused || _isSearchHovered)
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  focusNode: _searchFocusNode,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) {
                    ref.read(sessionsProvider.notifier).updateSearch(value);
                  },
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search topics or levels...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: (_isSearchFocused || _isSearchHovered)
                          ? AppColors.primary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppColors.textSecondary),
                      size: 18,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 36,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          MouseRegion(
            onEnter: (_) => setState(() => _isFilterHovered = true),
            onExit: (_) => setState(() => _isFilterHovered = false),
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: 'Filter sessions',
              child: AnimatedContainer(
                key: _filterIconKey,
                duration: const Duration(milliseconds: 150),
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: (_isFilterHovered || statusFilter != 'all')
                      ? (isDark
                          ? (statusFilter != 'all'
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.08))
                          : (statusFilter != 'all'
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surface))
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.surfaceSubtle),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (_isFilterHovered || statusFilter != 'all')
                        ? (isDark
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : AppColors.primary)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.border),
                    width: 1,
                  ),
                  boxShadow: (_isFilterHovered || statusFilter != 'all')
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    hoverColor: Colors.transparent,
                    splashColor: AppColors.primary.withValues(alpha: 0.15),
                    highlightColor: Colors.transparent,
                    onTap: () {
                      _showFilterDialog(context, statusFilter);
                    },
                    child: Center(
                      child: Icon(
                        Icons.filter_list,
                        color: (statusFilter != 'all' || _isFilterHovered)
                            ? AppColors.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppColors.textSecondary),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, String currentFilter) {
    final RenderBox renderBox = _filterIconKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final bool isDark = AppColors.isDark;

    showMenu<String>(
      context: context,
      color: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide.none,
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        MediaQuery.of(context).size.width - offset.dx - size.width,
        0,
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 140,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.popoverBackground.withValues(alpha: 0.8)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : const Color(0x14000000),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogItem(context, 'all', 'All', currentFilter),
                    _buildDialogItem(context, 'in_progress', 'Active', currentFilter),
                    _buildDialogItem(context, 'completed', 'Completed', currentFilter),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogItem(BuildContext context, String value, String label, String currentFilter) {
    final isSelected = value == currentFilter;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: InkWell(
            onTap: () {
              ref.read(sessionsProvider.notifier).updateFilter(value);
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : isHovered
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : (isHovered ? AppColors.textPrimary : AppColors.textSecondary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, color: AppColors.primary, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
