import 'package:flutter/material.dart';
import '../../../../../data/models/learning/milestone_step.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

/// An ultra-premium, modern Chevron Pipeline Stepper.
/// Displays milestone roadmap steps as an interlocking, continuous chevron ribbon
/// inspired by enterprise workflow breadcrumb designs.
class MilestoneRoadmapStepper extends StatefulWidget {
  final List<MilestoneStep> steps;
  final int activeIndex;
  final int maxUnlockedIndex;
  final ValueChanged<int> onStepTapped;

  const MilestoneRoadmapStepper({
    super.key,
    required this.steps,
    required this.activeIndex,
    this.maxUnlockedIndex = 0,
    required this.onStepTapped,
  });

  static const double _arrowWidth = 14.0;
  static const double _stepperHeight = 52.0;
  static const double _minItemWidth = 145.0;

  @override
  State<MilestoneRoadmapStepper> createState() => _MilestoneRoadmapStepperState();
}

class _MilestoneRoadmapStepperState extends State<MilestoneRoadmapStepper> {
  final ScrollController _scrollController = ScrollController();
  double _lastAvailableWidth = 0.0;
  double _lastEffectiveItemWidth = 165.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveStep(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveStep({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final double availableWidth = _lastAvailableWidth;
    if (availableWidth <= 0) return;

    final int index = widget.activeIndex;
    final double effectiveItemWidth = _lastEffectiveItemWidth;
    final double stepPitch = effectiveItemWidth - MilestoneRoadmapStepper._arrowWidth;

    // Center the active step horizontally in the available viewport
    final double itemCenter = index * stepPitch + (effectiveItemWidth / 2);
    final double targetOffset = (itemCenter - (availableWidth / 2))
        .clamp(0.0, _scrollController.position.maxScrollExtent);

    if (animate) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  @override
  void didUpdateWidget(covariant MilestoneRoadmapStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex ||
        oldWidget.steps.length != widget.steps.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveStep(animate: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxUnlocked = widget.maxUnlockedIndex.clamp(0, widget.steps.length - 1);
    final int count = widget.steps.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        // Total formula: totalWidth = N * itemWidth - (N - 1) * arrowWidth
        // => itemWidth = (totalWidth + (N - 1) * arrowWidth) / N
        final double calculatedItemWidth = count > 1
            ? (availableWidth + (count - 1) * MilestoneRoadmapStepper._arrowWidth) / count
            : availableWidth;

        final bool fitsInAvailableWidth = calculatedItemWidth >= MilestoneRoadmapStepper._minItemWidth;
        final double effectiveItemWidth =
            fitsInAvailableWidth ? calculatedItemWidth : 165.0;
        final double totalContentWidth = count > 1
            ? (count * effectiveItemWidth - (count - 1) * MilestoneRoadmapStepper._arrowWidth)
            : effectiveItemWidth;

        _lastAvailableWidth = availableWidth;
        _lastEffectiveItemWidth = effectiveItemWidth;

        Widget content = SizedBox(
          width: totalContentWidth,
          height: MilestoneRoadmapStepper._stepperHeight,
          child: Stack(
            children: List.generate(count, (index) {
              final step = widget.steps[index];
              final bool isActive = index == widget.activeIndex;
              final bool isCompleted =
                  step.status == 'complete' || index < maxUnlocked;
              final bool isUnlocked = index <= maxUnlocked ||
                  isCompleted ||
                  step.status == 'in_progress';
              final bool isLocked = !isUnlocked;
              final bool isFirst = index == 0;
              final bool isLast = index == count - 1;

              final double leftPos =
                  index * (effectiveItemWidth - MilestoneRoadmapStepper._arrowWidth);

              return Positioned(
                left: leftPos,
                top: 0,
                bottom: 0,
                width: effectiveItemWidth,
                child: _ChevronStepItem(
                  index: index,
                  step: step,
                  isActive: isActive,
                  isCompleted: isCompleted,
                  isUnlocked: isUnlocked,
                  isLocked: isLocked,
                  isFirst: isFirst,
                  isLast: isLast,
                  arrowWidth: MilestoneRoadmapStepper._arrowWidth,
                  onTap: isLocked ? null : () => widget.onStepTapped(index),
                ),
              );
            }),
          ),
        );

        return Container(
          height: MilestoneRoadmapStepper._stepperHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceDeep,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: fitsInAvailableWidth
              ? content
              : SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: content,
                ),
        );
      },
    );
  }
}

/// An individual interactive chevron segment
class _ChevronStepItem extends StatefulWidget {
  final int index;
  final MilestoneStep step;
  final bool isActive;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isLocked;
  final bool isFirst;
  final bool isLast;
  final double arrowWidth;
  final VoidCallback? onTap;

