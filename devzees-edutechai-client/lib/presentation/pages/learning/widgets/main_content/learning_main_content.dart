import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../presentation/widgets/gradient_text.dart';
import '../../../../../presentation/widgets/app_gradient_spinner.dart';
import 'journey_prompt_card.dart';
import '../../../../../core/providers/learning_provider.dart';
import '../../../../../core/providers/active_session_provider.dart';
import 'recent_journey_card.dart';
import 'recent_journey_skeleton.dart';
import '../workspace/active_learning_workspace.dart';
import 'neural_inference_loader.dart';

class LearningMainContent extends ConsumerWidget {
  final bool isMobile;

  const LearningMainContent({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        // When switching session from learning history, display the theme gradient spinner only
        if (!activeState.isSynthesizing) {
          return const Center(
            child: AppGradientSpinner(
              size: 56,
              strokeWidth: 3.5,
              showSparkle: true,
            ),
          );
        }

        String title = "Initializing AI Compute Cluster";
        String subtitle = "Orchestrating agents and provisioning neural resources...";
        
        if (activeState.session != null) {
          final stepIndex = activeState.activeStepIndex;
          if (stepIndex >= 0 && stepIndex < activeState.session!.steps.length) {
            final step = activeState.session!.steps[stepIndex];
            title = "Synthesizing Step ${stepIndex + 1}: ${step.title}";
            subtitle = "🤖 Multi-Agents (Socratic, YouTube, Academic, Quiz) generating step content concurrently...";
          }
        }
        
        return NeuralInferenceLoader(
          title: title,
          subtitle: subtitle,
        );
      }
      return const ActiveLearningWorkspace();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.workspaceBackgroundRadial,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16.0 : 32.0,
                          vertical: isMobile ? 24.0 : 48.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  'EduTechAI ',
                                  style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                GradientText(
                                  'Learning Workspace',
                                  style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 660),
                              child: Text(
                                'An adaptive, intelligent learning studio where specialized AI agents orchestrate personalized roadmaps, intuitive analogies, video deep-dives, and instant mastery checks.',
                                textAlign: TextAlign.center,
                                style: (isMobile ? AppTextStyles.body2 : AppTextStyles.body1).copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: sessionsState.isLoading
                            ? Padding(
                                key: const ValueKey('recent_journeys_loading'),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16.0 : 32.0,
                                  vertical: isMobile ? 16.0 : 24.0,
                                ),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 900),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text('⚡ ', style: TextStyle(fontSize: 24)),
                                           Text(
                                             'Continue Your Recent Active Journeys',
                                             style: (isMobile ? AppTextStyles.subtitle1 : AppTextStyles.h3).copyWith(
                                               color: AppColors.textPrimary,
                                             ),
                                           ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      if (isMobile)
                                        const Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 16.0),
                                              child: RecentJourneySkeletonCard(isMobile: true),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 16.0),
                                              child: RecentJourneySkeletonCard(isMobile: true),
                                            ),
                                          ],
                                        )
                                      else
                                        const Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 16.0,
                                          runSpacing: 16.0,
                                          children: [
                                            SizedBox(
                                              width: 280,
                                              child: RecentJourneySkeletonCard(isMobile: false),
                                            ),
                                            SizedBox(
                                              width: 280,
                                              child: RecentJourneySkeletonCard(isMobile: false),
                                            ),
                                            SizedBox(
                                              width: 280,
                                              child: RecentJourneySkeletonCard(isMobile: false),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : (displaySessions.isNotEmpty
                                ? Padding(
                                    key: const ValueKey('recent_journeys_loaded'),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 16.0 : 32.0,
                                      vertical: isMobile ? 16.0 : 24.0,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 900),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text('⚡ ', style: TextStyle(fontSize: 24)),
                                               Text(
                                                 'Continue Your Recent Active Journeys',
                                                 style: (isMobile ? AppTextStyles.subtitle1 : AppTextStyles.h3).copyWith(
                                                   color: AppColors.textPrimary,
                                                 ),
                                               ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          if (isMobile)
                                            Column(
                                              children: displaySessions
                                                  .map(
                                                    (session) => Padding(
                                                      padding: const EdgeInsets.only(
                                                        bottom: 16.0,
                                                      ),
                                                      child: RecentJourneyCard(
                                                        session: session,
                                                        isMobile: isMobile,
                                                        onContinue: () {
                                                          ref.read(activeSessionProvider.notifier).loadSession(session.sessionId);
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            )
                                          else
                                            Wrap(
                                              alignment: WrapAlignment.center,
                                              spacing: 16.0,
                                              runSpacing: 16.0,
                                              children: displaySessions
                                                  .map(
                                                    (session) => SizedBox(
                                                      width: 280,
                                                      child: RecentJourneyCard(
                                                        session: session,
                                                        isMobile: isMobile,
                                                        onContinue: () {
                                                          ref.read(activeSessionProvider.notifier).loadSession(session.sessionId);
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(key: ValueKey('recent_journeys_empty'))),
                      ),
                    ],
                  ),

                  // Pinned Bottom Section
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16.0 : 32.0,
                      vertical: isMobile ? 8.0 : 16.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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
                              style: (isMobile ? AppTextStyles.h4 : AppTextStyles.h3).copyWith(
                                letterSpacing: -0.5,
                              ),
                            ),
                            GradientText(
                              'learn today?',
                              style: (isMobile ? AppTextStyles.h4 : AppTextStyles.h3).copyWith(
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        Text(
                          'Decompose any concept into adaptive milestones, interactive Socratic lessons, and academic research.',
                          textAlign: TextAlign.center,
                          style: (isMobile ? AppTextStyles.caption : AppTextStyles.body2).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: isMobile ? 8 : 16),
                        JourneyPromptCard(
                          onStartJourney: (topic, mode, level) {
                            ref.read(activeSessionProvider.notifier).startNewSession(
                              topic: topic,
                              mode: mode,
                              level: level,
                            ).catchError((error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to start journey: $error')),
                                );
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
