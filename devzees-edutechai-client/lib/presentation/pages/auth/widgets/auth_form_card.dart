import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class AuthFormCard extends ConsumerStatefulWidget {
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
  ConsumerState<AuthFormCard> createState() => _AuthFormCardState();
}

class _AuthFormCardState extends ConsumerState<AuthFormCard> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _mobileCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter email and password');
      return;
    }

    final success = await ref.read(authProvider.notifier).login(email, password);
    if (success) {
      if (mounted) {
        context.go('/learning');
      }
    } else {
      if (mounted) {
        final error = ref.read(authProvider).error;
        _showSnackBar(error ?? 'Login failed');
      }
    }
  }

  void _handleSignUp() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final mobileNumber = _mobileCtrl.text.trim();
    final country = _countryCtrl.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    final success = await ref.read(authProvider.notifier).createUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      mobileNumber: mobileNumber.isNotEmpty ? mobileNumber : null,
      country: country.isNotEmpty ? country : null,
    );

    if (success) {
      if (mounted) {
        _showSnackBar('Account created successfully! Please login.');
        widget.onToggleMode(); // Switch to login
      }
    } else {
      if (mounted) {
        final error = ref.read(authProvider).error;
        _showSnackBar(error ?? 'Registration failed');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.surfaceIndigo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.accentPurple.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: widget.isLogin ? _buildSignInHeader(widget.isMobile) : _buildSignUpHeader(widget.isMobile),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: widget.isLogin ? _buildSignInForm() : _buildSignUpForm(widget.isMobile),
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
            gradient: AppColors.cardGradientOpaque,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentPurple.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.35),
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
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accentPink,
                        AppColors.accentPurple,
                        AppColors.accentBlue,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(color: AppColors.accentPink, blurRadius: 15),
                      BoxShadow(color: AppColors.accentPurple, blurRadius: 20),
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
              style: AppTextStyles.h2.copyWith(
                fontSize: isMobile ? 26 : 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.pinkPurpleGradient.createShader(bounds),
              child: Text(
                "AI Workspace",
                style: AppTextStyles.h2.copyWith(
                  fontSize: isMobile ? 26 : 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
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
          style: AppTextStyles.bodyPrimary.copyWith(
            fontSize: isMobile ? 14 : 16,
            color: AppColors.lavender.withValues(alpha: 0.75),
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
              style: AppTextStyles.h2.copyWith(
                fontSize: isMobile ? 26 : 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.pinkPurpleGradient.createShader(bounds),
              child: Text(
                "Learning Account",
                style: AppTextStyles.h2.copyWith(
                  fontSize: isMobile ? 26 : 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
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
          style: AppTextStyles.bodyPrimary.copyWith(
            fontSize: isMobile ? 14 : 16,
            color: AppColors.lavender.withValues(alpha: 0.75),
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
          color: AppColors.accentPurple.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.3), blurRadius: 16),
          ]),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(
          color: AppColors.lavender,
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
        _buildTextField(
          "Email Address",
          "student@example.com",
          false,
          _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onFieldSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          "Password",
          "        ",
          true,
          _passwordCtrl,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onFieldSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 32),
        _buildGradientButton("Sign In & Launch Agents 🚀", _handleLogin),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: widget.onToggleMode,
            child: Text(
              "Don't have an account? Create one",
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.lavender.withValues(alpha: 0.9),
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
          _buildTextField(
            "First Name *",
            "Jane",
            false,
            _firstNameCtrl,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            "Last Name *",
            "Doe",
            false,
            _lastNameCtrl,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "First Name *",
                  "Jane",
                  false,
                  _firstNameCtrl,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTextField(
                  "Last Name *",
                  "Doe",
                  false,
                  _lastNameCtrl,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        _buildTextField(
          "Email Address *",
          "jane.doe@example.com",
          false,
          _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          "Password * (min 6 characters)",
          "        ",
          true,
          _passwordCtrl,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          onFieldSubmitted: (_) => _handleSignUp(),
        ),
        const SizedBox(height: 20),
        if (isMobile) ...[
          _buildTextField(
            "Mobile Number",
            "+1 555-0199",
            false,
            _mobileCtrl,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            "Country",
            "United States",
            false,
            _countryCtrl,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.countryName],
            onFieldSubmitted: (_) => _handleSignUp(),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Mobile Number",
                  "+1 555-0199",
                  false,
                  _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTextField(
                  "Country",
                  "United States",
                  false,
                  _countryCtrl,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.countryName],
                  onFieldSubmitted: (_) => _handleSignUp(),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 32),
        _buildGradientButton("Create Account & Spawn Agent Squad 🚀", _handleSignUp),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: widget.onToggleMode,
            child: Text(
              "Already have an account? Sign In",
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.lavender.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    bool isObscure,
    TextEditingController controller, {
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.lavender.withValues(alpha: 0.92),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          style: AppTextStyles.bodyPrimary.copyWith(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyPrimary.copyWith(
              color: AppColors.lavender.withValues(alpha: 0.38),
            ),
            filled: true,
            fillColor: AppColors.surfaceDark.withValues(alpha: 0.75),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.accentPurple.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.accentPurple.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.accentPurple.withValues(alpha: 0.95),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onTap) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.pinkPurpleGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withValues(alpha: 0.4),
            offset: const Offset(0, 8),
            blurRadius: 25,
          ),
          BoxShadow(
            color: AppColors.accentPink.withValues(alpha: 0.25),
            offset: const Offset(0, 0),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.button.copyWith(
                color: AppColors.textPrimary,
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
