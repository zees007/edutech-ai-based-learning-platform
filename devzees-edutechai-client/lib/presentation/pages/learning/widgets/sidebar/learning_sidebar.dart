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
  final ScrollController scrollController;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  const LearningSidebar({
    super.key,
    required this.expanded,
    required this.isMobile,
    required this.scrollController,
    required this.onToggle,
    required this.onClose,
  });

  @override
  ConsumerState<LearningSidebar> createState() => _LearningSidebarState();
}

class _LearningSidebarState extends ConsumerState<LearningSidebar> {
  bool _isHistoryExpanded = true;
  final GlobalKey _filterIconKey = GlobalKey();

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
                  scrollController: widget.scrollController,
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
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.history, color: Colors.white.withValues(alpha: 0.7)),
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

  Widget _buildNewJourneyButton({required bool expanded}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: expanded
          ? GradientButton(
              text: 'Start New Journey',
              icon: Icons.edit_square,
              iconFirst: true,
              onPressed: () {
                ref.read(activeSessionProvider.notifier).clearSession();
              },
              height: 48,
            )
          : InkWell(
              onTap: () {
                ref.read(activeSessionProvider.notifier).clearSession();
              },
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
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Icon(
                _isHistoryExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                color: Colors.white.withValues(alpha: 0.5),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  ref.read(sessionsProvider.notifier).updateSearch(value);
                },
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search topics or levels...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 36,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            key: _filterIconKey,
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.filter_list,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
              onPressed: () {
                _showFilterDialog(context, statusFilter);
              },
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

    showMenu<String>(
      context: context,
      color: Colors.transparent,
      elevation: 0,
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
                  color: const Color(0xFF1A132C).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
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
                        color: isHovered || isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: AppColors.primary, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
