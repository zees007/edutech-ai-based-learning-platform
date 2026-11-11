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
import '../../../../../presentation/widgets/theme_toggle_button.dart';
import '../../../../widgets/promo_announcement_bar.dart';

class LearningMainContent extends ConsumerStatefulWidget {
  final bool isMobile;

  const LearningMainContent({super.key, required this.isMobile});

  @override
  ConsumerState<LearningMainContent> createState() => _LearningMainContentState();
}

class _LearningMainContentState extends ConsumerState<LearningMainContent> {
  bool _isPromoDismissed = false;

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
      if (activeState.isLoading) {
        // When switching session from learning history, display the theme gradient spinner in a card
        if (!activeState.isSynthesizing) {
          final isDark = AppColors.isDark;
          return Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isDark ? AppColors.primary : AppColors.purple).withValues(alpha: 0.45),
                  width: 1.5,
                ),
                color: isMobile
                    ? (isDark ? AppColors.canvasBackground : Colors.white)
                    : null,
                gradient: isMobile ? null : AppColors.cardGradientOpaque,
                boxShadow: [
                  if (!isMobile) ...[
                    BoxShadow(
                      color: (isDark ? AppColors.primary : AppColors.purple).withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                    BoxShadow(
                      color: (isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.accentPink.withValues(alpha: 0.2)),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ]
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

        return NeuralInferenceLoader(title: title, subtitle: subtitle);
      }
      return ActiveLearningWorkspace(key: ValueKey('active_workspace_${context.isDarkMode}'));
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
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                                    constraints: const BoxConstraints(maxWidth: 900),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (isPromoVisible)
                                          PromoAnnouncementBar(
                                            margin: const EdgeInsets.only(bottom: 14),
                                            onDismiss: () => setState(() => _isPromoDismissed = true),
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
                                                      .copyWith(letterSpacing: -0.5),
                                            ),
                                            GradientText(
                                              'Learning Workspace',
                                              style:
                                                  (isMobile
                                                          ? AppTextStyles.h3
                                                          : AppTextStyles.h2)
                                                      .copyWith(letterSpacing: -0.5),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: isPromoVisible ? 8 : 12),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 660),
                                          child: Text(
                                            'An adaptive, intelligent learning studio where specialized AI agents orchestrate personalized roadmaps, intuitive analogies, video deep-dives, and instant mastery checks.',
                                            textAlign: TextAlign.center,
                                            style:
                                                (isMobile
                                                        ? AppTextStyles.body2
                                                        : AppTextStyles.body1)
                                                    .copyWith(
                                                      color: AppColors.textSecondary,
                                                      height: isPromoVisible ? 1.45 : 1.55,
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
                                        key: const ValueKey('recent_journeys_loading'),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isMobile ? 16.0 : 32.0,
                                          vertical: recentJourneysVerticalPadding,
                                        ),
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 900,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      '⚡ ',
                                                      style: TextStyle(fontSize: 20),
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
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                SizedBox(
                                                  height: 74,
                                                  child: Center(
                                                    child: ListView.separated(
                                                      scrollDirection: Axis.horizontal,
                                                      shrinkWrap: true,
                                                      clipBehavior: Clip.none,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemCount: 3,
                                                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                                                      itemBuilder: (context, index) {
                                                        final widths = [140.0, 115.0, 155.0];
                                                        return SizedBox(
                                                          width: isMobile ? 250 : 270,
                                                          child: RecentJourneySkeletonCard(
                                                            isMobile: isMobile,
                                                            titleWidth: widths[index % widths.length],
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
                                                horizontal: isMobile ? 16.0 : 32.0,
                                                vertical: recentJourneysVerticalPadding,
                                              ),
                                              child: Center(
                                                child: ConstrainedBox(
                                                  constraints: const BoxConstraints(
                                                    maxWidth: 900,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
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
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 12),
                                                      SizedBox(
                                                        height: 74,
                                                        child: Center(
                                                          child: ListView.separated(
                                                            scrollDirection: Axis.horizontal,
                                                            shrinkWrap: true,
                                                            clipBehavior: Clip.none,
                                                            physics: const BouncingScrollPhysics(),
                                                            itemCount: displaySessions.length,
                                                            separatorBuilder: (context, index) => const SizedBox(width: 14),
                                                            itemBuilder: (context, index) {
                                                              final session = displaySessions[index];
                                                              return SizedBox(
                                                                width: isMobile ? 250 : 270,
                                                                child: RecentJourneyCard(
                                                                  session: session,
                                                                  isMobile: isMobile,
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
                                              key: ValueKey('recent_journeys_empty'),
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
                                constraints: const BoxConstraints(maxWidth: 880),
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
                                                  .copyWith(letterSpacing: -0.5),
                                        ),
                                        GradientText(
                                          'learn today?',
                                          style:
                                              (isMobile
                                                      ? AppTextStyles.h4
                                                      : AppTextStyles.h3)
                                                  .copyWith(letterSpacing: -0.5),
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
                                              .copyWith(color: AppColors.textSecondary),
                                    ),
                                    SizedBox(height: isMobile ? 6 : 10),
                                    JourneyPromptCard(
                                      onStartJourney: (topic, mode, level) {
                                        ref
                                            .read(activeSessionProvider.notifier)
                                            .startNewSession(
                                              topic: topic,
                                              mode: mode,
                                              level: level,
                                            )
                                            .catchError((error) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
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
      ..shader = RadialGradient(
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
      ..shader = RadialGradient(
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
      ..shader = RadialGradient(
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
