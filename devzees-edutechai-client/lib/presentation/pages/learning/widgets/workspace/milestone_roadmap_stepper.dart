import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/learning/milestone_step.dart';
import '../../../../../core/theme/app_colors.dart';

class MilestoneRoadmapStepper extends StatelessWidget {
  final List<MilestoneStep> steps;
  final int activeIndex;
  final int maxUnlockedIndex;
  final ValueChanged<int> onStepTapped;

  const MilestoneRoadmapStepper({
    super.key,
    required this.steps,
    required this.activeIndex,
    this.maxUnlockedIndex = 0,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final maxUnlocked = maxUnlockedIndex.clamp(0, steps.isNotEmpty ? steps.length - 1 : 0);

    return SizedBox(
      height: 100, // Reduced height
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 100,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Background Track
                Positioned(
                  left: 20,
                  right: 20,
                  top: 24, // 4(sizedbox) + 22(half height 44) - 2(half line) = 24
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Foreground Progress Track (extends to furthest unlocked step)
                if (maxUnlocked > 0)
                  Positioned(
                    left: 20,
                    top: 24,
                    child: Container(
                      height: 4,
                      width: (maxUnlocked * 144).toDouble(), // 144 is the width of an inactive step (120 + 24 margin)
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF472B6), Color(0xFFC084FC)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC084FC).withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Steps list
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isActive = index == activeIndex;
                    final isCompleted = step.status == 'complete' || index < maxUnlocked;
                    final isUnlocked = index <= maxUnlocked || isCompleted || step.status == 'in_progress';
                    final isLocked = !isUnlocked;

                    return MouseRegion(
                      cursor: isLocked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: isLocked ? null : () => onStepTapped(index),
                        child: Tooltip(
                          message: isLocked
                              ? '🔒 Step ${index + 1}${step.isPrerequisite ? " • Prerequisite" : ""}: Complete previous step to unlock\n${step.title}'
                              : (isActive
                                  ? '⭐ Currently Viewing (Step ${index + 1}${step.isPrerequisite ? " • Prerequisite" : ""})\n${step.title}\n${step.description}'
                                  : (isCompleted
                                      ? '✅ Completed (Step ${index + 1}${step.isPrerequisite ? " • Prerequisite" : ""}) — Click to review\n${step.title}'
                                      : '⚡ Step ${index + 1}${step.isPrerequisite ? " • Prerequisite" : ""}\n${step.title}\n${step.description}')),
                          textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13, height: 1.4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12), // Tighter spacing
                            width: isActive ? 160 : 120, // Keep width constrained for text wrapping
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4), // Reduced spacing
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A), // Solid background to block the line
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: isActive ? 160 : 120,
                                    height: 44,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isActive 
                                        ? AppColors.primary.withValues(alpha: 0.22) 
                                        : isCompleted 
                                          ? Colors.greenAccent.withValues(alpha: 0.1)
                                          : isUnlocked
                                            ? const Color(0xFFC084FC).withValues(alpha: 0.1)
                                            : Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isActive 
                                          ? AppColors.primary 
                                          : isCompleted 
                                            ? Colors.greenAccent.withValues(alpha: 0.5)
                                            : isUnlocked
                                              ? const Color(0xFFC084FC).withValues(alpha: 0.4)
                                              : Colors.white.withValues(alpha: 0.1),
                                        width: isActive ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        if (isActive)
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.45),
                                            blurRadius: 14,
                                            spreadRadius: 1,
                                          ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isActive
                                            ? (isCompleted ? Icons.check_circle_rounded : Icons.play_circle_fill_rounded)
                                            : (isCompleted 
                                                ? Icons.check_circle_rounded 
                                                : isLocked 
                                                  ? Icons.lock_rounded 
                                                  : Icons.bolt_rounded),
                                          color: isActive 
                                            ? AppColors.primary 
                                            : isCompleted 
                                              ? Colors.greenAccent 
                                              : isUnlocked
                                                ? const Color(0xFFC084FC)
                                                : Colors.white.withValues(alpha: 0.4),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'Step ${index + 1}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                    color: isActive || isCompleted || isUnlocked ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              if (step.isPrerequisite) ...[
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                                    ),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Icon(
                                                    Icons.school_rounded,
                                                    size: 9,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8), // Reduced space between button and text
                                Text(
                                  step.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 3, // Enable text wrap
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
