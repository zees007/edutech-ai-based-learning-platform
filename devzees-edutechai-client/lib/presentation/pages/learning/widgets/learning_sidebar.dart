import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/widgets/gradient_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/learning_provider.dart';
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
          if (widget.expanded && !_isHistoryExpanded)
            const Spacer()
          else
            Expanded(
              child: LearningHistoryList(
                scrollController: widget.scrollController,
                expanded: widget.expanded,
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
              onPressed: () {},
              height: 48,
            )
          : InkWell(
              onTap: () {},
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
              const Text(
                'Learning History',
                style: TextStyle(
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
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
