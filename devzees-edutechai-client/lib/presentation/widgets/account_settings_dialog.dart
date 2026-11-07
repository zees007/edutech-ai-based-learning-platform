import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/country_data.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/permission_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import 'gradient_button.dart';
import 'searchable_country_dropdown.dart';

/// Modal dialog for user account management:
/// Tab 0: Profile Editing (First Name, Last Name, Country, Mobile)
/// Tab 1: Security & Password Management (Change Password, Sign Out Other Devices)
class AccountSettingsDialog extends ConsumerStatefulWidget {
  final int initialTab;

  const AccountSettingsDialog({
    super.key,
    this.initialTab = 0,
  });

  /// Static helper to display the modal dialog.
  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AccountSettingsDialog(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<AccountSettingsDialog> createState() =>
      _AccountSettingsDialogState();
}

class _AccountSettingsDialogState extends ConsumerState<AccountSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Profile controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _countryController;
  late TextEditingController _mobileController;
  late Country _selectedCountry;
  final GlobalKey<SearchableCountryDropdownState> _countryDropdownKey = GlobalKey();

  // Security controllers
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // State flags
  bool _isSavingProfile = false;
  bool _isSavingPassword = false;
  String? _profileError;
  String? _profileSuccess;
  String? _passwordError;
  String? _passwordSuccess;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );

    final currentUser = ref.read(authProvider).user;
    final savedCountry = currentUser?.country ?? '';
    _selectedCountry = CountryData.findByName(savedCountry) ??
        CountryData.findByCode(savedCountry) ??
        CountryData.detectCountry();

    _firstNameController =
        TextEditingController(text: currentUser?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: currentUser?.lastName ?? '');
    _countryController =
        TextEditingController(text: savedCountry.isNotEmpty ? savedCountry : _selectedCountry.name);

    var initialMobile = currentUser?.mobile ?? '';
    if (initialMobile.startsWith(_selectedCountry.dialCode)) {
      initialMobile = initialMobile.substring(_selectedCountry.dialCode.length).trim();
    }
    _mobileController = TextEditingController(text: initialMobile);
  }

  void _onMobileChanged(String text) {
    if (text.startsWith('+')) {
      for (final c in CountryData.allCountries) {
        if (text.startsWith(c.dialCode)) {
          final remainder = text.substring(c.dialCode.length).trim();
          setState(() {
            _selectedCountry = c;
            _countryController.text = c.name;
            _mobileController.text = remainder;
            _mobileController.selection =
                TextSelection.collapsed(offset: remainder.length);
          });
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _mobileController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _handleSaveProfile() async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final country = _countryController.text.trim().isNotEmpty
        ? _countryController.text.trim()
        : _selectedCountry.name;

    final rawDigits = _mobileController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final mobile = rawDigits.isNotEmpty
        ? '${_selectedCountry.dialCode}$rawDigits'
        : null;

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() {
        _profileError = 'First name and Last name are required.';
        _profileSuccess = null;
      });
      return;
    }

    setState(() {
      _isSavingProfile = true;
      _profileError = null;
      _profileSuccess = null;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final updatedProfile = await userService.updateProfile(
        currentUser.id,
        firstName: firstName,
        lastName: lastName,
        country: country,
        mobile: mobile,
      );

      // Update reactive auth state and invalidate userProvider
      ref.read(authProvider.notifier).setUser(updatedProfile);
      ref.invalidate(userProvider);

      if (mounted) {
        setState(() {
          _isSavingProfile = false;
          _profileSuccess = 'Profile updated successfully!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSavingProfile = false;
          _profileError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _handleChangePassword() async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (oldPassword.isEmpty) {
      setState(() {
        _passwordError = 'Please enter your current password.';
        _passwordSuccess = null;
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _passwordError = 'New password must be at least 6 characters.';
        _passwordSuccess = null;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _passwordError = 'New password and confirmation do not match.';
        _passwordSuccess = null;
      });
      return;
    }

    if (oldPassword == newPassword) {
      setState(() {
        _passwordError =
            'New password cannot be identical to your old password.';
        _passwordSuccess = null;
      });
      return;
    }

    setState(() {
      _isSavingPassword = true;
      _passwordError = null;
      _passwordSuccess = null;
    });

    try {
      final userService = ref.read(userServiceProvider);
      await userService.changePassword(
        currentUser.id,
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (mounted) {
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        setState(() {
          _isSavingPassword = false;
          _passwordSuccess =
              'Password updated successfully! Other active sessions were invalidated.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSavingPassword = false;
          _passwordError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  // ─── UI Builders ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    final currentUser = ref.watch(authProvider).user;

    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xE60F111E)
                      : const Color(0xF5FFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar: Title & Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.manage_accounts_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Settings',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  currentUser?.email ?? 'Manage profile and security',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                          splashRadius: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Segmented Tabs Header
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.6)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        labelColor: isDark ? Colors.white : AppColors.primary,
                        unselectedLabelColor: AppColors.textMuted,
                        labelStyle: AppTextStyles.subtitle2.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: AppTextStyles.subtitle2.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(
                            iconMargin: EdgeInsets.zero,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline_rounded, size: 16),
                                SizedBox(width: 8),
                                Text('Profile'),
                              ],
                            ),
                          ),
                          Tab(
                            iconMargin: EdgeInsets.zero,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline_rounded, size: 16),
                                SizedBox(width: 8),
                                Text('Security'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tab Views
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        return _tabController.index == 0
                            ? _buildProfileTab(isDark)
                            : _buildSecurityTab(isDark);
                      },
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

  // ─── TAB 0: Profile Tab ───────────────────────────────────────────────────

  Widget _buildProfileTab(bool isDark) {
    final currentUser = ref.watch(authProvider).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_profileSuccess != null)
          _buildBanner(
            message: _profileSuccess!,
            isError: false,
            isDark: isDark,
          ),
        if (_profileError != null)
          _buildBanner(
            message: _profileError!,
            isError: true,
            isDark: isDark,
          ),

        // First Name & Last Name row
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                label: 'FIRST NAME *',
                hint: 'First name',
                controller: _firstNameController,
                prefixIcon: Icons.badge_outlined,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildInputField(
                label: 'LAST NAME *',
                hint: 'Last name',
                controller: _lastNameController,
                prefixIcon: Icons.badge_outlined,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Read-only Email Field
        _buildReadOnlyField(
          label: 'EMAIL ADDRESS',
          value: currentUser?.email ?? '',
          prefixIcon: Icons.mail_outline_rounded,
          badgeText: 'Verified',
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Country & Mobile row
        Row(
          children: [
            Expanded(
              child: _buildCountryPickerField(isDark),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMobileInputField(isDark),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Save Button
        GradientButton(
          text: 'Save Changes',
          icon: Icons.check_circle_outline_rounded,
          height: 46,
          isLoading: _isSavingProfile,
          onPressed: _handleSaveProfile,
        ),
      ],
    );
  }

  // ─── TAB 1: Security & Password Tab ───────────────────────────────────────

  Widget _buildSecurityTab(bool isDark) {
    final perms = ref.watch(permissionProvider);
    final bool canChange = perms.canChangePassword || perms.isSuperAdmin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_passwordSuccess != null)
          _buildBanner(
            message: _passwordSuccess!,
            isError: false,
            isDark: isDark,
          ),
        if (_passwordError != null)
          _buildBanner(
            message: _passwordError!,
            isError: true,
            isDark: isDark,
          ),

        if (!canChange)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.rose.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.rose.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.rose, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your role does not currently allow changing passwords. Please contact an administrator.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.rose,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          // Old Password
          _buildInputField(
            label: 'CURRENT PASSWORD *',
            hint: '••••••••',
            controller: _oldPasswordController,
            prefixIcon: Icons.key_outlined,
            isDark: isDark,
            isObscure: _obscureOldPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureOldPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              onPressed: () {
                setState(() {
                  _obscureOldPassword = !_obscureOldPassword;
                });
              },
            ),
          ),
          const SizedBox(height: 14),

          // New Password
          _buildInputField(
            label: 'NEW PASSWORD * (min 6 characters)',
            hint: '••••••••',
            controller: _newPasswordController,
            prefixIcon: Icons.lock_outline_rounded,
            isDark: isDark,
            isObscure: _obscureNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
          ),
          const SizedBox(height: 14),

          // Confirm Password
          _buildInputField(
            label: 'CONFIRM NEW PASSWORD *',
            hint: '••••••••',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_reset_rounded,
            isDark: isDark,
            isObscure: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // Update Password Button
          GradientButton(
            text: 'Update Password',
            icon: Icons.shield_outlined,
            height: 46,
            isLoading: _isSavingPassword,
            onPressed: _handleChangePassword,
          ),
        ],

        const SizedBox(height: 20),
        Divider(color: AppColors.glassBorder, height: 1),
        const SizedBox(height: 16),

        // Session Security Callout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Sessions',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Log out of all devices and browsers, including this one',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark
                        ? const Color(0xFF1E2235)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Sign out everywhere?'),
                    content: const Text(
                      'This will end all active sessions across all devices and browsers, including this one. You will need to log back in.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rose,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Sign Out Everywhere'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  Navigator.of(context).pop();
                  await ref.read(authProvider.notifier).logoutAll();
                  if (mounted) {
                    context.go('/auth');
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rose,
                side: BorderSide(
                  color: AppColors.rose.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
              ),
              child: const Text(
                'Sign Out Everywhere',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountryPickerField(bool isDark) {
    return SearchableCountryDropdown(
      key: _countryDropdownKey,
      selectedCountry: _selectedCountry,
      isDark: isDark,
      onCountryChanged: (newCountry) {
        setState(() {
          _selectedCountry = newCountry;
          _countryController.text = newCountry.name;
        });
      },
    );
  }

  Widget _buildMobileInputField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOBILE NUMBER',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : const Color(0xFF334155),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          onChanged: _onMobileChanged,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '555-0199',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondary.withValues(alpha: 0.6)
                  : const Color(0xFF94A3B8),
              fontSize: 13,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.75)
                : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: InkWell(
              onTap: () => _countryDropdownKey.currentState?.toggleDropdown(),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCountry.dialCode,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: isDark ? AppColors.primary : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Input Helpers ───────────────────────────────────────────────────────

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
    required bool isDark,
    bool isObscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondary.withValues(alpha: 0.6)
                  : const Color(0xFF94A3B8),
              fontSize: 13,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.75)
                : const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(
              prefixIcon,
              size: 17,
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.8)
                  : const Color(0xFF64748B),
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData prefixIcon,
    required String badgeText,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                prefixIcon,
                size: 17,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 12, color: AppColors.accentGreen),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanner({
    required String message,
    required bool isError,
    required bool isDark,
  }) {
    final color = isError ? AppColors.rose : AppColors.accentGreen;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

