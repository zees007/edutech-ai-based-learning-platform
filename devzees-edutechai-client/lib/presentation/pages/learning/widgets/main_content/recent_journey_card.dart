import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/learning/session_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../widgets/gradient_circular_progress.dart';

class RecentJourneyCard extends StatefulWidget {
  final SessionModel session;
  final VoidCallback onContinue;
  final bool isMobile;

  const RecentJourneyCard({
    super.key,
    required this.session,
    required this.onContinue,
    this.isMobile = false,
  });

  @override
  State<RecentJourneyCard> createState() => _RecentJourneyCardState();
}

class _RecentJourneyCardState extends State<RecentJourneyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double progress = (widget.session.totalSteps ?? 0) > 0 
        ? (widget.session.stepsCompleted / widget.session.totalSteps!).clamp(0.0, 1.0) 
        : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onContinue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -3.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100), // Pill Shape
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.6), // Stronger purple glow
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: Offset.zero, // Glows evenly around the border
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isHovered 
                      ? AppColors.primary.withValues(alpha: 0.15) 
                      : Colors.white.withValues(alpha: 0.03),
                  border: Border.all(
                    color: _isHovered 
                        ? AppColors.primary 
                        : AppColors.primary.withValues(alpha: 0.4), // Purple border even without hover
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Uniform Theme Gradient Progress Ring
                    GradientCircularProgress(
                      progress: progress,
                      size: 28,
                      strokeWidth: 3.0,
                    ),
                    const SizedBox(width: 12),
                    
                    // Topic Text & XP
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.session.topic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.session.xpEarned} XP',
                                style: GoogleFonts.inter(
                                  color: Colors.amber.withValues(alpha: 0.9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.session.stepsCompleted}/${widget.session.totalSteps ?? widget.session.stepsCompleted} Steps',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Subtle Action Arrow
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(_isHovered ? 4.0 : 0.0, 0.0, 0.0),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: _isHovered ? AppColors.primary : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
