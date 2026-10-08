import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/glass_loader_overlay.dart';

import 'widgets/auth_canvas.dart';
import 'widgets/auth_top_navbar.dart';
import 'widgets/auth_intro_header.dart';
import 'widgets/auth_form_card.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isLogin = true;
  bool _isFlowchartExpanded = false;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _setAuthMode(bool isLogin) {
    setState(() {
      _isLogin = isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final authState = ref.watch(authProvider);
    final isDark = AppColors.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : const Color(0xFFF6F8FC),
      body: GlassLoaderOverlay(
        isLoading: authState.isLoading,
        title: authState.loadingMessage ?? 'Authenticating',
        child: Stack(
          children: [
            if (!isDark) ...[
              // Light Mode Ambient Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _AmbientBackgroundPainter(isDark: false),
                ),
              ),
            ],
            SafeArea(
              child: Column(
                children: [
                  AuthTopNavbar(isMobile: isMobile),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 32,
                        vertical: isMobile ? 16 : 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1240),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthIntroHeader(
                                isMobile: isMobile,
                                showInstructions: !isMobile,
                              ),
                              const SizedBox(height: 32),
                              isMobile
                                  ? _buildMobileLayout()
                                  : _buildDesktopLayout(),
                              const SizedBox(height: 48),
                              _buildSiteFooter(isMobile, isDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Auth Canvas Flowchart
        Expanded(
          flex: 11,
          child: AuthCanvas(
            isLogin: _isLogin,
            onAuthModeChanged: _setAuthMode,
          ),
        ),
        const SizedBox(width: 32),
        // Right Column: Auth Form Card
        Expanded(
          flex: 11,
          child: AuthFormCard(
            isLogin: _isLogin,
            isMobile: false,
            onToggleMode: _toggleAuthMode,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Form Card First for mobile
        AuthFormCard(
          isLogin: _isLogin,
          isMobile: true,
          onToggleMode: _toggleAuthMode,
        ),
        const SizedBox(height: 24),
        // Expandable Flowchart Toggle
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isFlowchartExpanded = !_isFlowchartExpanded;
              });
            },
            icon: Icon(
              _isFlowchartExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
            label: Text(
              _isFlowchartExpanded
                  ? "Hide Access Flowchart"
                  : "View Access Flowchart",
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              side: BorderSide(
                color: AppColors.accentPurple.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: AppColors.accentPurple.withValues(alpha: 0.08),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Expanded Content
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isFlowchartExpanded
              ? Column(
                  children: [
                    const AuthInstructionsCard(isMobile: true),
                    const SizedBox(height: 20),
                    AuthCanvas(
                      isLogin: _isLogin,
                      onAuthModeChanged: _setAuthMode,
                    ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildSiteFooter(bool isMobile, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.border : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Center(
        child: Text(
          '© 2025 EduTechAI Inc. Autonomous Academic Swarms & Adaptive Pedagogy.',
          style: TextStyle(
            fontSize: isMobile ? 11.5 : 12,
            color: isDark ? AppColors.textSecondary : const Color(0xFF94A3B8),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _AmbientBackgroundPainter extends CustomPainter {
  final bool isDark;

  const _AmbientBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) return;

    // Soft violet ambient aura at top left
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.18, size.height * 0.12),
          radius: size.width * 0.4,
        ),
      );
    canvas.drawRect(Offset.zero & size, paint1);

    // Soft blue ambient aura at mid right
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3B82F6).withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.82, size.height * 0.40),
          radius: size.width * 0.45,
        ),
      );
    canvas.drawRect(Offset.zero & size, paint2);

    // Soft purple ambient aura at bottom
    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFA855F7).withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.50, size.height * 0.90),
          radius: size.width * 0.5,
        ),
      );
    canvas.drawRect(Offset.zero & size, paint3);
  }

  @override
  bool shouldRepaint(covariant _AmbientBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
