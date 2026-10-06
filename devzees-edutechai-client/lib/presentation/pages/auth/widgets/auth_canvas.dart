import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';

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
    final isDark = AppColors.isDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasBackground : Colors.white,
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
            Positioned.fill(child: CustomPaint(painter: _DotGridPainter(isDark: isDark))),

            // Flowchart Content (Centered horizontally and vertically)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 370),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Flowchart Header Badge
                      Center(child: _buildHeaderBadge(isDark)),
                      const SizedBox(height: 18),

                      // Step 01: Intake
                      _buildWorkflowCard(
                        iconWidget: _buildStepIcon(
                          icon: Icons.person_outline_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF60A5FA), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shadowColor: const Color(0x333B82F6),
                        ),
                        tag: 'STEP 01 • INTAKE',
                        tagTextColor: isDark ? AppColors.accentBlue : const Color(0xFF2563EB),
                        tagBgColor: isDark
                            ? AppColors.accentBlue.withValues(alpha: 0.15)
                            : const Color(0xFFEFF6FF),
                        tagBorderColor: isDark
                            ? AppColors.accentBlue.withValues(alpha: 0.35)
                            : const Color(0xFFBFDBFE),
                        title: 'User Arrival',
                        subtitle: 'Initiates secure session request',
                        baseColor: AppColors.accentBlue,
                        isDark: isDark,
                      ),
                      _buildConnectorArrow(isDark),

                      // Step 02: AI Evaluation
                      _buildWorkflowCard(
                        iconWidget: _buildStepIcon(
                          icon: Icons.shield_outlined,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shadowColor: const Color(0x339333EA),
                        ),
                        tag: 'STEP 02 • AI EVALUATION',
                        tagTextColor: isDark ? AppColors.accentPurple : const Color(0xFF9333EA),
                        tagBgColor: isDark
                            ? AppColors.accentPurple.withValues(alpha: 0.15)
                            : const Color(0xFFFAF5FF),
                        tagBorderColor: isDark
                            ? AppColors.accentPurple.withValues(alpha: 0.35)
                            : const Color(0xFFE9D5FF),
                        title: 'AI Identity Guard',
                        subtitle: 'Inspects credentials & privileges',
                        baseColor: AppColors.accentPurple,
                        isDark: isDark,
                      ),
                      _buildConnectorArrow(isDark),

                      // Step 03: Routing Gateway
                      _buildWorkflowCard(
                        iconWidget: _buildStepIcon(
                          icon: Icons.help_outline_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shadowColor: const Color(0x33EC4899),
                        ),
                        tag: 'STEP 03 • ROUTING GATEWAY',
                        tagTextColor: isDark ? AppColors.accentPink : const Color(0xFFDB2777),
                        tagBgColor: isDark
                            ? AppColors.accentPink.withValues(alpha: 0.15)
                            : const Color(0xFFFDF2F8),
                        tagBorderColor: isDark
                            ? AppColors.accentPink.withValues(alpha: 0.35)
                            : const Color(0xFFFBCFE8),
                        title: 'Account Verification',
                        subtitle: 'Determines authentication pathway',
                        baseColor: AppColors.accentPink,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),

                      // Branch Indicators (Split Logic)
                      _buildBranchIndicators(isDark),
                      const SizedBox(height: 6),

                      // Dual Pathway Cards: Step 04A & Step 04B
                      _buildDualPathwayCards(isDark),
                      const SizedBox(height: 8),

                      // Convergence Connector
                      _buildConvergenceArrow(isDark),
                      const SizedBox(height: 2),

                      // Step 05: Dispatch & Unlock
                      _buildWorkflowCard(
                        iconWidget: _buildStepIcon(
                          emoji: '🧠',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22D3EE), Color(0xFF0284C7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shadowColor: const Color(0x330284C7),
                        ),
                        tag: 'STEP 05 • DISPATCH & UNLOCK',
                        tagTextColor: isDark ? AppColors.accentCyan : const Color(0xFF0284C7),
                        tagBgColor: isDark
                            ? AppColors.accentCyan.withValues(alpha: 0.15)
                            : const Color(0xFFF0F9FF),
                        tagBorderColor: isDark
                            ? AppColors.accentCyan.withValues(alpha: 0.35)
                            : const Color(0xFFBAE6FD),
                        title: 'Spawn AI Agent Squad',
                        subtitle: 'Instant Autonomous Workspace Access',
                        baseColor: AppColors.accentCyan,
                        isDark: isDark,
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          const Icon(
            Icons.bolt_rounded,
            color: Color(0xFFF59E0B),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'EduTech AI — Providing Access Flowchart',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? AppColors.lavender : const Color(0xFF4F46E5),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon({
    IconData? icon,
    String? emoji,
    required Gradient gradient,
    required Color shadowColor,
  }) {
    return Container(
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
        child: emoji != null
            ? Text(emoji, style: const TextStyle(fontSize: 19))
            : Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }

  Widget _buildWorkflowCard({
    required Widget iconWidget,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  color: baseColor.withValues(alpha: 0.20),
                  blurRadius: 20,
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
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                      color: isDark ? tagTextColor.withValues(alpha: 0.95) : tagTextColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                    fontSize: 10.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectorArrow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2,
            height: 16,
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

  Widget _buildBranchIndicators(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'YES • EXISTING USER (✓)',
                  style: TextStyle(
                    color: isDark ? AppColors.accentGreen : const Color(0xFF059669),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'NO • NEW STUDENT (✨)',
                  style: TextStyle(
                    color: isDark ? AppColors.roseLight : const Color(0xFFD97706),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? AppColors.accentGreen : const Color(0xFF10B981),
                  size: 16,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? AppColors.roseLight : const Color(0xFFF59E0B),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDualPathwayCards(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // STEP 04A (Login)
        Expanded(
          child: _buildActionRouteCard(
            isActive: widget.isLogin,
            stepTag: 'STEP 04A • LOGIN',
            title: 'Sign In',
            subtitle: 'Existing Account Access',
            iconText: '🔐',
            activeBorderColor: isDark ? AppColors.accentGreen : const Color(0xFF34D399),
            activeBgGradient: isDark
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFECFDF5), Color(0xFFF0FDFA)],
                  ),
            activeShadowColor: isDark
                ? AppColors.accentGreen.withValues(alpha: 0.35)
                : const Color(0x3810B981),
            tagTextColor: isDark ? AppColors.accentGreen : const Color(0xFF047857),
            pulseDotColor: isDark ? AppColors.accentGreen : const Color(0xFF10B981),
            isDark: isDark,
            onTap: () => widget.onAuthModeChanged(true),
          ),
        ),
        const SizedBox(width: 10),
        // STEP 04B (Register)
        Expanded(
          child: _buildActionRouteCard(
            isActive: !widget.isLogin,
            stepTag: 'STEP 04B • REGISTER',
            title: 'Create Account',
            subtitle: 'Instant Free Setup',
            iconText: '✨',
            activeBorderColor: isDark ? AppColors.accentAmber : const Color(0xFFFBBF24),
            activeBgGradient: isDark
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                  ),
            activeShadowColor: isDark
                ? AppColors.accentAmber.withValues(alpha: 0.35)
                : const Color(0x38F59E0B),
            tagTextColor: isDark ? AppColors.accentAmber : const Color(0xFFB45309),
            pulseDotColor: isDark ? AppColors.accentAmber : const Color(0xFFF59E0B),
            isDark: isDark,
            onTap: () => widget.onAuthModeChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRouteCard({
    required bool isActive,
    required String stepTag,
    required String title,
    required String subtitle,
    required String iconText,
    required Color activeBorderColor,
    required Gradient? activeBgGradient,
    required Color activeShadowColor,
    required Color tagTextColor,
    required Color pulseDotColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
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
            borderRadius: BorderRadius.circular(16),
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
                      blurRadius: isDark ? 25 : 18,
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
                      child: Text(
                        iconText,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stepTag,
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
                          style: AppTextStyles.subtitle2.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : const Color(0xFF64748B),
                            fontSize: 9,
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
    );
  }

  Widget _buildConvergenceArrow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2,
            height: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: isDark
                ? AppColors.accentCyan
                : const Color(0xFF94A3B8),
            size: 16,
          ),
        ],
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
