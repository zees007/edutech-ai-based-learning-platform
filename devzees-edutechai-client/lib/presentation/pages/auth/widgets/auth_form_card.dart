import 'dart:ui';
import 'package:flutter/material.dart';

class AuthFormCard extends StatelessWidget {
  final bool isLogin;
  final bool isMobile;
  final VoidCallback onToggleMode;

  const AuthFormCard({
    super.key,
    required this.isLogin,
    required this.isMobile,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLogin ? _buildSignInHeader(isMobile) : _buildSignUpHeader(isMobile),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLogin ? _buildSignInForm() : _buildSignUpForm(isMobile),
          ),
        ],
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
            onPressed: onToggleMode,
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
            onPressed: onToggleMode,
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
