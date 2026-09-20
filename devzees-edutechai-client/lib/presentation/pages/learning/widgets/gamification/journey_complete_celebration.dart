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
    _controller.reverse().then((_) {
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

    return Positioned.fill(
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
                        AppColors.surfaceDark.withValues(alpha: 0.97),
                        AppColors.surfaceDeep.withValues(alpha: 0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.65),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.18),
                        blurRadius: 36,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.20),
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
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      size: 13,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Mastery Verified',
                                      style: AppTextStyles.badge.copyWith(
                                        color: Colors.amber.shade200,
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
                                      color: Colors.white.withValues(alpha: 0.06),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.glassBorderSubtle,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 17,
                                      color: AppColors.textMuted,
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
                              color: Colors.white,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ─── Topic Pill ───
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Text(
                              widget.topic,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.subtitle2.copyWith(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade200,
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
                                  iconColor: AppColors.accentAmber,
                                  label: 'Total XP',
                                  value: '+${widget.totalXp}',
                                  accentGradient: [
                                    AppColors.accentAmber.withValues(alpha: 0.20),
                                    AppColors.amberDeep.withValues(alpha: 0.08),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.checklist_rounded,
                                  iconColor: AppColors.accentCyan,
                                  label: 'Quiz Mastery',
                                  value: scorePercent != null
                                      ? '$scorePercent%'
                                      : '100%',
                                  accentGradient: [
                                    AppColors.accentCyan.withValues(alpha: 0.20),
                                    AppColors.blueLight.withValues(alpha: 0.08),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.military_tech_rounded,
                                  iconColor: AppColors.accentGreen,
                                  label: 'Milestones',
                                  value:
                                      '${widget.totalSteps}/${widget.totalSteps}',
                                  accentGradient: [
                                    AppColors.accentGreen.withValues(alpha: 0.20),
                                    AppColors.emerald.withValues(alpha: 0.08),
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
                                color: Colors.amber.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.emoji_events_rounded,
                                    color: Colors.amber,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    '+${widget.bonusXp} XP Completion Bonus Claimed! 🎉',
                                    style: AppTextStyles.captionBold.copyWith(
                                      color: Colors.amber.shade200,
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

                          // ─── ACTION BUTTONS (Review Steps / New Journey) ───
                          Row(
                            children: [
                              // Review Journey Steps
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => _dismissWith(widget.onReview),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 11),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMid
                                            .withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.glassBorder,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.visibility_rounded,
                                            size: 15,
                                            color: AppColors.textSlate,
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
                              const SizedBox(width: 12),

                              // New Journey
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => _dismissWith(widget.onNewTopic),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 11),
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
                                          Text(
                                            'New Journey',
                                            style: AppTextStyles.label.copyWith(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSolidHeader.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purpleLight.withValues(alpha: 0.30),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.12),
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
                    colors: [
                      AppColors.primary.withValues(alpha: 0.28),
                      AppColors.purpleDeep.withValues(alpha: 0.20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: AppColors.purpleLight.withValues(alpha: 0.45),
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
                        color: Colors.white,
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
                    color: AppColors.purpleLight,
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
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isMaxLevel ? 'MAX' : '$xpInLevel / $xpNeeded XP',
                    style: AppTextStyles.badge.copyWith(
                      color: AppColors.lavender,
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
                  backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.8),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isMaxLevel ? Colors.amber : AppColors.purpleLight,
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
          color: iconColor.withValues(alpha: 0.35),
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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10.5,
              color: AppColors.textMuted,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              const Icon(
                Icons.auto_stories_rounded,
                size: 15,
                color: AppColors.cyanLight,
              ),
              const SizedBox(width: 7),
              Text(
                'STUDY MATERIALS & EXPORT',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.cyanLight,
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
                            colors: [
                              AppColors.primary.withValues(alpha: 0.25),
                              AppColors.purpleDeep.withValues(alpha: 0.18),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isDownloadingPdf) ...[
                              const SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 1.8,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ] else ...[
                              const Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 14,
                                color: AppColors.purpleLight,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                _isDownloadingPdf ? 'Downloading...' : 'PDF Guide',
                                style: AppTextStyles.badge.copyWith(
                                  color: Colors.white,
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
                          color: AppColors.surfaceMid.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.glassBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isDownloadingMd) ...[
                              const SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 1.8,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ] else ...[
                              const Icon(
                                Icons.description_rounded,
                                size: 14,
                                color: AppColors.textSlate,
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
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.glassBorderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: AppColors.lavender,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Options',
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.lavender,
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
