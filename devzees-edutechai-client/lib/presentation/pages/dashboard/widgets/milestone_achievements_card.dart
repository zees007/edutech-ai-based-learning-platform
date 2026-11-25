import 'package:flutter/material.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_palette.dart';
import '../../../../core/utils/trophy_utils.dart';
import '../../../../data/models/dashboard/dashboard_response.dart';

/// Reusable gamified card showcasing milestone achievements and prestige trophy case.
///
/// Features:
/// - Distinct visual states for unlocked vs locked trophies:
///   - Unlocked: Glorious 24K golden look with radiant aura, gold gradient border,
///     vibrant 3D trophy asset, gold verified badge, and UNLOCKED prestige pill.
///   - Locked: Grayed-out monochrome desaturated trophy artwork with a prominent
///     lock badge on the crest, LOCKED pill, and frosted slate backdrop.
/// - Full fidelity 3D trophy images rendered from asset bundle with graceful vector fallback.
/// - Milestone progress bar with percentage indicator.
/// - Responsive grid: 3 columns on desktop, 2 columns on tablet/wide mobile, 1 on narrow mobile.
class MilestoneAchievementsCard extends StatefulWidget {
  final List<AchievementItem> achievements;
  final String title;
  final String subtitle;
  final int? crossAxisCount;

  const MilestoneAchievementsCard({
    super.key,
    required this.achievements,
    this.title = 'Learner Achievements & Trophies',
    this.subtitle =
        'Earn honorary trophies by staying consistent in your studies and achieving quiz excellence',
    this.crossAxisCount,
  });

  @override
  State<MilestoneAchievementsCard> createState() =>
      _MilestoneAchievementsCardState();
}