  const _ChevronStepItem({
    required this.index,
    required this.step,
    required this.isActive,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isLocked,
    required this.isFirst,
    required this.isLast,
    required this.arrowWidth,
    required this.onTap,
  });

  @override
  State<_ChevronStepItem> createState() => _ChevronStepItemState();
}

class _ChevronStepItemState extends State<_ChevronStepItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isActive;
    final bool isCompleted = widget.isCompleted;
    final bool isLocked = widget.isLocked;
    final bool isFirst = widget.isFirst;
    final bool isLast = widget.isLast;
    final double arrowWidth = widget.arrowWidth;

    // Tooltip message
    final InlineSpan tooltipRichMsg;
    if (isLocked) {
      tooltipRichMsg = TextSpan(text: '🔒 Step ${widget.index + 1}${widget.step.isPrerequisite ? " • Prerequisite" : ""}: Complete previous step to unlock\n${widget.step.title}');
    } else if (isActive) {
      tooltipRichMsg = TextSpan(text: '⭐ Active (Step ${widget.index + 1}${widget.step.isPrerequisite ? " • Prerequisite" : ""})\n${widget.step.title}\n${widget.step.description}');
    } else if (isCompleted) {
      tooltipRichMsg = TextSpan(
        children: [
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.only(right: 4.0),
              child: Icon(Icons.check_circle_rounded, size: 14, color: AppColors.greenMint),
            ),
          ),
          TextSpan(text: 'Completed (Step ${widget.index + 1}${widget.step.isPrerequisite ? " • Prerequisite" : ""}) — Tap to review\n${widget.step.title}'),
        ],
      );
    } else {
      tooltipRichMsg = TextSpan(text: '⚡ Step ${widget.index + 1}${widget.step.isPrerequisite ? " • Prerequisite" : ""}\n${widget.step.title}\n${widget.step.description}');
    }

    // Status icon
    final Widget statusIcon = Icon(
      isCompleted
          ? Icons.check_circle_rounded
          : (isActive
              ? Icons.explore_rounded
              : (isLocked ? Icons.lock_rounded : Icons.bolt_rounded)),
      size: 13,
      color: isActive
          ? Colors.white
          : (isCompleted
              ? Colors.white
              : (isLocked
                  ? Colors.white.withValues(alpha: 0.35)
                  : AppColors.purpleLight)),
    );

    // Primary Text Color
    final Color stepColor = isActive
        ? Colors.white
        : (isCompleted
            ? AppColors.greenMint
            : (isLocked
                ? Colors.white.withValues(alpha: 0.4)
                : AppColors.purpleLight));

    final Color titleColor = isActive
        ? Colors.white
        : (isCompleted
            ? Colors.white
            : (isLocked
                ? Colors.white.withValues(alpha: 0.35)
                : AppColors.slate200));

    // Background decoration
    Decoration backgroundDecoration;
    if (isActive) {
      backgroundDecoration = BoxDecoration(
        gradient: AppColors.royalBlueIndigoGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 1),
          ),
        ],
      );
    } else if (isCompleted) {
      // Vibrant Glassy Green (solid emerald base that does not let dark background bleed through)
      backgroundDecoration = BoxDecoration(
        gradient: AppColors.emeraldGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGreen.withValues(alpha: _isHovered ? 0.45 : 0.28),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      );
    } else if (!isLocked) {
      backgroundDecoration = BoxDecoration(
        color: _isHovered
            ? AppColors.surfaceMid.withValues(alpha: 0.85)
            : AppColors.surfaceMid.withValues(alpha: 0.50),
      );
    } else {
      backgroundDecoration = BoxDecoration(
        color: _isHovered
            ? AppColors.surfaceDark.withValues(alpha: 0.6)
            : Colors.transparent,
      );
    }

    // Divider color at the right arrow tip
    final Color dividerColor = isActive
        ? AppColors.blueSoft.withValues(alpha: 0.8)
        : (isCompleted
            ? AppColors.greenMint.withValues(alpha: 0.75)
            : Colors.white.withValues(alpha: 0.15));

    // Operational status label & badge styling
    final String statusLabel;
    final Color statusBadgeBg;
    final Color statusBadgeBorder;
    final Color statusBadgeText;

    if (isCompleted) {
      statusLabel = 'COMPLETED';
      statusBadgeBg = Colors.white.withValues(alpha: 0.20);
      statusBadgeBorder = Colors.white.withValues(alpha: 0.40);
      statusBadgeText = Colors.white;
    } else if (isActive || widget.step.status == 'in_progress') {
      statusLabel = 'IN PROGRESS';
      statusBadgeBg = Colors.white.withValues(alpha: 0.22);
      statusBadgeBorder = Colors.white.withValues(alpha: 0.45);
      statusBadgeText = Colors.white;
    } else if (isLocked) {
      statusLabel = 'LOCKED';
      statusBadgeBg = Colors.white.withValues(alpha: 0.06);
      statusBadgeBorder = Colors.white.withValues(alpha: 0.15);
      statusBadgeText = Colors.white.withValues(alpha: 0.45);
    } else {
      statusLabel = 'PENDING';
      statusBadgeBg = AppColors.purpleLight.withValues(alpha: 0.15);
      statusBadgeBorder = AppColors.purpleLight.withValues(alpha: 0.35);
      statusBadgeText = AppColors.lavender;
    }

    final clipper = _ChevronClipper(
      isFirst: isFirst,
      isLast: isLast,
      arrowWidth: arrowWidth,
    );

    return Tooltip(
      richMessage: tooltipRichMsg,
      child: MouseRegion(
        cursor: isLocked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            children: [
              // 1. Clipped Background Fill
              Positioned.fill(
                child: ClipPath(
                  clipper: clipper,
                  child: Container(
                    decoration: backgroundDecoration,
                  ),
                ),
              ),

              // 2. Chevron Divider Line (on right edge if not last)
              if (!isLast)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ChevronDividerPainter(
                      dividerColor: dividerColor,
                      arrowWidth: arrowWidth,
                      strokeWidth: isActive ? 2.0 : 1.2,
                    ),
                  ),
                ),

              // 3. Step Content (Padded to clear the arrow indent & tip)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isFirst ? 14.0 : (arrowWidth + 8.0),
                    right: isLast ? 14.0 : (arrowWidth + 8.0),
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top Row: Status Icon + Step Label + Prereq Tag + Status Badge
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            statusIcon,
                            const SizedBox(width: 5),
                            Text(
                              'STEP ${widget.index + 1}',
                              style: AppTextStyles.badge.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: stepColor,
                              ),
                            ),
                            if (widget.step.isPrerequisite) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  gradient: AppColors.amberGradient,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  'PREREQ',
                                  style: AppTextStyles.badge.copyWith(
                                    color: Colors.white,
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.5, vertical: 1),
                              decoration: BoxDecoration(
                                color: statusBadgeBg,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                    color: statusBadgeBorder, width: 0.6),
                              ),
                              child: Text(
                                statusLabel,
                                style: AppTextStyles.badge.copyWith(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                  color: statusBadgeText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Bottom: Title
                      Text(
                        widget.step.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11.5,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          color: titleColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom clipper that cuts out the chevron shape with interlocking left indent and right arrow tip.
class _ChevronClipper extends CustomClipper<Path> {
  final bool isFirst;
  final bool isLast;
  final double arrowWidth;

  const _ChevronClipper({
    required this.isFirst,
    required this.isLast,
    required this.arrowWidth,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double d = arrowWidth;

    // Start at Top-Left
    if (isFirst) {
      path.moveTo(0, 0);
      path.lineTo(0, h);
    } else {
      // Indent going to the right
      path.moveTo(0, 0);
      path.lineTo(d, h / 2);
      path.lineTo(0, h);
    }

    // Bottom-Right
    if (isLast) {
      path.lineTo(w, h);
      path.lineTo(w, 0);
    } else {
      // Arrow pointing to the right
      path.lineTo(w - d, h);
      path.lineTo(w, h / 2);
      path.lineTo(w - d, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _ChevronClipper oldClipper) => true;
}

/// Paints a crisp chevron divider stroke along the right edge
class _ChevronDividerPainter extends CustomPainter {
  final Color dividerColor;
  final double arrowWidth;
  final double strokeWidth;

  const _ChevronDividerPainter({
    required this.dividerColor,
    required this.arrowWidth,
    this.strokeWidth = 1.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dividerColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final path = Path();
    path.moveTo(size.width - arrowWidth, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - arrowWidth, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronDividerPainter oldDelegate) =>
      oldDelegate.dividerColor != dividerColor ||
      oldDelegate.arrowWidth != arrowWidth ||
      oldDelegate.strokeWidth != strokeWidth;
}
