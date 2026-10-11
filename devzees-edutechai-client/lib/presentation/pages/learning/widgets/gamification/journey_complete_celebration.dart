import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/providers/gamification_provider.dart';
import 'package:devzees_edutechai_client/core/services/export_service.dart';
import 'package:devzees_edutechai_client/core/services/export_helper.dart';
import '../export/export_session_modal.dart';

/// Ultra-premium Glassmorphic Journey Completed Celebration modal.
/// Features:
/// - App theme design system (dark glassmorphism, AppColors, AppTextStyles)
/// - Top-right dismiss (X) button
/// - Command Hub Level HUD (Level reached, title, animated progress bar)
/// - 3-metric stats grid (XP, Quiz Mastery, Milestones)
/// - Direct 1-click export actions (PDF, Markdown) + Full Export Modal launch
/// - Responsive scrollable container preventing overflow on smaller viewports
class JourneyCompleteCelebration extends ConsumerStatefulWidget {
  final String? sessionId;
  final String topic;
  final int totalSteps;
  final int totalXp;
  final int bonusXp;
  final double? averageQuizScore;
  final VoidCallback onReview;
  final VoidCallback onNewTopic;

  const JourneyCompleteCelebration({
    super.key,
    this.sessionId,
    required this.topic,
    required this.totalSteps,
    required this.totalXp,
    required this.bonusXp,
    this.averageQuizScore,
    required this.onReview,
    required this.onNewTopic,
  });

  @override
  ConsumerState<JourneyCompleteCelebration> createState() =>
      _JourneyCompleteCelebrationState();
}

