import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glow_background.dart';
import 'package:devzees_edutechai_client/presentation/widgets/n8n_canvas.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/app_theme.dart';
import 'package:devzees_edutechai_client/core/providers/theme_provider.dart';

import 'widgets/home_navbar.dart';
import 'widgets/hero_section.dart';
import 'widgets/workspace_preview_section.dart';
import 'widgets/comparison_section.dart';
import 'widgets/modes_and_levels_section.dart';
import 'widgets/export_ecosystem_section.dart';
import 'widgets/features_section.dart';
import 'widgets/agents_section.dart';
import 'widgets/about_section.dart';
import 'widgets/pricing_section.dart';
import 'widgets/faq_section.dart';
import 'widgets/cta_footer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  final GlobalKey _previewKey = GlobalKey();
  final GlobalKey _comparisonKey = GlobalKey();
  final GlobalKey _modesKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _agentsKey = GlobalKey();
  final GlobalKey _ecosystemKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Enforce dark palette for home page
    AppColors.setBrightness(Brightness.dark);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    // Restore AppColors to active user preference when leaving home page
    final themeMode = ref.read(themeModeProvider);
    final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);
    AppColors.setBrightness(isDark ? Brightness.dark : Brightness.light);
    super.dispose();
  }

  void _scrollListener() {
    // Show arrow after scrolling down ~half a typical page height (e.g. 500 pixels)
    final show = _scrollController.offset > 500;
    if (show != _showScrollToTop) {
      setState(() {
        _showScrollToTop = show;
      });
    }
  }

  void _scrollToSection(String section) {
    if (section == 'top') {
      _scrollToTop();
      return;
    }
    BuildContext? targetContext;
    switch (section) {
      case 'preview':
        targetContext = _previewKey.currentContext;
        break;
      case 'comparison':
        targetContext = _comparisonKey.currentContext;
        break;
      case 'modes':
        targetContext = _modesKey.currentContext;
        break;
      case 'ecosystem':
        targetContext = _ecosystemKey.currentContext;
        break;
      case 'features':
        targetContext = _featuresKey.currentContext;
        break;
      case 'agents':
        targetContext = _agentsKey.currentContext;
        break;
      case 'about':
        targetContext = _aboutKey.currentContext;
        break;
      case 'pricing':
        targetContext = _pricingKey.currentContext;
        break;
      case 'faq':
        targetContext = _faqKey.currentContext;
        break;
    }
    
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Guarantee dark palette while home page is in view
    AppColors.setBrightness(Brightness.dark);

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        body: GlowBackground(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                      child: Column(
                        children: [
                          HomeNavbar(onNavTap: _scrollToSection),
                          const SizedBox(height: 60),
                          HeroSection(onExploreTap: () => _scrollToSection('preview')),
                          const SizedBox(height: 100),
                          WorkspacePreviewSection(key: _previewKey),
                          const SizedBox(height: 120),
                          ComparisonSection(key: _comparisonKey),
                          const SizedBox(height: 120),
                          const N8nCanvas(),
                          const SizedBox(height: 120),
                          ModesAndLevelsSection(key: _modesKey),
                          const SizedBox(height: 120),
                          FeaturesSection(key: _featuresKey),
                          const SizedBox(height: 120),
                          AgentsSection(key: _agentsKey),
                          const SizedBox(height: 120),
                          ExportEcosystemSection(key: _ecosystemKey),
                          const SizedBox(height: 120),
                          AboutSection(key: _aboutKey),
                          const SizedBox(height: 120),
                          PricingSection(key: _pricingKey),
                          const SizedBox(height: 120),
                          FaqSection(key: _faqKey),
                          const SizedBox(height: 120),
                          const CtaFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _showScrollToTop 
            ? Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xCC080914),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _scrollToTop,
                        child: const Center(
                          child: Icon(Icons.arrow_upward_rounded, color: Color(0xFFEEF0F6), size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
