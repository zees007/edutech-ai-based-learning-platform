import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/providers/gamification_provider.dart';

class LevelUpCelebration extends StatefulWidget {
  final int level;
  final String levelTitle;
  final String? levelDescription;
  final int xpEarned;
  final int totalXp;
  final String? source; // 'quiz' or 'step'
  final double? quizScore;
  final int? quizCorrectCount;
  final int? quizTotalQuestions;
  final int? streakCount;
  final int? streakBonusXp;
  final VoidCallback onComplete;

  const LevelUpCelebration({
    super.key,
    required this.level,
    required this.levelTitle,
    this.levelDescription,
    required this.xpEarned,
    this.totalXp = 0,
    this.source,
    this.quizScore,
    this.quizCorrectCount,
    this.quizTotalQuestions,
    this.streakCount,
    this.streakBonusXp,
    required this.onComplete,
  });

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isDismissed = false;
  bool _isHovered = false;
  int _remainingSeconds = 6;
  Timer? _countdownTimer;

  void _dismiss() {
    if (_isDismissed) return;
    _isDismissed = true;
    _countdownTimer?.cancel();
    _controller
        .animateBack(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInCubic,
        )
        .then((_) {
          if (mounted) {
            widget.onComplete();
          }
        });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.08,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();

    // Auto-dismiss countdown with hover pause support
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isHovered) {
        // Paused while hovered — do not decrement countdown or dismiss
        return;
      }
      setState(() {
        if (_remainingSeconds > 1) {
          _remainingSeconds--;
        } else {
          _remainingSeconds = 0;
          timer.cancel();
          _dismiss();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final effectiveTotalXp = widget.totalXp > 0
        ? widget.totalXp
        : widget.xpEarned;
    final levelData = GamificationUtils.calculateLevelData(effectiveTotalXp);
    final bool isMaxLevel = levelData['is_max_level'] as bool;
    final double progress = (levelData['progress'] as num).toDouble();
    final int currentTotal = levelData['total_xp'] as int;
    final int remainingXp =
        (levelData['xp_needed_for_next'] as int) -
        (levelData['xp_in_level'] as int);
    final int nextLevelNum = (levelData['level'] as int) + 1;
    final String nextLevelTitle = GamificationUtils.getLevelTitle(nextLevelNum);

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _dismiss,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ─── Glassmorphism backdrop ─────────────────────────
              FadeTransition(
                opacity: _fadeAnimation,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(color: Colors.black.withValues(alpha: 0.65)),
                ),
              ),

              // ─── Modal Card with Celebratory Gradient ───────────
              SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isHovered = true),
                    onExit: (_) => setState(() => _isHovered = false),
                    child: GestureDetector(
                      onTap: () {}, // Prevent taps inside modal from closing
                      child: Container(
                        width: isMobile ? double.infinity : 480,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.9,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(
                                0xFF6B46C1,
                              ).withValues(alpha: 0.95), // Vibrant Purple
                              const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.95), // Vibrant Blue
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF6B46C1,
                              ).withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            children: [
                              // Glowing header aura
                              Positioned(
                                top: -50,
                                left: 0,
                                right: 0,
                                height: 140,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.25),
                                        Colors.transparent,
                                      ],
                                      radius: 0.8,
                                    ),
                                  ),
                                ),
                              ),

                              SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 18 : 28,
                                  vertical: isMobile ? 20 : 26,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // ─── Top Bar: Badge & Close Button ───
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.35,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.auto_awesome_rounded,
                                                size: 13,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                'LEVEL UP!',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: 1.2,
                                                      fontSize: 10.5,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            size: 20,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                          onPressed: _dismiss,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Dismiss',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // ─── Hero Emblem & Level Title ───
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.amber,
                                            Color(0xFFF59E0B),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.amber.withValues(
                                              alpha: 0.45,
                                            ),
                                            blurRadius: 22,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                          width: 2.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.stars_rounded,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    Text(
                                      'Level ${widget.level}',
                                      style: AppTextStyles.subtitle2.copyWith(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    Text(
                                      widget.levelTitle,
                                      style: AppTextStyles.h3.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: isMobile ? 24 : 28,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),

                                    Text(
                                      widget.levelDescription ??
                                          GamificationUtils.getLevelDescription(
                                            widget.level,
                                          ),
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12.5,
                                        height: 1.35,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),

                                    // ─── Milestone XP Breakdown Card ───
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.bolt_rounded,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'XP Earned This Milestone',
                                                    style: AppTextStyles.label
                                                        .copyWith(
                                                          color: Colors.white
                                                              .withValues(
                                                                alpha: 0.9,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '+${widget.xpEarned} XP',
                                                style: AppTextStyles.body2
                                                    .copyWith(
                                                      color: Colors.greenAccent,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: Divider(
                                              color: Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                              height: 1,
                                            ),
                                          ),
                                          _buildBreakdownItems(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // ─── Next Level Runway & Progress Bar ───
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                isMaxLevel
                                                    ? 'Apex Level Achieved 🏆'
                                                    : 'Next: Level $nextLevelNum ($nextLevelTitle)',
                                                style: AppTextStyles.label
                                                    .copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              Text(
                                                isMaxLevel
                                                    ? '100%'
                                                    : '${(progress * 100).toInt()}%',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color: Colors.amber,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 6,
                                              backgroundColor: Colors.white
                                                  .withValues(alpha: 0.15),
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(Colors.amber),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total: $currentTotal XP',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.75,
                                                          ),
                                                    ),
                                              ),
                                              Text(
                                                isMaxLevel
                                                    ? 'Grand Sage Max'
                                                    : '$remainingXp XP to Level $nextLevelNum',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color: Colors.amber,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // ─── Primary Action Button ───
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: _dismiss,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(
                                            0xFF6B46C1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Continue Learning',
                                              style: AppTextStyles.button
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFF6B46C1,
                                                    ),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16,
                                              color: Color(0xFF6B46C1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // ─── Auto-dismiss timer hint ───
                                    Text(
                                      _isHovered
                                          ? 'Auto-advance paused • Tap or click Continue Learning'
                                          : 'Auto-advancing in $_remainingSeconds seconds • Tap anywhere to continue',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownItems() {
    if (widget.source == 'quiz') {
      final correctCount = widget.quizCorrectCount ?? 3;
      final totalCount = widget.quizTotalQuestions ?? 3;
      final bool isPerfect = (widget.quizScore ?? 1.0) >= 1.0;
      final int baseQuizXp = correctCount * 20;

      return Column(
        children: [
          _buildBreakdownRow(
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.white.withValues(alpha: 0.8),
            title: '$correctCount of $totalCount Quiz Questions Correct',
            rewardText: '+$baseQuizXp XP',
          ),
          if (isPerfect) ...[
            const SizedBox(height: 6),
            _buildBreakdownRow(
              icon: Icons.verified_rounded,
              iconColor: Colors.amber,
              title: '100% Quiz Accuracy Bonus',
              rewardText: '+10 XP',
            ),
          ],
        ],
      );
    }

    if (widget.source == 'step') {
      final int streakBonus = widget.streakBonusXp ?? 0;
      final int streakCount = widget.streakCount ?? 0;

      return Column(
        children: [
          _buildBreakdownRow(
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.white.withValues(alpha: 0.8),
            title: 'Milestone Step Mastered',
            rewardText: '+10 XP',
          ),
          if (streakBonus > 0) ...[
            const SizedBox(height: 6),
            _buildBreakdownRow(
              icon: Icons.local_fire_department_rounded,
              iconColor: Colors.amber,
              title: '$streakCount-Day Daily Streak Multiplier Bonus',
              rewardText: '+$streakBonus XP',
            ),
          ],
        ],
      );
    }

    // Default / fallback
    return _buildBreakdownRow(
      icon: Icons.stars_rounded,
      iconColor: Colors.amber,
      title: 'Milestone Mastery Reward',
      rewardText: '+${widget.xpEarned} XP',
    );
  }

  Widget _buildBreakdownRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String rewardText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 7),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Text(
          rewardText,
          style: AppTextStyles.captionBold.copyWith(
            color: Colors.greenAccent,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
