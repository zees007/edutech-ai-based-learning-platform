import 'package:flutter/material.dart';
import '../../../../../data/models/learning/session_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../widgets/gradient_circular_progress.dart';
import 'package:devzees_edutechai_client/core/theme/theme_palette.dart';

class RecentJourneyCard extends StatefulWidget {
  final SessionModel session;
  final VoidCallback onContinue;
  final bool isMobile;
  final bool isCompact;

  const RecentJourneyCard({
    super.key,
    required this.session,
    required this.onContinue,
    this.isMobile = false,
    this.isCompact = false,
  });

  @override
  State<RecentJourneyCard> createState() => _RecentJourneyCardState();
}

class _RecentJourneyCardState extends State<RecentJourneyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double progress = (widget.session.totalSteps ?? 0) > 0
        ? (widget.session.stepsCompleted / widget.session.totalSteps!).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    final isDark = context.isDarkMode;
    final bool compact = widget.isCompact;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onContinue,
        child: Container(
          transform: Matrix4.translationValues(
            0.0,
            _isHovered ? -2.5 : 0.0,
            0.0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 11 : 14,
            vertical: compact ? 8 : 9,
          ),
          decoration: BoxDecoration(
            color: isDark ? context.appColors.scaffoldBackground : Colors.white,
            borderRadius: BorderRadius.circular(100), // Pill Shape
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: isDark
                    ? (_isHovered ? 0.70 : 0.45)
                    : (_isHovered ? 0.70 : 0.40),
              ),
              width: 1.5,
            ),
            boxShadow: [
              // Omnidirectional Neon Primary Glow (matches journey prompt card)
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isDark
                      ? (_isHovered ? 0.32 : 0.18)
                      : (_isHovered ? 0.28 : 0.14),
                ),
                blurRadius: _isHovered ? 24 : 16,
                spreadRadius: _isHovered ? 2 : 0,
                offset: Offset.zero,
              ),
              if (!isDark)
                BoxShadow(
                  color: const Color(0x0A0F172A),
                  blurRadius: _isHovered ? 14 : 8,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Uniform Theme Gradient Progress Ring
              GradientCircularProgress(
                progress: progress,
                size: compact ? 22 : 26,
                strokeWidth: compact ? 2.5 : 3.0,
              ),
              SizedBox(width: compact ? 8 : 10),

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
                      style: AppTextStyles.label.copyWith(
                        fontSize: compact ? 12 : null,
                        fontWeight: _isHovered
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.accentAmber,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.session.xpEarned} XP',
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.accentAmber,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.accentGreen.withValues(alpha: 0.15)
                                  : const Color(
                                      0xFFD1FAE5,
                                    ).withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.accentGreen.withValues(
                                  alpha: isDark ? 0.35 : 0.40,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${widget.session.stepsCompleted}/${widget.session.totalSteps ?? widget.session.stepsCompleted} Steps',
                              style: AppTextStyles.badge.copyWith(
                                fontSize: 9,
                                color: isDark
                                    ? AppColors.accentGreen
                                    : const Color(0xFF047857),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: compact ? 4 : 8),

              // Subtle Action Arrow
              Container(
                transform: Matrix4.translationValues(
                  _isHovered ? 4.0 : 0.0,
                  0.0,
                  0.0,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: compact ? 12 : 14,
                  color: _isHovered
                      ? AppColors.primary
                      : context.appColors.textSecondary.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
