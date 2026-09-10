import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glow_background.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/providers/learning_provider.dart';

import 'widgets/sidebar/learning_sidebar.dart';
import 'widgets/main_content/learning_main_content.dart';

class LearningPage extends ConsumerStatefulWidget {
  const LearningPage({super.key});

  @override
  ConsumerState<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends ConsumerState<LearningPage> {
  bool isExpanded = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionsProvider.notifier).loadInitial();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(sessionsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _closeDrawer() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white70),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: AppColors.background,
          child: LearningSidebar(
            expanded: true,
            isMobile: true,
            scrollController: _scrollController,
            onToggle: _toggleSidebar,
            onClose: _closeDrawer,
          ),
        ),
        body: GlowBackground(child: LearningMainContent(isMobile: isMobile)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlowBackground(
        child: Row(
          children: [
            // Sidebar
            Container(
              width: isExpanded ? 280 : 80,
              decoration: BoxDecoration(
                color: const Color(0xFF130D21),
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
              child: LearningSidebar(
                expanded: isExpanded,
                isMobile: false,
                scrollController: _scrollController,
                onToggle: _toggleSidebar,
                onClose: _closeDrawer,
              ),
            ),

            // Main Content
            Expanded(child: LearningMainContent(isMobile: isMobile)),
          ],
        ),
      ),
    );
  }
}
