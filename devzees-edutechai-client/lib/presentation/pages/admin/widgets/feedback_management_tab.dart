import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../core/providers/feedback_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/feedback/feedback_model.dart';
import '../../../widgets/center_toast.dart';
import '../../../widgets/gradient_button.dart';
import '../../../widgets/shimmer_loading.dart';
import 'admin_data_table.dart';

/// Admin Tab for moderating student feedback, selecting featured homepage testimonials,
/// and recording internal administrative moderation notes.
class FeedbackManagementTab extends ConsumerStatefulWidget {
  const FeedbackManagementTab({super.key});

  @override
  ConsumerState<FeedbackManagementTab> createState() =>
      _FeedbackManagementTabState();
}

class _FeedbackManagementTabState extends ConsumerState<FeedbackManagementTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminFeedbackProvider.notifier).loadFeedbacks(status: 'pending');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    ref
        .read(adminFeedbackProvider.notifier)
        .loadFeedbacks(
          status: status,
          query: _searchController.text.trim(),
          page: 0,
        );
  }

  void _onSearchSubmitted(String query) {
    ref
        .read(adminFeedbackProvider.notifier)
        .loadFeedbacks(status: _selectedStatus, query: query.trim(), page: 0);
  }

  void _clearSearch() {
    _searchController.clear();
    ref
        .read(adminFeedbackProvider.notifier)
        .loadFeedbacks(status: _selectedStatus, query: '', page: 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminFeedbackProvider);
    final metrics = state.metrics;
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'Feedback & Testimonials Moderation',
            style: (isMobile ? AppTextStyles.subtitle1 : AppTextStyles.h4).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review feedback submitted by learners upon session completion, manage homepage featured testimonials, and maintain internal notes.',
            style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // KPI Cards
          _buildMetricsRow(metrics, isMobile),
          SizedBox(height: isMobile ? 20 : 32),

          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.glassBorder,
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // Filter bar & Search box
          _buildFilterAndSearchRow(state, isMobile),
          const SizedBox(height: 12),

          // Background re-fetch subtle indicator
          if (state.isLoading && state.items.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(2)),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.purpleLight),
                ),
              ),
            )
          else
            const SizedBox(height: 8),

          // Data Table / Loading / Error
          if (state.isLoading && state.items.isEmpty)
            const ShimmerLoading(child: ShimmerBox(height: 320))
          else if (state.errorMessage != null && state.items.isEmpty)
            _buildErrorCard(state.errorMessage!)
          else
            _buildFeedbackTable(state, isMobile),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(AdminFeedbackSummaryMetrics? metrics, bool isMobile) {
    final cards = [
      _MetricCardData(
        label: 'Total Reviews',
        value: metrics != null ? '${metrics.totalCount}' : '0',
        icon: Icons.rate_review_rounded,
        iconColor: AppColors.purple,
      ),
      _MetricCardData(
        label: 'Pending Review',
        value: metrics != null ? '${metrics.pendingCount}' : '0',
        icon: Icons.hourglass_top_rounded,
        iconColor: AppColors.accentAmber,
      ),
      _MetricCardData(
        label: 'Featured on Homepage',
        value: metrics != null ? '${metrics.featuredCount}' : '0',
        icon: Icons.star_rounded,
        iconColor: AppColors.accentGreen,
      ),
      _MetricCardData(
        label: 'Archived',
        value: metrics != null ? '${metrics.archivedCount}' : '0',
        icon: Icons.archive_outlined,
        iconColor: AppColors.slate400,
      ),
      _MetricCardData(
        label: 'Average Rating',
        value: metrics != null
            ? '${metrics.averageRating.toStringAsFixed(1)} ★'
            : '0.0 ★',
        icon: Icons.grade_rounded,
        iconColor: AppColors.accentAmber,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 5
            : constraints.maxWidth > 680
                ? 3
                : constraints.maxWidth > 340
                    ? 2
                    : 1;
        final spacing = isMobile ? 12.0 : 16.0;
        final width =
            (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
            crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((card) {
            return SizedBox(
              width: width,
              child: _MetricCard(data: card, isMobile: isMobile),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFilterAndSearchRow(AdminFeedbackState state, bool isMobile) {
    final metrics = state.metrics;

    final chipsList = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusChip(
            id: 'pending',
            label: 'Pending',
            count: metrics?.pendingCount,
            badgeColor: AppColors.accentAmber,
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            id: 'featured',
            label: '🌟 Featured',
            count: metrics?.featuredCount,
            badgeColor: AppColors.accentGreen,
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            id: 'archived',
            label: 'Archived',
            count: metrics?.archivedCount,
            badgeColor: AppColors.slate400,
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            id: 'all',
            label: 'All',
            count: metrics?.totalCount,
            badgeColor: AppColors.purple,
          ),
        ],
      ),
    );

    final searchBox = Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.glassBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _onSearchSubmitted,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search quote, student, topic...',
          hintStyle: AppTextStyles.body2.copyWith(
            color: AppColors.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textMuted,
            size: 18,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  color: AppColors.textMuted,
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );

    final refreshButton = IconButton(
      tooltip: 'Refresh Feedbacks',
      icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
      onPressed: () {
        ref.read(adminFeedbackProvider.notifier).loadFeedbacks();
      },
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          chipsList,
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: searchBox),
              const SizedBox(width: 8),
              refreshButton,
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        chipsList,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280,
              child: searchBox,
            ),
            const SizedBox(width: 12),
            refreshButton,
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required String id,
    required String label,
    int? count,
    required Color badgeColor,
  }) {
    final isSelected = _selectedStatus == id;
    return InkWell(
      onTap: () => _onStatusFilterChanged(id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? badgeColor.withValues(alpha: 0.16)
              : AppColors.surfaceDark.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? badgeColor : AppColors.glassBorder,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.captionBold.copyWith(
                color: isSelected ? badgeColor : AppColors.textMuted,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? badgeColor : AppColors.slate700,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTable(AdminFeedbackState state, bool isMobile) {
    if (state.items.isEmpty) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No feedback records found',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query or filter criteria',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final totalPages = (state.total / state.pageSize).ceil().clamp(1, 9999);

    return AdminDataTable(
      minWidth: 1100,
      columns: const [
        'Student',
        'Level & Region',
        'Rating',
        'Topic',
        'Quote (Max 250)',
        'Status',
        'Admin Notes',
        'Actions',
      ],
      columnWidths: const [1.5, 1.2, 0.8, 1.2, 2.2, 1.3, 1.3, 1.5],
      currentPage: state.page,
      totalPages: totalPages,
      onPageChanged: (newPage) {
        ref.read(adminFeedbackProvider.notifier).loadFeedbacks(page: newPage);
      },
      rows: state.items.map<List<Widget>>((item) {
        return [
          // Student
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.userName,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.userEmail,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Education Level & Region
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.educationLevel,
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.country != null && item.country!.isNotEmpty
                    ? item.country!
                    : 'Global / Not Set',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Rating
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.accentAmber,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.rating}.0',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Topic Tag (with hover Tooltip showing full topic)
          Tooltip(
            message: item.topicTag,
            waitDuration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.purple.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                item.topicTag,
                style: TextStyle(
                  color: AppColors.purpleLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),

          // Quote (Quoted & Italicized)
          Tooltip(
            message: item.quote,
            child: Text(
              '"${item.quote}"',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Status Badge
          _buildStatusBadge(item.status),

          // Admin Notes preview
          if (item.adminNotes != null && item.adminNotes!.isNotEmpty)
            Tooltip(
              message: item.adminNotes!,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 14,
                    color: AppColors.purpleLight,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.adminNotes!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.purpleLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              '—',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Feature / Unfeature Button
              if (state.isFeedbackUpdating(item.feedbackId))
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accentAmber,
                        ),
                      ),
                    ),
                  ),
                )
              else if (item.status == 'featured')
                IconButton(
                  tooltip: 'Unfeature (Archive)',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: const Size(28, 28),
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(
                    Icons.star_rounded,
                    color: AppColors.accentAmber,
                    size: 18,
                  ),
                  onPressed: () => _updateFeedbackStatus(item, 'archived'),
                )
              else
                IconButton(
                  tooltip: 'Feature on Homepage',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: const Size(28, 28),
                    padding: EdgeInsets.zero,
                  ),
                  icon: Icon(
                    Icons.star_outline_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  onPressed: () => _updateFeedbackStatus(item, 'featured'),
                ),

              const SizedBox(width: 2),

              // Add / Edit Note Button
              IconButton(
                tooltip: 'Add / Edit Internal Note',
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(28, 28),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.purple,
                  size: 18,
                ),
                onPressed: () => _showModerationDialog(item),
              ),

              const SizedBox(width: 2),

              // View Details
              IconButton(
                tooltip: 'Review Details & Moderation',
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(28, 28),
                  padding: EdgeInsets.zero,
                ),
                icon: Icon(
                  Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 17,
                ),
                onPressed: () => _showModerationDialog(item),
              ),
            ],
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'featured':
        bg = AppColors.accentGreen.withValues(alpha: 0.15);
        fg = AppColors.accentGreen;
        label = 'Featured';
        icon = Icons.star_rounded;
        break;
      case 'archived':
        bg = AppColors.slate700.withValues(alpha: 0.35);
        fg = AppColors.slate400;
        label = 'Archived';
        icon = Icons.archive_outlined;
        break;
      case 'pending':
      default:
        bg = AppColors.accentAmber.withValues(alpha: 0.15);
        fg = AppColors.accentAmber;
        label = 'Pending';
        icon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
            onPressed: () =>
                ref.read(adminFeedbackProvider.notifier).loadFeedbacks(),
            child: Text(
              'Retry',
              style: AppTextStyles.button.copyWith(color: AppColors.rose),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateFeedbackStatus(
    AdminFeedbackModel item,
    String newStatus,
  ) async {
    final success = await ref
        .read(adminFeedbackProvider.notifier)
        .updateStatus(
          feedbackId: item.feedbackId,
          newStatus: newStatus,
          adminNotes: item.adminNotes,
        );

    if (mounted) {
      if (success) {
        CenterToast.showSuccess(
          context,
          newStatus == 'featured'
              ? '⭐ Feedback is now featured on the homepage!'
              : 'Feedback status updated to $newStatus',
          title: newStatus == 'featured' ? 'Featured Testimonial' : 'Status Updated',
        );
      } else {
        CenterToast.showError(
          context,
          'Failed to update feedback status.',
          title: 'Update Failed',
        );
      }
    }
  }

  void _showModerationDialog(AdminFeedbackModel item) {
    final notesController = TextEditingController(text: item.adminNotes ?? '');
    String currentStatus = item.status;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (modalContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceMid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppColors.glassBorder),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.rate_review_rounded,
                      color: AppColors.purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Moderation & Admin Notes',
                          style: AppTextStyles.subtitle1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'ID: ${item.feedbackId.substring(0, item.feedbackId.length > 8 ? 8 : item.feedbackId.length)}... • Session: ${item.sessionId}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Learner Feedback Details Box (READ-ONLY)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.userName,
                                        style: AppTextStyles.body1.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${item.educationLevel})',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < item.rating
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: 16,
                                      color: i < item.rating
                                          ? AppColors.accentAmber
                                          : AppColors.slate500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        item.country != null &&
                                                item.country!.isNotEmpty
                                            ? item.country!
                                            : 'Country not provided',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 14,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Tooltip(
                                        message: item.topicTag,
                                        waitDuration: const Duration(milliseconds: 200),
                                        child: Text(
                                          item.topicTag,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.purpleLight,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: AppColors.glassBorder.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '"${item.quote}"',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSlate,
                                fontStyle: FontStyle.italic,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Status Selector
                      Text(
                        'Publication Status',
                        style: AppTextStyles.captionBold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusSelectButton(
                            label: 'Pending',
                            active: currentStatus == 'pending',
                            color: AppColors.accentAmber,
                            onTap: () =>
                                setDialogState(() => currentStatus = 'pending'),
                          ),
                          _buildStatusSelectButton(
                            label: '⭐ Featured',
                            active: currentStatus == 'featured',
                            color: AppColors.accentGreen,
                            onTap: () => setDialogState(
                              () => currentStatus = 'featured',
                            ),
                          ),
                          _buildStatusSelectButton(
                            label: 'Archived',
                            active: currentStatus == 'archived',
                            color: AppColors.slate400,
                            onTap: () => setDialogState(
                              () => currentStatus = 'archived',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Admin Private Notes Field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Internal Administrative Notes',
                              style: AppTextStyles.captionBold.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: notesController,
                            builder: (context, val, _) {
                              return Text(
                                '${val.text.length}/255',
                                style: AppTextStyles.caption.copyWith(
                                  color: val.text.length > 255
                                      ? AppColors.rose
                                      : AppColors.textMuted,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesController,
                        maxLength: 255,
                        maxLines: 3,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Add internal moderation note (private, never visible to student)...',
                          hintStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceDark.withValues(
                            alpha: 0.6,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.glassBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.glassBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.purple,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                GradientButton(
                  height: 38,
                  text: 'Save Moderation',
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    final success = await ref
                        .read(adminFeedbackProvider.notifier)
                        .updateStatus(
                          feedbackId: item.feedbackId,
                          newStatus: currentStatus,
                          adminNotes: notesController.text.trim().isNotEmpty
                              ? notesController.text.trim()
                              : null,
                        );
                    if (mounted) {
                      if (success) {
                        CenterToast.showSuccess(
                          context,
                          'Feedback status and moderation notes saved!',
                          title: 'Changes Saved',
                        );
                      } else {
                        CenterToast.showError(
                          context,
                          'Failed to save feedback updates.',
                          title: 'Save Failed',
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusSelectButton({
    required String label,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? color : AppColors.glassBorder,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : AppColors.textMuted,
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MetricCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MetricCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricCardData data;
  final bool isMobile;
  const _MetricCard({required this.data, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            decoration: BoxDecoration(
              color: data.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.iconColor, size: isMobile ? 18 : 20),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            data.value,
            style: (isMobile ? AppTextStyles.subtitle1 : AppTextStyles.h4).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
