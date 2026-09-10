import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';

import 'widgets/auth_canvas.dart';
import 'widgets/auth_top_navbar.dart';
import 'widgets/auth_intro_header.dart';
import 'widgets/auth_form_card.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/glass_loader_overlay.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isFlowchartExpanded = false;

  // Animation controllers for subtle effects
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlassLoaderOverlay(
        isLoading: authState.isLoading,
        title: authState.loadingMessage ?? 'Authenticating',
        child: Stack(
          children: [
          // Background Glow Orbs
          Positioned(
            top: -100,
            left: -100,
            child: _buildGlowOrb(AppColors.primary.withValues(alpha: 0.12), isMobile ? 250 : 400),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: _buildGlowOrb(AppColors.accentPink.withValues(alpha: 0.08), isMobile ? 200 : 350),
          ),
          Positioned(
            bottom: -150,
            left: MediaQuery.of(context).size.width * 0.3,
            child: _buildGlowOrb(AppColors.accentBlue.withValues(alpha: 0.06), isMobile ? 150 : 300),
          ),

          // Main Content Area
          SafeArea(
            child: Column(
              children: [
                AuthTopNavbar(isMobile: isMobile),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: isMobile ? 24 : 40,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthIntroHeader(isMobile: isMobile, showInstructions: !isMobile),
                            const SizedBox(height: 48),
                            isMobile
                                ? _buildMobileLayout()
                                : _buildDesktopLayout(),
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
        const SizedBox(width: 48),
        // Right Column: Auth Form
        Expanded(
          flex: 10,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * 0.01 + 0.99,
                child: child,
              );
            },
            child: AuthFormCard(
              isLogin: _isLogin,
              isMobile: false,
              onToggleMode: _toggleAuthMode,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The Glass Form Card with Header Inside (First for mobile)
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value * 0.01 + 0.99,
              child: child,
            );
          },
          child: AuthFormCard(
            isLogin: _isLogin,
            isMobile: true,
            onToggleMode: _toggleAuthMode,
          ),
        ),
        const SizedBox(height: 32),
        // Expandable Flowchart Toggle
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isFlowchartExpanded = !_isFlowchartExpanded;
              });
            },
            icon: Icon(
              _isFlowchartExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
            label: Text(
              _isFlowchartExpanded ? "Hide Access Flowchart" : "View Access Flowchart",
              style: AppTextStyles.subtitle2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: AppColors.accentPurple.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              backgroundColor: AppColors.accentPurple.withValues(alpha: 0.1),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Expanded Content
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isFlowchartExpanded
              ? Column(
                  children: [
                    const AuthInstructionsCard(isMobile: true),
                    const SizedBox(height: 24),
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

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
