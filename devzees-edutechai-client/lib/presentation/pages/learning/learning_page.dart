import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glow_background.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/providers/learning_provider.dart';
import 'package:devzees_edutechai_client/core/providers/gamification_provider.dart';

import 'widgets/sidebar/learning_sidebar.dart';
import 'widgets/main_content/learning_main_content.dart';
import 'widgets/gamification/level_up_celebration.dart';
import 'widgets/gamification/journey_complete_celebration.dart';
import 'package:devzees_edutechai_client/core/providers/active_session_provider.dart';

class LearningPage extends ConsumerStatefulWidget {
  const LearningPage({super.key});

  @override
  ConsumerState<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends ConsumerState<LearningPage> {
  bool isExpanded = true;
  final ScrollController _scrollController = ScrollController();
  OverlayEntry? _levelUpOverlay;
  OverlayEntry? _journeyCompleteOverlay;

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
    _levelUpOverlay?.remove();
    _journeyCompleteOverlay?.remove();
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

  void _showLevelUpCelebration(GamificationEvent event) {
    if (_levelUpOverlay != null) return;
    
    _levelUpOverlay = OverlayEntry(
      builder: (context) => LevelUpCelebration(
        level: event.level,
        levelTitle: event.levelTitle,
        xpEarned: event.xpEarned,
        onComplete: () {
          _levelUpOverlay?.remove();
          _levelUpOverlay = null;
          ref.read(gamificationEventProvider.notifier).dismiss();
        },
      ),
    );
    Overlay.of(context).insert(_levelUpOverlay!);
  }

  void _showJourneyCompleteCelebration(JourneyCompleteEvent event) {
    if (_journeyCompleteOverlay != null) return;
    
    _journeyCompleteOverlay = OverlayEntry(
      builder: (context) => JourneyCompleteCelebration(
        topic: event.topic,
        totalSteps: event.totalSteps,
        totalXp: event.totalXp,
        bonusXp: event.bonusXp,
        averageQuizScore: event.averageQuizScore,
        onReview: () {
          _journeyCompleteOverlay?.remove();
          _journeyCompleteOverlay = null;
          ref.read(journeyCompleteProvider.notifier).dismiss();
        },
        onNewTopic: () {
          _journeyCompleteOverlay?.remove();
          _journeyCompleteOverlay = null;
          ref.read(journeyCompleteProvider.notifier).dismiss();
          ref.read(activeSessionProvider.notifier).clearSession();
        },
      ),
    );
    Overlay.of(context).insert(_journeyCompleteOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GamificationEvent?>(gamificationEventProvider, (previous, next) {
      if (next != null) {
        // Ensure this runs after the current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
           _showLevelUpCelebration(next);
        });
      }
    });

    ref.listen<JourneyCompleteEvent?>(journeyCompleteProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showJourneyCompleteCelebration(next);
        });
      }
    });

    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textSecondary),
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
                color: AppColors.sidebarBackground,
                border: Border(
                  right: BorderSide(
                    color: AppColors.glassBorder,
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
