import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glow_background.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/user_directory_tab.dart';
import 'widgets/role_privilege_tab.dart';
import 'widgets/subscription_manager_tab.dart';
import 'widgets/analytics_tab.dart';

/// Main Admin Console page with sidebar navigation and content area.
class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  AdminSection _currentSection = AdminSection.users;
  bool _isSidebarExpanded = true;

  Widget _buildContent() {
    switch (_currentSection) {
      case AdminSection.users:
        return const UserDirectoryTab();
      case AdminSection.roles:
        return const RolePrivilegeTab();
      case AdminSection.subscriptions:
        return const SubscriptionManagerTab();
      case AdminSection.analytics:
        return const AnalyticsTab();
    }
  }

  String _getSectionTitle() {
    switch (_currentSection) {
      case AdminSection.users:
        return '👥 User Directory';
      case AdminSection.roles:
        return '🛡️ Roles & Privileges';
      case AdminSection.subscriptions:
        return '💳 Subscriptions';
      case AdminSection.analytics:
        return '📊 Analytics';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceSolidHeader,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textSecondary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(
            _getSectionTitle(),
            style: AppTextStyles.subtitle2,
          ),
        ),
        drawer: Drawer(
          backgroundColor: AppColors.sidebarBackground,
          child: AdminSidebar(
            selected: _currentSection,
            onSectionChanged: (section) {
              setState(() => _currentSection = section);
              Navigator.of(context).pop(); // Close drawer
            },
          ),
        ),
        body: GlowBackground(child: _buildContent()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlowBackground(
        child: Row(
          children: [
            // Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isSidebarExpanded ? 260 : 80,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.sidebarBackground,
                border: Border(
                  right: BorderSide(
                    color: AppColors.glassBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: AdminSidebar(
                      selected: _currentSection,
                      expanded: _isSidebarExpanded,
                      onSectionChanged: (section) {
                        setState(() => _currentSection = section);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSolidHeader,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.glassBorder,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Toggle sidebar
                        IconButton(
                          icon: Icon(
                            _isSidebarExpanded
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () {
                            setState(() {
                              _isSidebarExpanded = !_isSidebarExpanded;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        // Gradient header
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            '🛡️ EduTechAI Admin Console',
                            style: AppTextStyles.subtitle1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getSectionTitle(),
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content Area
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
