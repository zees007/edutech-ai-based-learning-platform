import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glow_background.dart';
import 'package:devzees_edutechai_client/presentation/widgets/n8n_canvas.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';

import 'widgets/home_navbar.dart';
import 'widgets/hero_section.dart';
import 'widgets/features_section.dart';
import 'widgets/agents_section.dart';
import 'widgets/about_section.dart';
import 'widgets/pricing_section.dart';
import 'widgets/cta_footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _agentsKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
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
    BuildContext? targetContext;
    switch (section) {
      case 'about':
        targetContext = _aboutKey.currentContext;
        break;
      case 'features':
        targetContext = _featuresKey.currentContext;
        break;
      case 'agents':
        targetContext = _agentsKey.currentContext;
        break;
      case 'pricing':
        targetContext = _pricingKey.currentContext;
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
    return Scaffold(
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
                        const HeroSection(),
                        const SizedBox(height: 120),
                        const N8nCanvas(),
                        const SizedBox(height: 120),
                        FeaturesSection(key: _featuresKey),
                        const SizedBox(height: 120),
                        AgentsSection(key: _agentsKey),
                        const SizedBox(height: 120),
                        AboutSection(key: _aboutKey),
                        const SizedBox(height: 120),
                        PricingSection(key: _pricingKey),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _scrollToTop,
                      child: const Center(
                        child: Icon(Icons.arrow_upward, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
