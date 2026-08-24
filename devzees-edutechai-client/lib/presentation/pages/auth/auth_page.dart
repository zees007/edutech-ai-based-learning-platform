import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';

import 'widgets/auth_canvas.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  bool _isLogin = true;

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

    return Scaffold(
      backgroundColor: const Color(0xFF0E0918),
      body: Stack(
        children: [
          // Background Glow Orbs
          Positioned(
            top: -100,
            left: -100,
            child: _buildGlowOrb(const Color(0xFF8B5CF6).withValues(alpha: 0.12), isMobile ? 250 : 400),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: _buildGlowOrb(const Color(0xFFEC4899).withValues(alpha: 0.08), isMobile ? 200 : 350),
          ),
          Positioned(
            bottom: -150,
            left: MediaQuery.of(context).size.width * 0.3,
            child: _buildGlowOrb(const Color(0xFF3B82F6).withValues(alpha: 0.06), isMobile ? 150 : 300),
          ),

          // Main Content Area
          SafeArea(
            child: Column(
              children: [
                _buildTopNavbar(isMobile),
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
                            _buildIntroHeader(isMobile),
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
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLogin ? _buildSignInHeader(false) : _buildSignUpHeader(false),
                  ),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLogin ? _buildSignInForm() : _buildSignUpForm(false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Canvas on top for context
        AuthCanvas(
          isLogin: _isLogin,
          onAuthModeChanged: _setAuthMode,
        ),
        const SizedBox(height: 48),
        // The Glass Form Card with Header Inside
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value * 0.01 + 0.99,
              child: child,
            );
          },
          child: _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLogin ? _buildSignInHeader(true) : _buildSignUpHeader(true),
                ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLogin ? _buildSignInForm() : _buildSignUpForm(true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              "Access the ",
              style: TextStyle(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                "AI Learning Workspace",
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Text(
            "EduTech AI is an autonomous, multi-agent academic ecosystem. Log in or create a new student account to instantiate your personal supervisor-worker agent swarm.",
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: const Color(0xFFE9D5FF).withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("💡", style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  GradientText(
                    "Access Instructions",
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18, // Reduced from 18:20
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Trace the Providing Access Flowchart below. If you already have an account, complete the Sign In form on the right. Otherwise, proceed to the Create Account tab. Upon verification, the system dispatches the AI Agent Squad to instantly grant workspace access.",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13, // Reduced from 14:15
                  color: Colors.white.withValues(alpha: 0.7), // Reduced opacity from 0.9
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavbar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 12 : 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Text(
                '⚡ ',
                style: GoogleFonts.inter(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.w900),
              ),
              GradientText(
                'EduTech',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AI',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFC084FC),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          // Back to Home Button
          OutlinedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white70),
            label: Text(
              isMobile ? 'Back' : 'Back to Home',
              style: const TextStyle(color: Colors.white70),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
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

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(15, 23, 42, 0.94),
                Color.fromRGBO(26, 17, 46, 0.90),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFA855F7).withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                blurRadius: 65,
                spreadRadius: -15,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top Gradient Line
              Positioned(
                top: 0,
                left: 40,
                right: 40,
                height: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFFEC4899),
                        Color(0xFFA855F7),
                        Color(0xFF3B82F6),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFEC4899), blurRadius: 15),
                      BoxShadow(color: Color(0xFFA855F7), blurRadius: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInHeader(bool isMobile) {
    return Column(
      key: const ValueKey('signin_header'),
      children: [
        _buildStepBadge("🚀 STEP 04A   LOGIN"),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              "Sign In to ",
              style: TextStyle(
                fontSize: isMobile ? 26 : 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                "AI Workspace",
                style: TextStyle(
                  fontSize: isMobile ? 26 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Enter your credentials to resume your personalized curriculum session.",
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: const Color(0xFFE9D5FF).withValues(alpha: 0.75),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpHeader(bool isMobile) {
    return Column(
      key: const ValueKey('signup_header'),
      children: [
        _buildStepBadge("✨ STEP 04B   REGISTER"),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              "Create Your ",
              style: TextStyle(
                fontSize: isMobile ? 26 : 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                "Learning Account",
                style: TextStyle(
                  fontSize: isMobile ? 26 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Instantiate your personal autonomous AI agent squad in seconds.",
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: const Color(0xFFE9D5FF).withValues(alpha: 0.75),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFFA855F7).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(color: const Color(0xFFA855F7).withValues(alpha: 0.3), blurRadius: 16),
          ]),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE9D5FF),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      key: const ValueKey('signin_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField("Email Address", "student@example.com", false),
        const SizedBox(height: 20),
        _buildTextField("Password", "        ", true),
        const SizedBox(height: 32),
        _buildGradientButton("Sign In & Launch Agents 🚀"),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: _toggleAuthMode,
            child: Text(
              "Don't have an account? Create one",
              style: TextStyle(
                color: const Color(0xFFE9D5FF).withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(bool isMobile) {
    return Column(
      key: const ValueKey('signup_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isMobile) ...[
          _buildTextField("First Name *", "Jane", false),
          const SizedBox(height: 20),
          _buildTextField("Last Name *", "Doe", false),
        ] else ...[
          Row(
            children: [
              Expanded(child: _buildTextField("First Name *", "Jane", false)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField("Last Name *", "Doe", false)),
            ],
          ),
        ],
        const SizedBox(height: 20),
        _buildTextField("Email Address *", "jane.doe@example.com", false),
        const SizedBox(height: 20),
        _buildTextField("Password * (min 6 characters)", "        ", true),
        const SizedBox(height: 20),
        if (isMobile) ...[
          _buildTextField("Mobile Number", "+1 555-0199", false),
          const SizedBox(height: 20),
          _buildTextField("Country", "United States", false),
        ] else ...[
          Row(
            children: [
              Expanded(child: _buildTextField("Mobile Number", "+1 555-0199", false)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField("Country", "United States", false)),
            ],
          ),
        ],
        const SizedBox(height: 32),
        _buildGradientButton("Create Account & Spawn Agent Squad 🚀"),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: _toggleAuthMode,
            child: Text(
              "Already have an account? Sign In",
              style: TextStyle(
                color: const Color(0xFFE9D5FF).withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, bool isObscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFE9D5FF).withValues(alpha: 0.92),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: isObscure,
          style: const TextStyle(
            color: Color(0xFFFAFAFA),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFFE9D5FF).withValues(alpha: 0.38),
            ),
            filled: true,
            fillColor: const Color.fromRGBO(15, 23, 42, 0.75),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFFA855F7).withValues(alpha: 0.95),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(String text) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.4),
            offset: const Offset(0, 8),
            blurRadius: 25,
          ),
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.25),
            offset: const Offset(0, 0),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            // Future: Implement Auth Logic here
          },
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
