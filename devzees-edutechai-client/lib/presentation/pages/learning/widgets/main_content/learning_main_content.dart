import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/theme_palette.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../presentation/widgets/gradient_text.dart';
import '../../../../../presentation/widgets/app_gradient_spinner.dart';
import 'journey_prompt_card.dart';
import '../../../../../core/providers/learning_provider.dart';
import '../../../../../core/providers/active_session_provider.dart';
import '../../../../../core/services/subscription_service.dart';
import 'recent_journey_card.dart';
import 'recent_journey_skeleton.dart';
import '../workspace/active_learning_workspace.dart';
import 'neural_inference_loader.dart';
import '../../../../../core/providers/auth_provider.dart';
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
    required String tier,
  }) {
    final isDark = context.isDarkMode;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.canvasBackground : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isPremium
                  ? (isDark ? AppColors.primary : AppColors.purple).withValues(alpha: 0.3)
                  : const Color(0xFFEF4444).withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPremium
                      ? (isDark ? AppColors.primary : AppColors.purple).withValues(alpha: 0.12)
                      : const Color(0xFFEF4444).withValues(alpha: 0.12),
                ),
                child: Icon(
                  isPremium ? Icons.stop_circle_outlined : Icons.warning_amber_rounded,
                  color: isPremium
                      ? (isDark ? AppColors.primary : AppColors.purple)
                      : const Color(0xFFEF4444),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPremium ? 'Discard Journey?' : 'Cancel Learning Journey?',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPremium
                    ? 'Are you sure you want to stop? The current milestone synthesis and notes will be discarded.'
                    : 'AI agents are actively generating your personalized curriculum. Since AI compute has been allocated for this session, cancelling now will still count as 1 of your 10 free monthly sessions.\n\nAre you sure you want to cancel?',
                style: AppTextStyles.body2.copyWith(
                  color: isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: Text(
                'Keep Generating',
                style: AppTextStyles.button.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isPremium
                        ? AppColors.primaryGradient
                        : const LinearGradient(
                            colors: [Color(0xFFDC2626), Color(0xFFEF4444), Color(0xFFF43F5E)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isPremium ? AppColors.primary : const Color(0xFFEF4444))
                            .withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    isPremium ? 'Discard Journey' : 'Cancel & Consume Quota',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
    final user = ref.read(authProvider).user;
    final tier = user?.subscription?.tier.toLowerCase() ?? 'free';
    final isPremium = tier == 'pro' || tier == 'ultra' || (user?.roles.contains('Admin') ?? false);

    // Hold the loader on screen while modal is presented
    setState(() => _isConfirmationModalOpen = true);
    final confirmed = await _showCancelConfirmationDialog(
      context: context,
      isPremium: isPremium,
      tier: tier,
    );
    if (mounted) {
      setState(() => _isConfirmationModalOpen = false);
    }

    if (confirmed == true && context.mounted) {
      setState(() => _isCancelling = true);
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
      if (activeState.isLoading || _isConfirmationModalOpen) {
        // When switching session from learning history, display the theme gradient spinner in a card
        if (!activeState.isSynthesizing && !_isConfirmationModalOpen) {
          final isDark = AppColors.isDark;
          return Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isDark ? AppColors.primary : AppColors.purple)
                      .withValues(alpha: 0.45),
                  width: 1.5,
                ),
                color: isMobile
                    ? (isDark ? AppColors.canvasBackground : Colors.white)
                    : null,
                gradient: isMobile ? null : AppColors.cardGradientOpaque,
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
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
      return ActiveLearningWorkspace(
        key: ValueKey('active_workspace_${context.isDarkMode}'),
      );
    }

    final isDark = context.isDarkMode;

    // Check if promotional banner is active & not dismissed
    final catalogAsync = ref.watch(pricingCatalogProvider);
    final isPromoActive = catalogAsync.value?.promoBanner?.isActive ?? false;
    final isPromoVisible = isPromoActive && !_isPromoDismissed;

    return Container(
      color: isDark
          ? (isMobile ? AppColors.mobileBackground : AppColors.background)
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
                      gradient: AppColors.workspaceBackgroundRadial,
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

              // Auto-adjust top & bottom paddings based on promo banner presence and viewport height:
              // - With promo banner: use compact top padding (16px desktop / 12px mobile) so banner fits cleanly.
              // - Without promo banner: grant generous headroom (up to 48px desktop / 28px mobile) so
              //   "EduTechAI Learning Workspace" is comfortably spaced from the top navigation bar.
              final double heroTopPadding;
              if (isPromoVisible) {
                heroTopPadding = isMobile ? 12.0 : 16.0;
              } else {
                if (availableHeight >= 850) {
                  heroTopPadding = isMobile ? 28.0 : 48.0;
                } else if (availableHeight >= 720) {
                  heroTopPadding = isMobile ? 22.0 : 38.0;
                } else {
                  heroTopPadding = isMobile ? 16.0 : 26.0;
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
                                  isMobile ? 16.0 : 32.0,
                                  heroTopPadding,
                                  isMobile ? 16.0 : 32.0,
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
                                                  (isMobile
                                                          ? AppTextStyles.h3
                                                          : AppTextStyles.h2)
                                                      .copyWith(
                                                        letterSpacing: -0.5,
                                                      ),
                                            ),
                                            GradientText(
                                              'Learning Workspace',
                                              style:
                                                  (isMobile
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
                                                      color: AppColors
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
                                child: sessionsState.isLoading
                                    ? Padding(
                                        key: const ValueKey(
                                          'recent_journeys_loading',
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isMobile ? 16.0 : 32.0,
                                          vertical:
                                              recentJourneysVerticalPadding,
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
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      '⚡ ',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Continue Your Recent Active Journeys',
                                                      style:
                                                          (isMobile
                                                                  ? AppTextStyles
                                                                        .subtitle2
                                                                  : AppTextStyles
                                                                        .subtitle1)
                                                              .copyWith(
                                                                color: AppColors
                                                                    .textPrimary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                SizedBox(
                                                  height: 74,
                                                  child: Center(
                                                    child: ListView.separated(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      shrinkWrap: true,
                                                      clipBehavior: Clip.none,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount: 3,
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              const SizedBox(
                                                                width: 14,
                                                              ),
                                                      itemBuilder: (context, index) {
                                                        final widths = [
                                                          160.0,
                                                          130.0,
                                                          175.0,
                                                        ];
                                                        return SizedBox(
                                                          width: isMobile
                                                              ? 250
                                                              : 315,
                                                          child: RecentJourneySkeletonCard(
                                                            isMobile: isMobile,
                                                            titleWidth:
                                                                widths[index %
                                                                    widths
                                                                        .length],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : (displaySessions.isNotEmpty
                                          ? Padding(
                                              key: const ValueKey(
                                                'recent_journeys_loaded',
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isMobile
                                                    ? 16.0
                                                    : 32.0,
                                                vertical:
                                                    recentJourneysVerticalPadding,
                                              ),
                                              child: Center(
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                        maxWidth: 1020,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            '⚡ ',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Continue Your Recent Active Journeys',
                                                            style:
                                                                (isMobile
                                                                        ? AppTextStyles
                                                                              .subtitle2
                                                                        : AppTextStyles
                                                                              .subtitle1)
                                                                    .copyWith(
                                                                      color: AppColors
                                                                          .textPrimary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      SizedBox(
                                                        height: 74,
                                                        child: Center(
                                                          child: ListView.separated(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            clipBehavior:
                                                                Clip.none,
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            itemCount:
                                                                displaySessions
                                                                    .length,
                                                            separatorBuilder:
                                                                (
                                                                  context,
                                                                  index,
                                                                ) =>
                                                                    const SizedBox(
                                                                      width: 14,
                                                                    ),
                                                            itemBuilder: (context, index) {
                                                              final session =
                                                                  displaySessions[index];
                                                              return SizedBox(
                                                                width: isMobile
                                                                    ? 250
                                                                    : 315,
                                                                child: RecentJourneyCard(
                                                                  session:
                                                                      session,
                                                                  isMobile:
                                                                      isMobile,
                                                                  onContinue: () {
                                                                    ref
                                                                        .read(
                                                                          activeSessionProvider
                                                                              .notifier,
                                                                        )
                                                                        .loadSession(
                                                                          session
                                                                              .sessionId,
                                                                        );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(
                                              key: ValueKey(
                                                'recent_journeys_empty',
                                              ),
                                            )),
                              ),
                            ],
                          ),

                          // Bottom Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16.0 : 32.0,
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
                                                color: AppColors.textSecondary,
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
