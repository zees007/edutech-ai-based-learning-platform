import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/learning/milestone_step.dart';
import '../../../../../core/theme/app_colors.dart';

class MilestoneRoadmapStepper extends StatelessWidget {
  final List<MilestoneStep> steps;
  final int activeIndex;
  final ValueChanged<int> onStepTapped;

  const MilestoneRoadmapStepper({
    super.key,
    required this.steps,
    required this.activeIndex,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Track
          Positioned(
            left: 40,
            right: 40,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Foreground Progress Track
          if (activeIndex > 0)
            Positioned(
              left: 40,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Simplified progress width calculation for horizontal list
                  return Container(); 
                },
              ),
            ),

          // Steps list
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: steps.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final step = steps[index];
              final isActive = index == activeIndex;
              final isCompleted = step.status == 'complete' || index < activeIndex;
              final isLocked = !isActive && !isCompleted;

              return GestureDetector(
                onTap: isLocked ? null : () => onStepTapped(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 160 : 120,
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isActive 
                            ? AppColors.primary.withValues(alpha: 0.2) 
                            : isCompleted 
                              ? Colors.greenAccent.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isActive 
                              ? AppColors.primary 
                              : isCompleted 
                                ? Colors.greenAccent.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.1),
                            width: isActive ? 2 : 1,
                          ),
                          boxShadow: [
                            if (isActive)
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isCompleted 
                                ? Icons.check_circle_outline 
                                : isLocked 
                                  ? Icons.lock_outline 
                                  : Icons.play_circle_outline,
                              color: isActive 
                                ? AppColors.primary 
                                : isCompleted 
                                  ? Colors.greenAccent 
                                  : Colors.white.withValues(alpha: 0.4),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Step ${index + 1}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: isActive || isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
