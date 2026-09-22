import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/constants/responsive.dart';
import 'plan_card.dart';
import 'mobile_plan_deck.dart';

class SubscriptionModal extends ConsumerWidget {
  const SubscriptionModal({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Action unavailable (Coming Soon)')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    final currentTier = user?.subscription?.tier.toLowerCase() ?? 'free';
    final price = user?.subscription?.priceAmount?.toInt() ?? 0;
    final end = user?.subscription?.currentPeriodEnd;

    final String formattedDate = end != null
        ? '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}'
        : 'N/A';

    final bool isMobile =
        Responsive.isMobile(context) ||
        MediaQuery.of(context).size.width < 1100;

    // Determine initial index for the mobile deck based on current plan
    int initialDeckIndex = 0;
    if (currentTier == 'pro') initialDeckIndex = 1;
    if (currentTier == 'ultra') initialDeckIndex = 2;

    final List<Widget> rawCards = [
      Padding(
        padding: EdgeInsets.only(
          top: (!isMobile && currentTier != 'free') ? 32.0 : 0.0,
        ),
        child: PlanCard(
          title: 'Free',
          price: '\$0',
          billingCycle: 'mo',
          description:
              'Essential AI tutoring for curious learners starting out.',
          features: const [
            '10 AI Sessions / month',
            '1 Follow-Up Question / step',
            '1 YouTube Video / step',
            'Bite-Sized Learning Mode',
            'Milestone Quizzes & XP',
            'All 5 Education Levels',
            'Session History & Recovery',
          ],
          buttonText: currentTier == 'free'
              ? 'Current Plan'
              : 'Downgrade to Free',
          isCurrentPlan: currentTier == 'free',
          onButtonTap: currentTier == 'free'
              ? null
              : () => _showComingSoon(context),
          useSpacer: !isMobile,
          width: isMobile ? double.infinity : 320,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(
          top: (!isMobile && currentTier != 'pro') ? 32.0 : 0.0,
        ),
        child: PlanCard(
          title: 'Pro',
          price: '\$19',
          billingCycle: 'mo',
          description:
              'Full agent squad, visual modes, research preprints & Markdown export.',
          features: const [
            'Unlimited AI Sessions',
            '5 Follow-Up Questions / step',
            '3 YouTube Videos / step (Clips)',
            'Visual & Deep-Dive Modes',
            'Academic Preprints & AI TL;DR',
            'Step Content Regeneration',
            'Markdown (.md) Export',
            '1.5x XP Multiplier',
          ],
          buttonText: currentTier == 'free'
              ? 'Upgrade to Pro ⚡'
              : (currentTier == 'pro' ? 'Current Plan' : 'Downgrade to Pro'),
          isCurrentPlan: currentTier == 'pro',
          onButtonTap: currentTier == 'pro'
              ? null
              : () => _showComingSoon(context),
          useSpacer: !isMobile,
          width: isMobile ? double.infinity : 320,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(
          top: (!isMobile && currentTier != 'ultra') ? 32.0 : 0.0,
        ),
        child: PlanCard(
          title: 'Ultra',
          price: '\$49',
          billingCycle: 'mo',
          description:
              'Unrestricted multi-agent squad, full research, PDF export & 2x XP.',
          features: const [
            'Everything in Pro +',
            'Unlimited Follow-Up Chat',
            '5 YouTube Videos / step',
            'Full-Text Academic Research',
            'Markdown + PDF (.pdf) Export',
            'Priority Multi-Agent Exec',
            '2x XP Boost & Fast Leveling',
            '24/7 Priority Support',
          ],
          buttonText: currentTier == 'ultra'
              ? 'Current Plan'
              : 'Select Ultra ✨',
          isCurrentPlan: currentTier == 'ultra',
          onButtonTap: currentTier == 'ultra'
              ? null
              : () => _showComingSoon(context),
          useSpacer: !isMobile,
          width: isMobile ? double.infinity : 320,
        ),
      ),
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: isMobile ? 16 : 24,
        ),
        child: Container(
          width: isMobile ? double.infinity : 1150,
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Subscription',
                          style: isMobile ? AppTextStyles.h3 : AppTextStyles.h2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your current plan: ${currentTier.toUpperCase()}',
                          style: AppTextStyles.subtitle1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (currentTier != 'free') ...[
                          const SizedBox(height: 4),
                          Text(
                            'Renews on $formattedDate (\$$price/mo)',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 24 : 48),

              // Plan Cards Section
              Flexible(
                child: isMobile
                    ? MobilePlanDeck(
                        cards: rawCards,
                        initialIndex: initialDeckIndex,
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              rawCards[0],
                              const SizedBox(width: 24),
                              rawCards[1],
                              const SizedBox(width: 24),
                              rawCards[2],
                            ],
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
}