class _JourneyCompleteCelebrationState
    extends ConsumerState<JourneyCompleteCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isDismissed = false;
  bool _isDownloadingPdf = false;
  bool _isDownloadingMd = false;

  void _dismissWith(VoidCallback action) {
    if (_isDismissed) return;
    _isDismissed = true;
    _controller
        .animateBack(0.0,
            duration: const Duration(milliseconds: 220), curve: Curves.easeIn)
        .then((_) {
      if (mounted) {
        action();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _sanitizeFilename(String name, String ext) {
    final clean = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    final truncated = clean.length > 28 ? clean.substring(0, 28) : clean;
    return '${truncated}_study_guide.$ext';
  }

  Future<void> _handleDirectPdfDownload() async {
    if (_isDownloadingPdf || widget.sessionId == null) return;
    setState(() => _isDownloadingPdf = true);
    try {
      final exportService = ref.read(exportServiceProvider);
      final bytes = await exportService.fetchPdf(widget.sessionId!);
      if (!mounted) return;
      await ExportHelper.saveOrShareFile(
        bytes: bytes,
        filename: _sanitizeFilename(widget.topic, 'pdf'),
        mimeType: 'application/pdf',
        context: context,
        successMessage: 'PDF Study Guide downloaded!',
      );
    } catch (e) {
      if (!mounted) return;
      ExportHelper.showToast(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isDownloadingPdf = false);
    }
  }

  Future<void> _handleDirectMdDownload() async {
    if (_isDownloadingMd || widget.sessionId == null) return;
    setState(() => _isDownloadingMd = true);
    try {
      final exportService = ref.read(exportServiceProvider);
      final mdContent = await exportService.fetchMarkdown(widget.sessionId!);
      if (!mounted) return;
      await ExportHelper.saveOrShareText(
        content: mdContent,
        filename: _sanitizeFilename(widget.topic, 'md'),
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      ExportHelper.showToast(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isDownloadingMd = false);
    }
  }

  void _handleOpenFullExportModal() {
    if (widget.sessionId == null || widget.sessionId!.isEmpty) return;
    ExportSessionModal.show(
      context,
      sessionId: widget.sessionId!,
      topic: widget.topic,
      totalSteps: widget.totalSteps,
      stepsCompleted: widget.totalSteps,
      xpEarned: widget.totalXp,
      isCompleted: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scorePercent = widget.averageQuizScore != null
        ? (widget.averageQuizScore! * 100).round()
        : null;

    final levelData = GamificationUtils.calculateLevelData(widget.totalXp);
    final double lvlPct = (levelData['progress'] as double).clamp(0.0, 1.0);
    final int levelNumber = levelData['level'] as int;
    final String levelTitle = levelData['title'] as String;
    final int xpInLevel = levelData['xp_in_level'] as int;
    final int xpNeeded = levelData['xp_needed_for_next'] as int;
    final bool isMaxLevel = levelData['is_max_level'] as bool;

    final screenHeight = MediaQuery.of(context).size.height;
    final double maxModalHeight = screenHeight * 0.92;

    return SizedBox.expand(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ─── Glassmorphic Backdrop ───
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _dismissWith(widget.onReview),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),

            // ─── Celebration Modal Card ───
            SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 530,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  constraints: BoxConstraints(maxHeight: maxModalHeight),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.isDark
                            ? AppColors.surfaceDark.withValues(alpha: 0.97)
                            : const Color(0xFFFFFFFF),
                        AppColors.isDark
                            ? AppColors.surfaceDeep.withValues(alpha: 0.95)
                            : const Color(0xFFF8FAFC),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.isDark
                          ? Colors.amber.withValues(alpha: 0.45)
                          : const Color(0xFFFCD34D),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: AppColors.isDark ? 0.65 : 0.12),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.amber.withValues(
                            alpha: AppColors.isDark ? 0.18 : 0.10),
                        blurRadius: 36,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(
                            alpha: AppColors.isDark ? 0.20 : 0.08),
                        blurRadius: 32,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ─── Header Action Row (Close button top-right) ───
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Micro Status Tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.isDark
                                      ? Colors.amber.withValues(alpha: 0.15)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.isDark
                                        ? Colors.amber.withValues(alpha: 0.35)
                                        : const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stars_rounded,
                                      size: 13,
                                      color: AppColors.isDark
                                          ? Colors.amber
                                          : const Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Mastery Verified',
                                      style: AppTextStyles.badge.copyWith(
                                        color: AppColors.isDark
                                            ? Colors.amber.shade200
                                            : const Color(0xFFB45309),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Close (X) Icon
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => _dismissWith(widget.onReview),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : const Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.isDark
                                            ? AppColors.glassBorderSubtle
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 17,
                                      color: AppColors.isDark
                                          ? AppColors.textMuted
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ─── Glowing Golden Trophy Badge ───
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.orange.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.45),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ─── Heading Title ───
                          Text(
                            'JOURNEY MASTERED! 🎓',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ─── Topic Pill ───
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.isDark
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.isDark
                                    ? AppColors.primary.withValues(alpha: 0.30)
                                    : const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Text(
                              widget.topic,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.subtitle2.copyWith(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.isDark
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFF1D4ED8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ─── COMMAND HUB LEVEL HUD SECTION ───
                          _buildLevelHudCard(
                            level: levelNumber,
                            title: levelTitle,
                            progress: lvlPct,
                            xpInLevel: xpInLevel,
                            xpNeeded: xpNeeded,
                            isMaxLevel: isMaxLevel,
                          ),
                          const SizedBox(height: 14),

                          // ─── 3 KEY STATS GRID (XP, Quiz Mastery, Milestones) ───
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.bolt_rounded,
                                  iconColor: AppColors.isDark
                                      ? AppColors.accentAmber
                                      : const Color(0xFFD97706),
                                  label: 'Total XP',
                                  value: '+${widget.totalXp}',
                                  accentGradient: AppColors.isDark
                                      ? [
                                          AppColors.accentAmber.withValues(alpha: 0.20),
                                          AppColors.amberDeep.withValues(alpha: 0.08),
                                        ]
                                      : [
                                          const Color(0xFFFEF3C7),
                                          const Color(0xFFFFFBEB),
                                        ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.checklist_rounded,
                                  iconColor: AppColors.isDark
                                      ? AppColors.accentCyan
                                      : const Color(0xFF0284C7),
                                  label: 'Quiz Mastery',
                                  value: scorePercent != null
                                      ? '$scorePercent%'
                                      : '100%',
                                  accentGradient: AppColors.isDark
                                      ? [
                                          AppColors.accentCyan.withValues(alpha: 0.20),
                                          AppColors.blueLight.withValues(alpha: 0.08),
                                        ]
                                      : [
                                          const Color(0xFFE0F2FE),
                                          const Color(0xFFF0F9FF),
                                        ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.military_tech_rounded,
                                  iconColor: AppColors.isDark
                                      ? AppColors.accentGreen
                                      : const Color(0xFF059669),
                                  label: 'Milestones',
                                  value:
                                      '${widget.totalSteps}/${widget.totalSteps}',
                                  accentGradient: AppColors.isDark
                                      ? [
                                          AppColors.accentGreen.withValues(alpha: 0.20),
                                          AppColors.emerald.withValues(alpha: 0.08),
                                        ]
                                      : [
                                          const Color(0xFFDCFCE7),
                                          const Color(0xFFF0FDF4),
                                        ],
                                ),
                              ),
                            ],
                          ),

                          // ─── Bonus XP Banner (if applicable) ───
                          if (widget.bonusXp > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.isDark
                                    ? Colors.amber.withValues(alpha: 0.10)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.isDark
                                      ? Colors.amber.withValues(alpha: 0.30)
                                      : const Color(0xFFFDE68A),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events_rounded,
                                    color: AppColors.isDark
                                        ? Colors.amber
                                        : const Color(0xFFD97706),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    '+${widget.bonusXp} XP Completion Bonus Claimed! 🎉',
                                    style: AppTextStyles.captionBold.copyWith(
                                      color: AppColors.isDark
                                          ? Colors.amber.shade200
                                          : const Color(0xFFB45309),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 18),

                          // ─── STUDY MATERIALS & EXPORT SECTION ───
                          _buildExportSection(),

                          const SizedBox(height: 20),

                          // ─── ACTION BUTTONS (Review Steps / Start New Journey) ───
                          Row(
                            children: [
                              // Review Journey Steps
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.isDark
                                        ? AppColors.surfaceMid
                                            .withValues(alpha: 0.55)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.isDark
                                          ? AppColors.glassBorder
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _dismissWith(widget.onReview),
                                      mouseCursor: SystemMouseCursors.click,
                                      borderRadius: BorderRadius.circular(12),
                                      hoverColor: AppColors.isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.black.withValues(alpha: 0.04),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 11),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.visibility_rounded,
                                              size: 15,
                                              color: AppColors.isDark
                                                  ? AppColors.textSlate
                                                  : const Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 7),
                                            Text(
                                              'Review Steps',
                                              style: AppTextStyles.label.copyWith(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Start New Journey
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _dismissWith(widget.onNewTopic),
                                      mouseCursor: SystemMouseCursors.click,
                                      borderRadius: BorderRadius.circular(12),
                                      hoverColor: Colors.white.withValues(alpha: 0.12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 11),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.add_circle_outline_rounded,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 7),
                                            Flexible(
                                              child: Text(
                                                'Start New Journey',
                                                style: AppTextStyles.label.copyWith(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── COMMAND HUB LEVEL HUD WIDGET ───
  Widget _buildLevelHudCard({
    required int level,
    required String title,
    required double progress,
    required int xpInLevel,
    required int xpNeeded,
    required bool isMaxLevel,
  }) {
    final bool isDark = AppColors.isDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceSolidHeader.withValues(alpha: 0.8)
            : const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.purpleLight.withValues(alpha: 0.30)
              : const Color(0xFFE9D5FF),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.purple.withValues(alpha: 0.12)
                : const Color(0x106B47EB),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Level Badge & Title Pill
          Row(
            children: [
              // Golden Level Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.primary.withValues(alpha: 0.28),
                            AppColors.purpleDeep.withValues(alpha: 0.20),
                          ]
                        : [
                            const Color(0xFFEDE9FE),
                            const Color(0xFFDDD6FE),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: isDark
                        ? AppColors.purpleLight.withValues(alpha: 0.45)
                        : const Color(0xFFC4B5FD),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      'Level $level Reached',
                      style: AppTextStyles.captionBold.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF6D28D9),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Title Pill
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: isDark
                        ? const Color(0xFFC084FC)
                        : const Color(0xFF7C3AED),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Level Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMaxLevel ? 'Grand Sage Max Level' : 'Level $level → ${level + 1}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isMaxLevel ? 'MAX' : '$xpInLevel / $xpNeeded XP',
                    style: AppTextStyles.badge.copyWith(
                      color: isDark
                          ? const Color(0xFFC084FC)
                          : const Color(0xFF7C3AED),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: isMaxLevel ? 1.0 : progress,
                  minHeight: 5.5,
                  backgroundColor: isDark
                      ? AppColors.surfaceDark.withValues(alpha: 0.8)
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isMaxLevel
                        ? (isDark ? Colors.amber : const Color(0xFFD97706))
                        : (isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STAT METRIC CARD ───
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required List<Color> accentGradient,
  }) {
    final bool isDark = AppColors.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: accentGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: iconColor.withValues(alpha: isDark ? 0.35 : 0.45),
          width: 0.9,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10.5,
              color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── STUDY MATERIALS & EXPORT SECTION ───
  Widget _buildExportSection() {
    final bool hasSessionId =
        widget.sessionId != null && widget.sessionId!.isNotEmpty;
    final bool isDark = AppColors.isDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.55)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : const Color(0xFFE2E8F0),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: 15,
                color: isDark ? AppColors.cyanLight : const Color(0xFF0284C7),
              ),
              const SizedBox(width: 7),
              Text(
                'STUDY MATERIALS & EXPORT',
                style: AppTextStyles.captionBold.copyWith(
                  color: isDark ? AppColors.cyanLight : const Color(0xFF0284C7),
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Download Action Chips Row
          Row(
            children: [
              // PDF Direct Download
              Expanded(
                child: MouseRegion(
                  cursor: hasSessionId
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: Tooltip(
                    message: 'Download complete study guide as PDF',
                    child: GestureDetector(
                      onTap: hasSessionId && !_isDownloadingPdf
                          ? _handleDirectPdfDownload
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 9, horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    AppColors.primary.withValues(alpha: 0.25),
                                    AppColors.purpleDeep.withValues(alpha: 0.18),
                                  ]
                                : [
                                    const Color(0xFFEDE9FE),
                                    const Color(0xFFE0E7FF),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.45)
                                : const Color(0xFFC7D2FE),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isDownloadingPdf) ...[
                              SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  color: isDark ? Colors.white : const Color(0xFF6D28D9),
                                  strokeWidth: 1.8,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ] else ...[
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFFC084FC)
                                    : const Color(0xFF7C3AED),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                _isDownloadingPdf ? 'Downloading...' : 'PDF Guide',
                                style: AppTextStyles.badge.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF6D28D9),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Markdown Direct Download
              Expanded(
                child: MouseRegion(
                  cursor: hasSessionId
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: Tooltip(
                    message: 'Download notes in Markdown format',
                    child: GestureDetector(
                      onTap: hasSessionId && !_isDownloadingMd
                          ? _handleDirectMdDownload
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 9, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceMid.withValues(alpha: 0.45)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? AppColors.glassBorder
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isDownloadingMd) ...[
                              SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                  strokeWidth: 1.8,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ] else ...[
                              Icon(
                                Icons.description_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.textSlate
                                    : const Color(0xFF475569),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                _isDownloadingMd ? 'Downloading...' : 'Markdown',
                                style: AppTextStyles.badge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // More Export Options / Preview Modal
              MouseRegion(
                cursor: hasSessionId
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: Tooltip(
                  message: 'Preview notes, copy to clipboard, and HTML options',
                  child: GestureDetector(
                    onTap: hasSessionId ? _handleOpenFullExportModal : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.glassBorderSubtle
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: isDark
                                ? const Color(0xFFC084FC)
                                : const Color(0xFF7C3AED),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Options',
                            style: AppTextStyles.badge.copyWith(
                              color: isDark
                                  ? const Color(0xFFC084FC)
                                  : const Color(0xFF7C3AED),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
