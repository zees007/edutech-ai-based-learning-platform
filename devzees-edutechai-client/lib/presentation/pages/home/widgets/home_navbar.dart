import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:go_router/go_router.dart';

class HomeNavbar extends StatelessWidget {
  final Function(String)? onNavTap;
  const HomeNavbar({super.key, this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(color: AppColors.accentPurple.withValues(alpha: 0.25), blurRadius: 30),
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            // Approximating inset shadow with an inner border
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.15), width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(
                  children: [
                    Text(
                      '⚡ ',
                      style: AppTextStyles.h3.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    GradientText(
                      'EduTech',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 22,
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
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.lavender,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
          
          // Links (Desktop & Tablet only)
          if (!Responsive.isMobile(context))
            Row(
              children: [
                _NavPill(title: 'About', onTap: () => onNavTap?.call('about')),
                _NavPill(title: 'Features', onTap: () => onNavTap?.call('features')),
                _NavPill(title: 'Agents', onTap: () => onNavTap?.call('agents')),
                _NavPill(title: 'Pricing', onTap: () => onNavTap?.call('pricing')),
              ],
            ),
            
          // Auth Buttons
          Row(
            children: [
              if (!Responsive.isMobile(context)) ...[
                TextButton(
                  onPressed: () {
                    context.go('/auth');
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: AppTextStyles.button.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  child: Text('Sign In', style: TextStyle(color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 8),
              ],
              GradientButton(
                text: 'Get Started',
                height: 36,
                onPressed: () {
                  context.go('/auth');
                },
              ),
              if (Responsive.isMobile(context)) ...[
                const SizedBox(width: 4),
                _MobileMenuButton(onNavTap: onNavTap),
              ],
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

class _NavPill extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _NavPill({required this.title, required this.onTap});

  @override
  State<_NavPill> createState() => _NavPillState();
}

class _NavPillState extends State<_NavPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _isHovered ? AppColors.primary.withValues(alpha: 0.18) : Colors.transparent,
            border: Border.all(
              color: _isHovered ? AppColors.primary.withValues(alpha: 0.4) : Colors.transparent,
            ),
            boxShadow: _isHovered
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 15)]
                : [],
          ),
          child: Text(
            widget.title,
            style: AppTextStyles.subtitle2.copyWith(
              color: _isHovered ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileMenuButton extends StatefulWidget {
  final Function(String)? onNavTap;
  const _MobileMenuButton({this.onNavTap});

  @override
  State<_MobileMenuButton> createState() => _MobileMenuButtonState();
}

class _MobileMenuButtonState extends State<_MobileMenuButton> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _isOpen ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(
          color: _isOpen ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: PopupMenuButton<String>(
          onOpened: () => setState(() => _isOpen = true),
          onCanceled: () => setState(() => _isOpen = false),
          onSelected: (value) {
            setState(() => _isOpen = false);
            widget.onNavTap?.call(value);
          },
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          color: Colors.transparent,
          elevation: 0,
          offset: const Offset(0, 56),
          padding: EdgeInsets.zero,
          itemBuilder: (context) => [
            PopupMenuItem(
              padding: EdgeInsets.zero,
              enabled: false,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuItem('About', 'about'),
                        _buildMenuItem('Features', 'features'),
                        _buildMenuItem('Agents', 'agents'),
                        _buildMenuItem('Pricing', 'pricing'),
                        Divider(color: AppColors.primary.withValues(alpha: 0.2), height: 1),
                        _buildMenuItem('Sign In', 'signin'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, String value) {
    return _MobileMenuItem(
      title: title,
      onTap: () {
        Navigator.pop(context, value);
      },
    );
  }
}

class _MobileMenuItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _MobileMenuItem({required this.title, required this.onTap});

  @override
  State<_MobileMenuItem> createState() => _MobileMenuItemState();
}

class _MobileMenuItemState extends State<_MobileMenuItem> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isActive = true),
      onExit: (_) => setState(() => _isActive = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isActive = true),
        onTapUp: (_) => setState(() => _isActive = false),
        onTapCancel: () => setState(() => _isActive = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          ),
          child: Text(
            widget.title,
            style: AppTextStyles.subtitle2.copyWith(
              color: _isActive ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
