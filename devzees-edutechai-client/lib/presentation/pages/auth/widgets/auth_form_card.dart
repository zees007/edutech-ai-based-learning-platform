import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';

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

  bool _obscurePassword = true;

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
    final isDark = AppColors.isDark;

    return _buildContainerCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step Indicator Badge
          Center(
            child: _buildStepBadge(
              widget.isLogin ? '🚀  Step 04A • Login' : '✨  Step 04B • Register',
              isDark,
            ),
          ),
          const SizedBox(height: 16),

          // Header & Title
          _buildHeader(widget.isMobile, isDark),
          const SizedBox(height: 20),

          // Segmented Tab Switcher (Sign In vs Create Account)
          _buildSegmentedTabSwitcher(isDark),
          const SizedBox(height: 24),

          // Forms (Sign In vs Sign Up)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: widget.isLogin
                ? _buildSignInForm(isDark)
                : _buildSignUpForm(widget.isMobile, isDark),
          ),
          const SizedBox(height: 20),

          // Alternative Link
          _buildAlternativeLink(isDark),
        ],
      ),
    );
  }

  Widget _buildContainerCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: isDark ? AppColors.cardGradientOpaque : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.accentPurple.withValues(alpha: 0.45)
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.35),
                  blurRadius: 65,
                  spreadRadius: -15,
                  offset: const Offset(0, 25),
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
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 20 : 36,
        vertical: widget.isMobile ? 24 : 32,
      ),
      child: child,
    );
  }

  Widget _buildStepBadge(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accentPurple.withValues(alpha: 0.15)
            : const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.accentPurple.withValues(alpha: 0.4)
              : const Color(0xFFDDD6FE),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.3),
                  blurRadius: 16,
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.lavender : const Color(0xFF6D28D9),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile, bool isDark) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              widget.isLogin ? "Sign In to " : "Create Your ",
              style: AppTextStyles.h2.copyWith(
                fontSize: isMobile ? 23 : 27,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            GradientText(
              widget.isLogin ? "AI Workspace" : "Learning Account",
              gradient: AppColors.pinkPurpleGradient,
              style: AppTextStyles.h2.copyWith(
                fontSize: isMobile ? 23 : 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            widget.isLogin
                ? "Enter your credentials to resume your personalized curriculum session."
                : "Instantiate your personal autonomous AI agent squad in seconds.",
            style: AppTextStyles.bodyPrimary.copyWith(
              fontSize: 13.5,
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedTabSwitcher(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSubtle : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.accentPurple.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: "Sign In",
              isSelected: widget.isLogin,
              isDark: isDark,
              onTap: () {
                if (!widget.isLogin) widget.onToggleMode();
              },
            ),
          ),
          Expanded(
            child: _buildTabItem(
              title: "Create Account",
              isSelected: !widget.isLogin,
              isDark: isDark,
              onTap: () {
                if (widget.isLogin) widget.onToggleMode();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8.5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.accentPurple.withValues(alpha: 0.25)
                    : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected && isDark
                ? Border.all(
                    color: AppColors.accentPurple.withValues(alpha: 0.5),
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? AppColors.accentPurple.withValues(alpha: 0.2)
                          : const Color(0x10000000),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? AppColors.lavender : const Color(0xFF6D28D9))
                  : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(bool isDark) {
    return Column(
      key: const ValueKey('signin_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputField(
          label: "EMAIL ADDRESS",
          hint: "student@example.com",
          controller: _emailCtrl,
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          isDark: isDark,
          onFieldSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 18),
        _buildInputField(
          label: "PASSWORD",
          hint: "••••••••••••",
          controller: _passwordCtrl,
          isObscure: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          isDark: isDark,
          trailingHeader: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showSnackBar('Password reset instructions sent to your email.'),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF7C3AED),
                ),
              ),
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: isDark ? AppColors.textSecondary : const Color(0xFF94A3B8),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          onFieldSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 24),

        // App Gradient Button
        GradientButton(
          text: "Sign In",
          width: double.infinity,
          height: 48,
          isLoading: ref.watch(authProvider).isLoading,
          onPressed: _handleLogin,
        ),
      ],
    );
  }

  Widget _buildSignUpForm(bool isMobile, bool isDark) {
    return Column(
      key: const ValueKey('signup_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isMobile) ...[
          _buildInputField(
            label: "FIRST NAME *",
            hint: "Jane",
            controller: _firstNameCtrl,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            label: "LAST NAME *",
            hint: "Doe",
            controller: _lastNameCtrl,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            isDark: isDark,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: "FIRST NAME *",
                  hint: "Jane",
                  controller: _firstNameCtrl,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: "LAST NAME *",
                  hint: "Doe",
                  controller: _lastNameCtrl,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        _buildInputField(
          label: "EMAIL ADDRESS *",
          hint: "jane.doe@example.com",
          controller: _emailCtrl,
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildInputField(
          label: "PASSWORD * (MIN 6 CHARACTERS)",
          hint: "••••••••••••",
          controller: _passwordCtrl,
          isObscure: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          isDark: isDark,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: isDark ? AppColors.textSecondary : const Color(0xFF94A3B8),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 14),
        if (isMobile) ...[
          _buildInputField(
            label: "MOBILE NUMBER",
            hint: "+1 555-0199",
            controller: _mobileCtrl,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildInputField(
            label: "COUNTRY",
            hint: "United States",
            controller: _countryCtrl,
            prefixIcon: Icons.public_outlined,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.countryName],
            isDark: isDark,
            onFieldSubmitted: (_) => _handleSignUp(),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: "MOBILE NUMBER",
                  hint: "+1 555-0199",
                  controller: _mobileCtrl,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: "COUNTRY",
                  hint: "United States",
                  controller: _countryCtrl,
                  prefixIcon: Icons.public_outlined,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.countryName],
                  isDark: isDark,
                  onFieldSubmitted: (_) => _handleSignUp(),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),

        // App Gradient Button
        GradientButton(
          text: "Create Account",
          width: double.infinity,
          height: 48,
          isLoading: ref.watch(authProvider).isLoading,
          onPressed: _handleSignUp,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
    required bool isDark,
    bool isObscure = false,
    Widget? trailingHeader,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : const Color(0xFF334155),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            ?trailingHeader,
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondary.withValues(alpha: 0.6)
                  : const Color(0xFF94A3B8),
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.75)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(
              prefixIcon,
              size: 18,
              color: isDark
                  ? AppColors.accentPurple.withValues(alpha: 0.7)
                  : const Color(0xFF94A3B8),
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.accentPurple.withValues(alpha: 0.35)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.accentPurple.withValues(alpha: 0.35)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.accentPurple : const Color(0xFF7C3AED),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeLink(bool isDark) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isLogin
                ? "Don't have an account?"
                : "Already have an account?",
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 6),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onToggleMode,
              child: Text(
                widget.isLogin ? "Sign Up for Free" : "Sign In",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF7C3AED),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
