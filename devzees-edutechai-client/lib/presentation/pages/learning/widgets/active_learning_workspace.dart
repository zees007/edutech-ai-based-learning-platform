import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/active_session_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'milestone_roadmap_stepper.dart';

class ActiveLearningWorkspace extends ConsumerWidget {
  const ActiveLearningWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeSessionProvider);
    final session = activeState.session;

    if (session == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Gamification Dashboard Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Title Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Mastery Dashboard',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildBadge(Icons.auto_awesome, 'Mode: ${session.learningMode.toUpperCase()}', AppColors.primary),
                        const SizedBox(width: 12),
                        _buildBadge(Icons.school, 'Audience: ${session.studentLevel}', Colors.blueAccent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 4 Metric Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final currentLevel = (session.xpEarned / 1000).floor() + 1;
                  final nextLevel = currentLevel + 1;
                  final nextLevelProgress = (session.xpEarned % 1000) / 1000.0;
                  final totalSteps = session.steps.isNotEmpty ? session.steps.length : 1;
                  final completionProgress = session.stepsCompleted / totalSteps;

                  return GridView.count(
                    crossAxisCount: isMobile ? 2 : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildMetricCard(
                        'Current Level', 
                        'Lvl $currentLevel', 
                        Icons.military_tech, 
                        Colors.amber
                      ),
                      _buildMetricCard(
                        'Total XP Earned', 
                        '${session.xpEarned} XP', 
                        Icons.star, 
                        Colors.amberAccent
                      ),
                      _buildProgressCard(
                        'Level Progress', 
                        'Lvl $currentLevel → $nextLevel', 
                        nextLevelProgress, 
                        AppColors.primary
                      ),
                      _buildProgressCard(
                        'Topic Completion', 
                        '${session.stepsCompleted}/${session.steps.length} Steps', 
                        completionProgress, 
                        Colors.greenAccent
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Milestone Stepper
        if (session.steps.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: MilestoneRoadmapStepper(
              steps: session.steps,
              activeIndex: activeState.activeStepIndex,
              onStepTapped: (index) {
                ref.read(activeSessionProvider.notifier).setActiveStep(index);
              },
            ),
          ),
          
        // Main Content Area for Active Step
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: activeState.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : session.steps.isNotEmpty
                ? SingleChildScrollView(
                    child: _buildStepContent(session.steps[activeState.activeStepIndex]),
                  )
                : Center(
                    child: Text(
                      'No steps available.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, String subtitle, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.inter(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(dynamic step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          step.description,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        if (step.tutorExplanation != null) ...[
          Text(
            'Tutor Explanation',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.tutorExplanation!,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ]
        // More content like videos, quiz, papers can be rendered here
      ],
    );
  }
}
