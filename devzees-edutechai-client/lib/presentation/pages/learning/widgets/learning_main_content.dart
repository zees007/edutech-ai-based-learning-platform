import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../presentation/widgets/gradient_text.dart';
import '../../../../presentation/widgets/journey_prompt_card.dart';

class LearningMainContent extends StatelessWidget {
  final bool isMobile;

  const LearningMainContent({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 24.0 : 48.0),
                  child: const Center(
                    child: Text(
                      'Workspace Content\n(To be implemented)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 20,
                      ),
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
