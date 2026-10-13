import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glow_background.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/providers/learning_provider.dart';
import 'package:devzees_edutechai_client/core/providers/gamification_provider.dart';
import 'package:devzees_edutechai_client/core/providers/auth_provider.dart';
import 'package:devzees_edutechai_client/presentation/widgets/shimmer_app_shell.dart';

import 'widgets/sidebar/learning_sidebar.dart';
import 'widgets/main_content/learning_main_content.dart';
import 'widgets/gamification/level_up_celebration.dart';
import 'widgets/gamification/journey_complete_celebration.dart';
import 'package:devzees_edutechai_client/core/providers/active_session_provider.dart';
import 'package:devzees_edutechai_client/core/providers/theme_provider.dart';
import 'widgets/mobile/mobile_learning_top_bar.dart';
import 'widgets/mobile/mobile_command_hub_sheet.dart';

class LearningPage extends ConsumerStatefulWidget {
  const LearningPage({super.key});

  @override
  ConsumerState<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends ConsumerState<LearningPage> {
  bool isExpanded = true;
  OverlayEntry? _levelUpOverlay;
  bool _isJourneyCompleteDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionsProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _levelUpOverlay?.remove();
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
    if (_isJourneyCompleteDialogOpen || !mounted) return;
    _isJourneyCompleteDialogOpen = true;

    showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return JourneyCompleteCelebration(
          sessionId: event.sessionId,
          topic: event.topic,
          totalSteps: event.totalSteps,
          totalXp: event.totalXp,
          bonusXp: event.bonusXp,
          averageQuizScore: event.averageQuizScore,
          onReview: () {
            ref.read(activeSessionProvider.notifier).ensureJourneyCompleted();
            if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }
          },
          onNewTopic: () {
            ref.read(activeSessionProvider.notifier).ensureJourneyCompleted();
            ref.read(activeSessionProvider.notifier).clearSession();
            if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }
          },
        );
      },
    ).then((_) {
      _isJourneyCompleteDialogOpen = false;
      ref.read(journeyCompleteProvider.notifier).dismiss();
      ref.read(activeSessionProvider.notifier).ensureJourneyCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);
    AppColors.setBrightness(isDark ? Brightness.dark : Brightness.light);
    final isAuthInitial = ref.watch(authProvider.select((s) => s.isInitial));

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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isAuthInitial
          ? const ShimmerAppShell(key: ValueKey('shimmer_skeleton'))
          : KeyedSubtree(
              key: ValueKey('learning_content_${themeMode.name}'),
              child: _buildScaffold(context),
            ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      final activeState = ref.watch(activeSessionProvider);
      final session = activeState.session;
      final int maxUnlockedIndex = session != null
          ? (session.currentStepIndex > session.stepsCompleted
                  ? session.currentStepIndex
                  : session.stepsCompleted)
              .clamp(0, session.steps.isNotEmpty ? session.steps.length - 1 : 0)
          : 0;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: MobileLearningTopBar(
          session: session,
          activeStepIndex: activeState.activeStepIndex,
          onOpenCommandHub: session != null
              ? () {
                  MobileCommandHubSheet.show(
                    context,
                    session: session,
                    activeIndex: activeState.activeStepIndex,
                    maxUnlockedIndex: maxUnlockedIndex,
                    onStepTapped: (index) {
                      ref.read(activeSessionProvider.notifier).setActiveStep(index);
                    },
                  );
                }
              : null,
        ),
        drawer: Drawer(
          backgroundColor: AppColors.sidebarBackground,
          child: LearningSidebar(
            expanded: true,
            isMobile: true,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