class _MilestoneAchievementsCardState extends State<MilestoneAchievementsCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final achievements = widget.achievements;
    final unlockedCount = achievements.where((a) => a.unlocked).length;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = Responsive.isMobile(context);
    final isNarrow = screenWidth < 400;
    final int cols =
        widget.crossAxisCount ??
        (Responsive.isDesktop(context) ? 3 : (screenWidth >= 520 ? 2 : 1));

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: context.appColors.border) : null,
        boxShadow: context.appColors.cardShadow,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          if (isNarrow) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFFD97706))
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: isMobile ? 16 : 18,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: AppTextStyles.body2.copyWith(
                              color: context.appColors.textSecondary,
                              fontSize: isMobile ? 12 : 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildUnlockCounterBadge(
                  isDark,
                  isMobile,
                  unlockedCount,
                  achievements.length,
                ),
              ],
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (isDark
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFD97706))
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFD97706),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 16 : 18,
                          color: isDark
                              ? context.appColors.textPrimary
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: AppTextStyles.body2.copyWith(
                          color: isDark
                              ? context.appColors.textSecondary
                              : const Color(0xFF64748B),
                          fontSize: isMobile ? 12 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildUnlockCounterBadge(
                  isDark,
                  isMobile,
                  unlockedCount,
                  achievements.length,
                ),
              ],
            ),
          ],

          if (achievements.isNotEmpty) ...[
            const SizedBox(height: 14),
            // Overall Milestone Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: achievements.isEmpty
                          ? 0.0
                          : (unlockedCount / achievements.length).clamp(
                              0.0,
                              1.0,
                            ),
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${achievements.isEmpty ? 0 : ((unlockedCount / achievements.length) * 100).toInt()}% Complete',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFD97706),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Achievements Grid or Empty State
          if (achievements.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.military_tech_outlined,
                    size: 36,
                    color: isDark
                        ? context.appColors.textSecondary
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No milestone achievements available.',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? context.appColors.textSecondary
                          : const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < achievements.length; i += cols) ...[
                  if (i > 0) const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int j = 0; j < cols; j++) ...[
                          if (j > 0) const SizedBox(width: 12),
                          if (i + j < achievements.length)
                            Expanded(
                              child: _AchievementTile(
                                achievement: achievements[i + j],
                                isDark: isDark,
                                isMobile: isMobile || cols == 3,
                              ),
                            )
                          else
                            const Expanded(child: SizedBox.shrink()),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUnlockCounterBadge(
    bool isDark,
    bool isMobile,
    int unlockedCount,
    int totalCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.15),
            const Color(0xFFD97706).withValues(alpha: isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(
            0xFFF59E0B,
          ).withValues(alpha: isDark ? 0.45 : 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 14,
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(width: 5),
          Text(
            '$unlockedCount / $totalCount Unlocked',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive achievement tile with 3D artwork, golden prestige glow or grayed-out locked state.
class _AchievementTile extends StatefulWidget {
  final AchievementItem achievement;
  final bool isDark;
  final bool isMobile;

  const _AchievementTile({
    required this.achievement,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_AchievementTile> createState() => _AchievementTileState();
}

class _AchievementTileState extends State<_AchievementTile> {
  bool _isHovered = false;

  static const ColorFilter _grayscaleFilter = ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  String? _getAssetPath(String id, String icon) {
    final cleanId = id.toLowerCase().trim();
    final cleanIcon = icon.toLowerCase().trim();

    const assetMap = {
      'bronze': 'assets/images/gamification/trophy_bronze.png',
      'silver': 'assets/images/gamification/trophy_silver.png',
      'gold': 'assets/images/gamification/trophy_gold.png',
      'platinum': 'assets/images/gamification/trophy_platinum.png',
      'sapphire': 'assets/images/gamification/trophy_sapphire.png',
      'diamond': 'assets/images/gamification/trophy_diamond.png',
    };

    if (assetMap.containsKey(cleanId)) return assetMap[cleanId];
    if (assetMap.containsKey(cleanIcon)) return assetMap[cleanIcon];

    final style = getTrophyStyle(cleanId.isNotEmpty ? cleanId : cleanIcon);
    if (style.assetPath != null) return style.assetPath;

    if (cleanId == 'trophy' || cleanIcon == 'trophy') {
      return 'assets/images/gamification/trophy_gold.png';
    }

    return null;
  }

  String _getTierLabel(String id) {
    switch (id.toLowerCase().trim()) {
      case 'bronze':
        return 'TIER I • BRONZE';
      case 'silver':
        return 'TIER II • SILVER';
      case 'gold':
        return 'TIER III • GOLD';
      case 'platinum':
        return 'TIER IV • PLATINUM';
      case 'sapphire':
        return 'TIER V • SAPPHIRE';
      case 'diamond':
        return 'TIER VI • DIAMOND';
      default:
        return 'PRESTIGE MILESTONE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ach = widget.achievement;
    final isUnlocked = ach.unlocked;
    final isDark = widget.isDark;
    final isMobile = widget.isMobile;

    final assetPath = _getAssetPath(ach.id, ach.icon);
    final fallbackStyle = getTrophyStyle(
      ach.icon.isNotEmpty ? ach.icon : ach.id,
    );
    final tierLabel = _getTierLabel(ach.id);

    final crestSize = isMobile ? 48.0 : 54.0;
    final imageSize = isMobile ? 38.0 : 44.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => setState(() => _isHovered = !_isHovered),
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Container(
            constraints: const BoxConstraints(minHeight: 90),
            padding: EdgeInsets.all(isMobile ? 10 : 13),
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(
                                0xFF261D12,
                              ).withValues(alpha: _isHovered ? 0.85 : 0.70),
                              const Color(
                                0xFF181512,
                              ).withValues(alpha: _isHovered ? 0.95 : 0.85),
                            ]
                          : [
                              const Color(0xFFFFFBEB),
                              const Color(
                                0xFFFEF3C7,
                              ).withValues(alpha: _isHovered ? 0.85 : 0.65),
                            ],
                    )
                  : null,
              color: isUnlocked
                  ? null
                  : (isDark
                        ? const Color(
                            0xFF131520,
                          ).withValues(alpha: _isHovered ? 0.75 : 0.55)
                        : const Color(
                            0xFFF8FAFC,
                          ).withValues(alpha: _isHovered ? 0.95 : 0.85)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked
                    ? const Color(0xFFF59E0B).withValues(
                        alpha: isDark
                            ? (_isHovered ? 0.75 : 0.50)
                            : (_isHovered ? 0.70 : 0.45),
                      )
                    : (isDark
                          ? const Color(
                              0xFF282D42,
                            ).withValues(alpha: _isHovered ? 0.85 : 0.55)
                          : const Color(0xFFE2E8F0)),
                width: isUnlocked ? 1.2 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isUnlocked
                      ? const Color(0xFFF59E0B).withValues(
                          alpha: isDark
                              ? (_isHovered ? 0.35 : 0.20)
                              : (_isHovered ? 0.28 : 0.14),
                        )
                      : Colors.black.withValues(
                          alpha: _isHovered
                              ? (isDark ? 0.35 : 0.12)
                              : (isDark ? 0.15 : 0.04),
                        ),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: Offset(0, _isHovered ? 6 : 3),
                ),
                if (isUnlocked)
                  BoxShadow(
                    color: const Color(
                      0xFFFFD700,
                    ).withValues(alpha: isDark ? 0.15 : 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3D Trophy Crest Artwork (with golden halo if unlocked, or desaturated + lock badge if locked)
                SizedBox(
                  width: crestSize,
                  height: crestSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: crestSize,
                        height: crestSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isUnlocked
                              ? RadialGradient(
                                  colors: [
                                    const Color(0xFFFFD700).withValues(
                                      alpha: isDark
                                          ? (_isHovered ? 0.45 : 0.35)
                                          : (_isHovered ? 0.38 : 0.28),
                                    ),
                                    const Color(0xFFF59E0B).withValues(
                                      alpha: isDark
                                          ? (_isHovered ? 0.25 : 0.18)
                                          : (_isHovered ? 0.18 : 0.12),
                                    ),
                                    Colors.transparent,
                                  ],
                                  radius: 0.85,
                                )
                              : null,
                          color: isUnlocked
                              ? null
                              : (isDark
                                    ? const Color(0xFF1B1E30)
                                    : const Color(0xFFF1F5F9)),
                          border: Border.all(
                            color: isUnlocked
                                ? const Color(
                                    0xFFFFD700,
                                  ).withValues(alpha: isDark ? 0.70 : 0.55)
                                : (isDark
                                      ? const Color(0xFF2E334D)
                                      : const Color(0xFFCBD5E1)),
                            width: isUnlocked ? 1.5 : 1.0,
                          ),
                          boxShadow: isUnlocked
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: isDark ? 0.35 : 0.22),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: _buildTrophyVisual(
                            isUnlocked: isUnlocked,
                            isDark: isDark,
                            assetPath: assetPath,
                            fallbackStyle: fallbackStyle,
                            imageSize: imageSize,
                          ),
                        ),
                      ),

                      // Crest Overlay Badge:
                      // Unlocked -> Golden checkmark/star badge
                      // Locked -> Padlock icon badge
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: isUnlocked
                            ? Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? const Color(0xFF1C1917)
                                      : Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFF59E0B,
                                      ).withValues(alpha: 0.40),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.verified_rounded,
                                  size: 13,
                                  color: Color(0xFFF59E0B),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? const Color(0xFF0F111D)
                                      : const Color(0xFFE2E8F0),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFF94A3B8),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.lock_rounded,
                                  size: 11,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Content Column: Tier, Title, Description, and Badges with full expansion on hover
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Row: Tier Label & UNLOCKED / LOCKED Badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tierLabel,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                  color: isUnlocked
                                      ? (isDark
                                            ? const Color(0xFFFBBF24)
                                            : const Color(0xFFD97706))
                                      : (isDark
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF94A3B8)),
                                ),
                                maxLines: _isHovered ? null : 1,
                                overflow: _isHovered
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF59E0B),
                                      Color(0xFFD97706),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFF59E0B,
                                      ).withValues(alpha: 0.30),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'UNLOCKED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.08),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      size: 9.5,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 3.5),
                                    Text(
                                      'LOCKED',
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Trophy Title: full text on hover
                        Text(
                          ach.title,
                          style: AppTextStyles.label.copyWith(
                            color: isUnlocked
                                ? (isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A))
                                : (isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B)),
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                          maxLines: _isHovered ? null : 1,
                          overflow: _isHovered
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),

                        // Description / Unlock Criteria: full text on hover
                        Text(
                          ach.description,
                          style: AppTextStyles.caption.copyWith(
                            color: isUnlocked
                                ? (isDark
                                      ? context.appColors.textSecondary
                                      : const Color(0xFF475569))
                                : (isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8)),
                            fontSize: 11,
                            height: 1.35,
                          ),
                          maxLines: _isHovered ? null : 2,
                          overflow: _isHovered
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrophyVisual({
    required bool isUnlocked,
    required bool isDark,
    required String? assetPath,
    required TrophyStyle fallbackStyle,
    required double imageSize,
  }) {
    final Widget rawVisual = assetPath != null
        ? Image.asset(
            assetPath,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              fallbackStyle.icon,
              size: imageSize * 0.6,
              color: isUnlocked
                  ? const Color(0xFFF59E0B)
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
            ),
          )
        : Icon(
            fallbackStyle.icon,
            size: imageSize * 0.6,
            color: isUnlocked
                ? const Color(0xFFF59E0B)
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          );

    if (!isUnlocked) {
      return ColorFiltered(
        colorFilter: _grayscaleFilter,
        child: Opacity(opacity: isDark ? 0.38 : 0.45, child: rawVisual),
      );
    }

    return rawVisual;
  }
}
