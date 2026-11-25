import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/theme_palette.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';

/// Showcases the post-authentication AI workspace experience and provides
/// quick switching between Sign In and Create Account modes.
class AuthCanvas extends StatefulWidget {
  final bool isLogin;
  final ValueChanged<bool> onAuthModeChanged;

  const AuthCanvas({
    super.key,
    required this.isLogin,
    required this.onAuthModeChanged,
  });

  @override
  State<AuthCanvas> createState() => _AuthCanvasState();
}

class _AuthCanvasState extends State<AuthCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? context.appColors.scaffoldBackground : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.45)
              : const Color(0xFFC7D2FE).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.20),
                  blurRadius: 40,
                  spreadRadius: -8,
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x0F0F172A),
                  blurRadius: 30,
                  spreadRadius: -4,
                  offset: Offset(0, 12),
                ),
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ambient Dot Matrix Background
            Positioned.fill(
              child: CustomPaint(painter: _DotGridPainter(isDark: isDark)),
            ),

            // Workspace Value Preview Content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeaderBadge(isDark),
                      const SizedBox(height: 14),
                      _buildHeadline(isDark),
                      const SizedBox(height: 20),

                      // Pillar 01: Socratic AI Tutor Squad
                      _buildWorkspacePillarCard(
                        icon: Icons.psychology_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF60A5FA), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shadowColor: const Color(0x333B82F6),
                        tag: '01 • SOCRATIC AI TUTOR',
                        tagTextColor: isDark
                            ? AppColors.blueLight
                            : const Color(0xFF2563EB),
                        tagBgColor: const Color(0xFFEFF6FF),
                        tagBorderColor: const Color(0xFFBFDBFE),
                        title: 'Autonomous Agent Squad',
                        subtitle:
                            'Guiding questions & everyday analogies tailored to how you learn.',
                        baseColor: AppColors.accentBlue,
                        isDark: isDark,
                      ),
                      _buildConnectorArrow(isDark),

                      // Pillar 02: All-in-One Learning Tools
                      _buildWorkspacePillarCard(
                        icon: Icons.auto_awesome_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shadowColor: const Color(0x339333EA),
                        tag: '02 • LEARNING STUDIO',
                        tagTextColor: isDark
                            ? AppColors.purpleLight
                            : const Color(0xFF7C3AED),
                        tagBgColor: const Color(0xFFFAF5FF),
                        tagBorderColor: const Color(0xFFE9D5FF),
                        title: '3 Modes, Videos, Research & Quizzes',
                        subtitle:
                            'Explore papers, curated videos, and adaptive mastery checks in one place.',
                        baseColor: AppColors.accentPurple,
                        isDark: isDark,
                      ),
                      _buildConnectorArrow(isDark),

                      // Pillar 03: Track & Achieve
                      _buildWorkspacePillarCard(
                        icon: Icons.emoji_events_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22D3EE), Color(0xFF0284C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shadowColor: const Color(0x330284C7),
                        tag: '03 • TRACK & ACHIEVE',
                        tagTextColor: isDark
                            ? AppColors.cyanLight
                            : const Color(0xFF0284C7),
                        tagBgColor: const Color(0xFFF0F9FF),
                        tagBorderColor: const Color(0xFFBAE6FD),
                        title: 'XP, Streaks & Session Exports',
                        subtitle:
                            'Monitor standing on your HUD and export study sessions anytime.',
                        baseColor: AppColors.accentCyan,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 22),
                      _buildModeSelectorSection(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accentPurple.withValues(alpha: 0.15)
            : const Color(0xFFEEF2FF),
        border: Border.all(
          color: isDark
              ? AppColors.accentPurple.withValues(alpha: 0.4)
              : const Color(0xFFC7D2FE).withValues(alpha: 0.8),
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Inside Your AI Workspace',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.lavender : const Color(0xFF4F46E5),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(bool isDark) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              'What You ',
              style: AppTextStyles.h3.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: context.appColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            GradientText(
              'Unlock',
              gradient: AppColors.pinkPurpleGradient,
              style: AppTextStyles.h3.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          widget.isLogin
              ? 'Sign in to pick up right where your AI study squad left off.'
              : 'Create a free account to launch your personalized learning workspace.',
          style: AppTextStyles.caption.copyWith(
            fontSize: 12.5,
            color: isDark
                ? context.appColors.textSecondary
                : const Color(0xFF64748B),
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWorkspacePillarCard({
    required IconData icon,
    required Gradient gradient,
    required Color shadowColor,
    required String tag,
    required Color tagTextColor,
    required Color tagBgColor,
    required Color tagBorderColor,
    required String title,
    required String subtitle,
    required Color baseColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceMid.withValues(alpha: 0.85)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? baseColor.withValues(alpha: 0.35)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.18),
                  blurRadius: 18,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 21),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? tagTextColor.withValues(alpha: 0.15)
                        : tagBgColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark
                          ? tagTextColor.withValues(alpha: 0.35)
                          : tagBorderColor,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isDark
                          ? tagTextColor.withValues(alpha: 0.95)
                          : tagTextColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: context.appColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? context.appColors.textSecondary
                        : const Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorArrow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2,
            height: 12,
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : const Color(0xFF94A3B8),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelectorSection(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'READY TO ENTER?',
          style: TextStyle(
            color: isDark
                ? context.appColors.textSecondary
                : const Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildEntryModeCard(
                isActive: widget.isLogin,
                tag: 'RETURNING LEARNER',
                title: 'Sign In',
                subtitle: 'Resume sessions',
                icon: Icons.login_rounded,
                activeBorderColor: isDark
                    ? AppColors.accentGreen
                    : const Color(0xFF34D399),
                activeBgGradient: isDark
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFECFDF5), Color(0xFFF0FDFA)],
                      ),
                activeShadowColor: isDark
                    ? AppColors.accentGreen.withValues(alpha: 0.35)
                    : const Color(0x3810B981),
                tagTextColor: isDark
                    ? AppColors.accentGreen
                    : const Color(0xFF047857),
                pulseDotColor: isDark
                    ? AppColors.accentGreen
                    : const Color(0xFF10B981),
                isDark: isDark,
                onTap: () => widget.onAuthModeChanged(true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildEntryModeCard(
                isActive: !widget.isLogin,
                tag: 'NEW LEARNER',
                title: 'Create Account',
                subtitle: 'Start free today',
                icon: Icons.person_add_alt_1_rounded,
                activeBorderColor: isDark
                    ? AppColors.accentAmber
                    : const Color(0xFFFBBF24),
                activeBgGradient: isDark
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      ),
                activeShadowColor: isDark
                    ? AppColors.accentAmber.withValues(alpha: 0.35)
                    : const Color(0x38F59E0B),
                tagTextColor: isDark
                    ? AppColors.accentAmber
                    : const Color(0xFFB45309),
                pulseDotColor: isDark
                    ? AppColors.accentAmber
                    : const Color(0xFFF59E0B),
                isDark: isDark,
                onTap: () => widget.onAuthModeChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntryModeCard({
    required bool isActive,
    required String tag,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeBorderColor,
    required Gradient? activeBgGradient,
    required Color activeShadowColor,
    required Color tagTextColor,
    required Color pulseDotColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        opaque: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark
                        ? pulseDotColor.withValues(alpha: 0.15)
                        : (activeBgGradient == null
                              ? pulseDotColor.withValues(alpha: 0.15)
                              : null))
                  : (isDark
                        ? AppColors.surfaceMid.withValues(alpha: 0.8)
                        : Colors.white),
              gradient: isActive && !isDark ? activeBgGradient : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? activeBorderColor
                    : (isDark
                          ? activeBorderColor.withValues(alpha: 0.3)
                          : const Color(0xFFE2E8F0)),
                width: isActive ? 1.5 : 1.0,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeShadowColor,
                        blurRadius: isDark ? 22 : 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : const Color(0x060F172A),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                if (isActive)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, _) {
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pulseDotColor,
                            boxShadow: [
                              BoxShadow(
                                color: pulseDotColor.withValues(
                                  alpha: 0.4 + (0.5 * _pulseAnimation.value),
                                ),
                                blurRadius: 6 + (4 * _pulseAnimation.value),
                                spreadRadius: 2 * _pulseAnimation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: pulseDotColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: pulseDotColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Center(
                        child: Icon(icon, size: 16, color: tagTextColor),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tagTextColor,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subtitle2.copyWith(
                              color: context.appColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? context.appColors.textSecondary
                                  : const Color(0xFF64748B),
                              fontSize: 9.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final bool isDark;

  const _DotGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : const Color(0xFFCBD5E1).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    const spacing = 18.0;
    const radius = 1.1;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
