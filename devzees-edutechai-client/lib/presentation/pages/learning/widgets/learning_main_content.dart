import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../presentation/widgets/gradient_text.dart';
import '../../../../presentation/widgets/journey_prompt_card.dart';
import '../../../../core/providers/learning_provider.dart';
import 'recent_journey_card.dart';
import '../../../../core/theme/app_colors.dart';

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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
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
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          GradientText(
                            'Learning Workspace',
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
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
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (displaySessions.isNotEmpty)
                  Padding(
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
                                style: GoogleFonts.inter(
                                  fontSize: isMobile ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                                          // TODO: Navigate to session
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
                                          // TODO: Navigate to session
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),

                if (displaySessions.isEmpty && sessionsState.isLoading)
                  Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Pinned Bottom Section
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16.0 : 32.0,
            vertical: isMobile ? 8.0 : 16.0,
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
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GradientText(
                    'learn today?',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                'Decompose any concept into adaptive milestones, interactive Socratic lessons, and academic research.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: isMobile ? 8 : 16),
              JourneyPromptCard(
                onStartJourney: () {
                  // TODO: Handle start journey
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
