import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/responsive.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_palette.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../presentation/widgets/gradient_text.dart';
import '../../../../../presentation/widgets/gradient_button.dart';
import '../../../../../presentation/widgets/app_gradient_spinner.dart';
import 'journey_prompt_card.dart';
import '../../../../../core/providers/learning_provider.dart';
import '../../../../../core/providers/active_session_provider.dart';
import '../../../../../core/services/subscription_service.dart';
import 'recent_journey_card.dart';
import 'recent_journey_skeleton.dart';
import '../workspace/active_learning_workspace.dart';
import 'neural_inference_loader.dart';
import '../../../../../core/providers/permission_provider.dart';
import '../../../../../presentation/widgets/center_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../presentation/widgets/theme_toggle_button.dart';
import '../../../../widgets/promo_announcement_bar.dart';

class LearningMainContent extends ConsumerStatefulWidget {
  final bool isMobile;

  const LearningMainContent({super.key, required this.isMobile});

  @override
  ConsumerState<LearningMainContent> createState() =>
      _LearningMainContentState();
}

class _LearningMainContentState extends ConsumerState<LearningMainContent> {
  bool _isPromoDismissed = false;
  bool _isCancelling = false;
  bool _isConfirmationModalOpen = false;

  Future<bool?> _showCancelConfirmationDialog({
    required BuildContext context,
    required bool isPremium,
  }) {
    final isDark = context.isDarkMode;
    final isMobile = Responsive.isMobile(context);
    final accentColor = isPremium
        ? (isDark ? AppColors.primary : AppColors.purple)
        : const Color(0xFFF59E0B);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? context.appColors.scaffoldBackground : Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: (isDark ? AppColors.primary : AppColors.purple).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          titlePadding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            12,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
          ),
          actionsPadding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 20,
            16,
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  isPremium ? Icons.stop_circle_outlined : Icons.warning_amber_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPremium ? 'Discard Journey?' : 'Cancel Journey?',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: isPremium
                ? Text(
                    'Are you sure you want to stop? The current milestone synthesis and notes will be discarded.',
                    style: AppTextStyles.body2.copyWith(
                      color: isDark ? const Color(0xFF9CA3AF) : context.appColors.textSecondary,
                      height: 1.45,
                      fontSize: isMobile ? 13 : 14,
                    ),
                  )
                : _ShiningWarningText(
                    text: 'AI compute has been allocated for this session. Cancelling now will still count as 1 of your 10 free monthly sessions.',
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : context.appColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Keep Generating',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.button.copyWith(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : context.appColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradientButton(
                    text: isPremium ? 'Discard Journey' : 'Cancel Anyway',
                    height: null,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    textStyle: GoogleFonts.inter(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCancelJourney(BuildContext context, bool isPhase2) async {
    if (!isPhase2) {
      // Phase 1: Instant abort during initial milestone planning
      setState(() => _isCancelling = true);
      try {
        await ref.read(activeSessionProvider.notifier).cancelSessionCreation(isPhase1: true);
        if (context.mounted) {
          CenterToast.showInfo(
            context,
            'Journey creation cancelled.',
            title: 'Cancelled',
            duration: const Duration(seconds: 3),
          );
        }
      } finally {
        if (mounted) setState(() => _isCancelling = false);
      }
      return;
    }

    // Phase 2: Active synthesis
    final perms = ref.read(permissionProvider);
    final isPremium = perms.isPremium;

    // Hold the loader on screen while modal is presented
    setState(() => _isConfirmationModalOpen = true);
    final confirmed = await _showCancelConfirmationDialog(
      context: context,
      isPremium: isPremium,
    );

    if (confirmed == true && context.mounted) {
      // Transition atomically to cancelling state so workspace never flashes
      setState(() {
        _isConfirmationModalOpen = false;
        _isCancelling = true;
      });
      try {
        await ref.read(activeSessionProvider.notifier).cancelSessionCreation(isPhase1: false);
        if (context.mounted) {
          if (isPremium) {
            CenterToast.showSuccess(
              context,
              'Journey discarded successfully.',
              title: 'Journey Discarded',
              duration: const Duration(seconds: 3),
            );
          } else {
            CenterToast.showWarning(
              context,
              'Journey cancelled. Counted towards your monthly quota.',
              title: 'Session Cancelled',
              duration: const Duration(seconds: 4),
            );
          }
        }
      } finally {
        if (mounted) setState(() => _isCancelling = false);
      }
    } else {
      if (mounted) {
        setState(() => _isConfirmationModalOpen = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.isMobile;
    final sessionsState = ref.watch(sessionsProvider);
    // Get top 3 incomplete sessions (or just top 3 if all are complete)
    final recentSessions = sessionsState.items
        .where((s) => !s.isComplete)
        .take(3)
        .toList();

    // If no incomplete sessions, just take top 3
    final displaySessions =
        recentSessions.isEmpty && sessionsState.items.isNotEmpty
        ? sessionsState.items.take(3).toList()
        : recentSessions;

    final activeState = ref.watch(activeSessionProvider);

    if (activeState.session != null || activeState.isLoading) {
      if (activeState.isLoading || _isConfirmationModalOpen || _isCancelling) {
        // When switching session from learning history, display the theme gradient spinner in a card
        if (!activeState.isSynthesizing && !_isConfirmationModalOpen) {
          final isDark = context.isDarkMode;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isDark ? AppColors.primary : AppColors.purple)
                      .withValues(alpha: 0.45),
                  width: 1.5,
                ),
                color: isMobile
                    ? (isDark ? context.appColors.scaffoldBackground : Colors.white)
                    : null,
                gradient: isMobile ? null : (context.isDarkMode ? const LinearGradient(colors: [Color(0xF511121D), Color(0xEE0E0F18)], begin: Alignment.topLeft, end: Alignment.bottomRight) : const LinearGradient(colors: [Color(0xFAFFFFFF), Color(0xF5F9F9FB)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                boxShadow: [
                  if (!isMobile) ...[
                    BoxShadow(
                      color: (isDark ? AppColors.primary : AppColors.purple)
                          .withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                    BoxShadow(
                      color: (isDark
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.accentPink.withValues(alpha: 0.2)),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppGradientSpinner(
                    size: 56,
                    strokeWidth: 3.5,
                    showSparkle: true,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading Session',
                    style: AppTextStyles.h4.copyWith(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Restoring your learning journey...',
                    style: AppTextStyles.body2.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
                ),
              ),
            ),
          );
        }

        String title = "Initializing AI Compute Cluster";
        String subtitle =
            "Orchestrating agents and provisioning neural resources...";

        if (activeState.session != null) {
          final stepIndex = activeState.activeStepIndex;
          if (stepIndex >= 0 && stepIndex < activeState.session!.steps.length) {
            final step = activeState.session!.steps[stepIndex];
            title = "Synthesizing Step ${stepIndex + 1}: ${step.title}";
            subtitle =
                "🤖 Multi-Agents (Socratic, YouTube, Academic, Quiz) generating step content concurrently...";
          }
        }

        final isPhase2 = activeState.session != null;
        return NeuralInferenceLoader(
          title: title,
          subtitle: subtitle,
          isCancelling: _isCancelling,
          onCancel: () => _handleCancelJourney(context, isPhase2),
        );
      }
      return const ActiveLearningWorkspace(
        key: ValueKey('active_workspace'),
      );
    }

    final isDark = context.isDarkMode;

    // Check if promotional banner is active & not dismissed
    final catalogAsync = ref.watch(pricingCatalogProvider);
    final isPromoActive = catalogAsync.value?.promoBanner?.isActive ?? false;
    final isPromoVisible = isPromoActive && !_isPromoDismissed;

    return Container(
      color: isDark
          ? (isMobile ? context.appColors.scaffoldBackground : context.appColors.scaffoldBackground)
          : const Color(0xFFF6F8FC),
      child: Stack(
        children: [
          // Dark Mode Ambient Radial Gradient
          if (!isMobile)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: isDark ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: (context.isDarkMode ? const RadialGradient(center: Alignment(0.0, -0.3), radius: 1.2, colors: [Color(0xFF151624), Color(0xFF0E0F18), Color(0xFF0B0C13)], stops: [0.0, 0.5, 1.0]) : const RadialGradient(center: Alignment(0.0, -0.3), radius: 1.2, colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFF6F8FC)], stops: [0.0, 0.5, 1.0])),
                    ),
                  ),
                ),
              ),
            ),
          // Light Mode Ambient Background Aura
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: !isDark ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: const CustomPaint(
                  painter: _AmbientBackgroundPainter(isDark: false),
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final availableWidth = constraints.maxWidth;
              final isTablet = Responsive.isTablet(context);
              final double horizontalPadding = isMobile
                  ? 16.0
                  : (isTablet ? 20.0 : 32.0);

              // Auto-adjust top & bottom paddings based on promo banner presence and viewport height:
              // - With promo banner: use compact top padding (16px desktop / 12px mobile) so banner fits cleanly.
              // - Without promo banner: grant generous headroom (up to 48px desktop / 28px mobile) so
              //   "EduTechAI Learning Workspace" is comfortably spaced from the top navigation bar.
              final double heroTopPadding;
              if (isPromoVisible) {
                heroTopPadding = isMobile ? 12.0 : 16.0;
              } else {
                if (availableHeight >= 850) {
                  heroTopPadding = isMobile ? 28.0 : (isTablet ? 36.0 : 48.0);
                } else if (availableHeight >= 720) {
                  heroTopPadding = isMobile ? 22.0 : (isTablet ? 28.0 : 38.0);
                } else {
                  heroTopPadding = isMobile ? 16.0 : 24.0;
                }
              }

              final double heroBottomPadding = isPromoVisible
                  ? (isMobile ? 8.0 : 12.0)
                  : (isMobile ? 12.0 : 16.0);

              final double recentJourneysVerticalPadding = isPromoVisible
                  ? (isMobile ? 8.0 : 10.0)
                  : (isMobile ? 12.0 : 16.0);

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      minWidth: constraints.maxWidth,
                    ),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  heroTopPadding,
                                  horizontalPadding,
                                  heroBottomPadding,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1020,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (isPromoVisible)
                                          PromoAnnouncementBar(
                                            margin: const EdgeInsets.only(
                                              bottom: 14,
                                            ),
                                            onDismiss: () => setState(
                                              () => _isPromoDismissed = true,
                                            ),
                                          ),
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          children: [
                                            Text(
                                              'EduTechAI ',
                                              style:
                                                  (isMobile || isTablet
                                                          ? AppTextStyles.h3
                                                          : AppTextStyles.h2)
                                                      .copyWith(
                                                        letterSpacing: -0.5,
                                                      ),
                                            ),
                                            GradientText(
                                              'Learning Workspace',
                                              style:
                                                  (isMobile || isTablet
                                                          ? AppTextStyles.h3
                                                          : AppTextStyles.h2)
                                                      .copyWith(
                                                        letterSpacing: -0.5,
                                                      ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: isPromoVisible ? 8 : 12,
                                        ),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 740,
                                          ),
                                          child: Text(
                                            'An adaptive, intelligent learning studio where specialized AI agents orchestrate personalized roadmaps, intuitive analogies, video deep-dives, and instant mastery checks.',
                                            textAlign: TextAlign.center,
                                            style:
                                                (isMobile
                                                        ? AppTextStyles.body2
                                                        : AppTextStyles.body1)
                                                    .copyWith(
                                                      color: context
                                                          .appColors
                                                          .textSecondary,
                                                      height: isPromoVisible
                                                          ? 1.45
                                                          : 1.55,
                                                    ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: (sessionsState.isLoading ||
                                        displaySessions.isNotEmpty)
                                    ? _buildRecentJourneysSection(
                                        context: context,
                                        isLoading: sessionsState.isLoading,
                                        displaySessions: displaySessions,
                                        isMobile: isMobile,
                                        isTablet: isTablet,
                                        availableWidth: availableWidth,
                                        horizontalPadding: horizontalPadding,
                                        verticalPadding:
                                            recentJourneysVerticalPadding,
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('recent_journeys_empty'),
                                      ),
                              ),
                            ],
                          ),

                          // Bottom Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: isMobile ? 6.0 : 8.0,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1020,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      children: [
                                        Text(
                                          'What do you want to ',
                                          style:
                                              (isMobile
                                                      ? AppTextStyles.h4
                                                      : AppTextStyles.h3)
                                                  .copyWith(
                                                    letterSpacing: -0.5,
                                                  ),
                                        ),
                                        GradientText(
                                          'learn today?',
                                          style:
                                              (isMobile
                                                      ? AppTextStyles.h4
                                                      : AppTextStyles.h3)
                                                  .copyWith(
                                                    letterSpacing: -0.5,
                                                  ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isMobile ? 4 : 8),
                                    Text(
                                      'Decompose any concept into adaptive milestones, interactive Socratic lessons, and academic research.',
                                      textAlign: TextAlign.center,
                                      style:
                                          (isMobile
                                                  ? AppTextStyles.caption
                                                  : AppTextStyles.body2)
                                              .copyWith(
                                                color: context.appColors.textSecondary,
                                              ),
                                    ),
                                    SizedBox(height: isMobile ? 6 : 10),
                                    JourneyPromptCard(
                                      onStartJourney: (topic, mode, level) {
                                        ref
                                            .read(
                                              activeSessionProvider.notifier,
                                            )
                                            .startNewSession(
                                              topic: topic,
                                              mode: mode,
                                              level: level,
                                            )
                                            .catchError((error) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Failed to start journey: $error',
                                                    ),
                                                  ),
                                                );
                                              }
                                            });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (!isMobile)
            const Positioned(
              top: 16,
              right: 24,
              child: ThemeToggleButton(size: 32),
            ),
        ],
      ),
    );
  }

  /// Responsive Recent Journeys section:
  /// - Mobile (`isMobile`) or ultra-narrow panes (< 430px inner width): clipped horizontal carousel.
  /// - Tablet & Desktop: compact single-row layout fitting up to 3 journey pills cleanly without overflow.
  Widget _buildRecentJourneysSection({
    required BuildContext context,
    required bool isLoading,
    required List<dynamic> displaySessions,
    required bool isMobile,
    required bool isTablet,
    required double availableWidth,
    required double horizontalPadding,
    required double verticalPadding,
  }) {
    final double innerWidth =
        (availableWidth - horizontalPadding * 2).clamp(0.0, 1020.0);
    final int itemCount = isLoading ? 3 : displaySessions.length;
    final bool useCarousel = isMobile || innerWidth < 430;
    final double gap = isMobile ? 10.0 : (isTablet || innerWidth < 760 ? 8.0 : 12.0);
    final double carouselCardWidth =
        (innerWidth * 0.72).clamp(210.0, 248.0);
    final double rowCardWidth = itemCount > 0
        ? ((innerWidth - gap * (itemCount - 1)) / itemCount).clamp(136.0, 285.0)
        : 285.0;
    final bool useCompactCard = !useCarousel && (isTablet || rowCardWidth < 235.0);

    List<Widget> buildItems(double cardWidth) {
      final skeletonTitleWidths = [140.0, 115.0, 155.0];
      return List.generate(itemCount, (index) {
        final Widget card = isLoading
            ? RecentJourneySkeletonCard(
                isMobile: isMobile,
                isCompact: useCompactCard,
                titleWidth:
                    skeletonTitleWidths[index % skeletonTitleWidths.length],
              )
            : RecentJourneyCard(
                session: displaySessions[index],
                isMobile: isMobile,
                isCompact: useCompactCard,
                onContinue: () {
                  ref
                      .read(activeSessionProvider.notifier)
                      .loadSession(displaySessions[index].sessionId);
                },
              );

        return Padding(
          padding: EdgeInsets.only(right: index < itemCount - 1 ? gap : 0),
          child: SizedBox(width: cardWidth, child: card),
        );
      });
    }

    return Padding(
      key: ValueKey(isLoading ? 'recent_journeys_loading' : 'recent_journeys_loaded'),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1020),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚡ ', style: TextStyle(fontSize: 20)),
                  Flexible(
                    child: Text(
                      'Continue Your Recent Active Journeys',
                      textAlign: TextAlign.center,
                      style: (isMobile
                              ? AppTextStyles.subtitle2
                              : AppTextStyles.subtitle1)
                          .copyWith(
                            color: context.appColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (useCarousel)
                ClipRect(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.hardEdge,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: buildItems(carouselCardWidth),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildItems(rowCardWidth),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbientBackgroundPainter extends CustomPainter {
  final bool isDark;

  const _AmbientBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) return;

    // Soft violet ambient aura at top left
    final paint1 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.07),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.18, size.height * 0.12),
              radius: size.width * 0.4,
            ),
          );
    canvas.drawRect(Offset.zero & size, paint1);

    // Soft blue ambient aura at mid right
    final paint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF3B82F6).withValues(alpha: 0.06),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.82, size.height * 0.40),
              radius: size.width * 0.45,
            ),
          );
    canvas.drawRect(Offset.zero & size, paint2);

    // Soft purple ambient aura at bottom
    final paint3 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFA855F7).withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.50, size.height * 0.90),
              radius: size.width * 0.5,
            ),
          );
    canvas.drawRect(Offset.zero & size, paint3);
  }

  @override
  bool shouldRepaint(covariant _AmbientBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _ShiningWarningText extends StatefulWidget {
  final String text;
  final bool isDark;
  final bool isMobile;

  const _ShiningWarningText({
    required this.text,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_ShiningWarningText> createState() => _ShiningWarningTextState();
}

class _ShiningWarningTextState extends State<_ShiningWarningText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor =
        widget.isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    final shineColor =
        widget.isDark ? const Color(0xFFFFFBEB) : const Color(0xFFEA580C);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final progress = _shimmerController.value;
        final start = -3.0 + progress * 6.0;

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(start - 1.0, 0),
              end: Alignment(start + 1.0, 0),
              colors: [
                baseColor,
                shineColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Text(
        widget.text,
        style: AppTextStyles.body2.copyWith(
          color: baseColor,
          fontWeight: FontWeight.w600,
          height: 1.45,
          fontSize: widget.isMobile ? 13 : 14,
        ),
      ),
    );
  }
}
