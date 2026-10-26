import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/responsive.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/subscription/payment_models.dart';
import '../../widgets/glass_card.dart';
import '../learning/widgets/subscription/checkout_review_dialog.dart';
import '../learning/widgets/subscription/plan_card.dart';
import '../learning/widgets/subscription/mobile_plan_deck.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _billingCycle = 'monthly'; // 'monthly' or 'annual'
  bool _isCanceling = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openCheckout(String targetTier, double basePrice) async {
    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CheckoutReviewDialog(
        targetTier: targetTier,
        billingCycle: _billingCycle,
        basePrice: basePrice,
      ),
    );

    if (success == true) {
      ref.invalidate(userProvider);
    }
  }

  Future<void> _showCancelConfirmation(String userId, String? expiryDate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.isDark ? const Color(0xFF16182B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Auto-Renewal?', style: AppTextStyles.h4),
        content: Text(
          'Your recurring subscription will not renew. You will retain all active tier features until $expiryDate.',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Keep Plan', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isCanceling = true);
      try {
        await ref.read(subscriptionServiceProvider).cancelSubscription(
              userId,
              reason: 'User disabled auto-renewal in settings',
            );
        ref.invalidate(userProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Auto-renewal cancelled successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isCanceling = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    final currentTier = user?.subscription?.tier.toLowerCase() ?? 'free';
    final price = user?.subscription?.priceAmount?.toInt() ?? 0;
    final end = user?.subscription?.currentPeriodEnd;
    final autoRenew = user?.subscription?.autoRenew ?? true;
    final gatewayProvider =
        user?.subscription?.gatewayProvider?.toUpperCase() ?? 'RAZORPAY';

    final String formattedDate = end != null
        ? '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}'
        : 'N/A';

    final bool isDark = AppColors.isDark;
    final bool isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090A11) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Ambient Radial Glow Backdrop
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 600,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
                    AppColors.accentPink.withValues(alpha: isDark ? 0.10 : 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top Navigation Bar ──
                _buildTopBar(context, currentTier, isDark, isMobile),

                // ── Main Scrollable Body ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Hero Title & Subtitle
                            _buildHeroHeader(currentTier, formattedDate, price, gatewayProvider),
                            const SizedBox(height: 28),

                            // Segmented Navigation Tabs
                            _buildNavigationTabs(isDark, isMobile),
                            const SizedBox(height: 32),

                            // Tab Body Content
                            AnimatedBuilder(
                              animation: _tabController,
                              builder: (context, _) {
                                switch (_tabController.index) {
                                  case 0:
                                    return _buildPlansTab(context, currentTier, isMobile);
                                  case 1:
                                    return _buildBillingSettingsTab(
                                      user,
                                      currentTier,
                                      formattedDate,
                                      autoRenew,
                                      gatewayProvider,
                                    );
                                  case 2:
                                    return _buildInvoicesTab(user?.id ?? '');
                                  default:
                                    return const SizedBox.shrink();
                                }
                              },
                            ),

                            const SizedBox(height: 60),

                            // Trust and Security Footer
                            _buildSecurityFooter(isDark),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    String currentTier,
    bool isDark,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F111E).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button & Brand Logo
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/learning');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isMobile ? 'Workspace' : 'Back to Workspace',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Active Tier Chip
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile) ...[
                Text(
                  'ACTIVE TIER: ',
                  style: AppTextStyles.caption.copyWith(
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              _buildTierBadge(currentTier),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(
    String currentTier,
    String formattedDate,
    int price,
    String gatewayProvider,
  ) {
    return Column(
      children: [
        // Pill Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'FLEXIBLE PLANS',
                style: TextStyle(
                  color: AppColors.isDark ? AppColors.blueSoft : AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Supercharge Your AI Learning',
          textAlign: TextAlign.center,
          style: AppTextStyles.h1.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 10),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            'Select the optimal plan to unlock unlimited multi-agent deep dive sessions, full-text academic research, and priority AI execution.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationTabs(bool isDark, bool isMobile) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 580),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141628) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: isMobile,
        tabAlignment: isMobile ? TabAlignment.start : TabAlignment.fill,
        onTap: (_) => setState(() {}),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPink.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(
            icon: Icon(Icons.auto_awesome_rounded, size: 16),
            text: 'Plans & Pricing',
          ),
          Tab(
            icon: Icon(Icons.manage_accounts_rounded, size: 16),
            text: 'Billing & Settings',
          ),
          Tab(
            icon: Icon(Icons.receipt_long_rounded, size: 16),
            text: 'Invoice Records',
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTab(BuildContext context, String currentTier, bool isMobile) {
    final catalogAsync = ref.watch(pricingCatalogProvider);
    final catalog = catalogAsync.value ?? PricingCatalogModel.defaultCatalog;

    final isAnnual = _billingCycle == 'annual';

    final proRawPrice = catalog.getPrice('pro', _billingCycle);
    final ultraRawPrice = catalog.getPrice('ultra', _billingCycle);

    final proPrice = proRawPrice == proRawPrice.toInt()
        ? '\$${proRawPrice.toInt()}'
        : '\$${proRawPrice.toStringAsFixed(2)}';
    final ultraPrice = ultraRawPrice == ultraRawPrice.toInt()
        ? '\$${ultraRawPrice.toInt()}'
        : '\$${ultraRawPrice.toStringAsFixed(2)}';

    final cardPadding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 22)
        : const EdgeInsets.all(28);

    final cardFree = PlanCard(
      title: 'Free',
      price: '\$0',
      billingCycle: isAnnual ? 'yr' : 'mo',
      description: 'Essential AI tutoring for curious learners starting out.',
      features: const [
        '10 AI Sessions / month',
        '1 Follow-Up Question / step',
        '1 YouTube Video / step',
        'Bite-Sized & Visual Modes',
        'Milestone Quizzes & XP',
        'Academic Paper Search',
        'Session History & Recovery',
      ],
      buttonText: currentTier == 'free' ? 'Current Plan' : 'Downgrade to Free',
      isCurrentPlan: currentTier == 'free',
      badgeText: 'STARTER',
      onButtonTap: null,
      padding: cardPadding,
      width: isMobile ? double.infinity : 350,
    );

    final cardPro = PlanCard(
      title: 'Pro',
      price: proPrice,
      billingCycle: isAnnual ? 'yr' : 'mo',
      description: 'Full agent squad, deep dive modes, & Markdown export.',
      features: const [
        'Unlimited AI Sessions',
        '5 Follow-Up Questions / step',
        '3 YouTube Videos / step',
        'Unlock Deep Dive Mode',
        'Step Content Regeneration',
        'Markdown & HTML Export',
        '1.5x XP Multiplier',
      ],
      buttonText: currentTier == 'pro' ? 'Current Plan' : 'Upgrade to Pro ⚡',
      isCurrentPlan: currentTier == 'pro',
      isFeatured: true,
      badgeText: 'MOST POPULAR',
      onButtonTap: currentTier == 'pro'
          ? null
          : () => _openCheckout('pro', proRawPrice),
      padding: cardPadding,
      width: isMobile ? double.infinity : 350,
    );

    final cardUltra = PlanCard(
      title: 'Ultra',
      price: ultraPrice,
      billingCycle: isAnnual ? 'yr' : 'mo',
      description: 'Unrestricted multi-agent squad, research, PDF export & 2x XP.',
      features: const [
        'Everything in Pro +',
        'Unlimited Follow-Up Chat',
        '5 YouTube Videos / step',
        'Full-Text Academic Research',
        'PDF (.pdf) Export',
        'Priority Multi-Agent Exec',
        '2x XP Boost & Fast Leveling',
      ],
      buttonText: currentTier == 'ultra' ? 'Current Plan' : 'Select Ultra ✨',
      isCurrentPlan: currentTier == 'ultra',
      badgeText: 'MAX POWER',
      onButtonTap: currentTier == 'ultra'
          ? null
          : () => _openCheckout('ultra', ultraRawPrice),
      padding: cardPadding,
      width: isMobile ? double.infinity : 350,
    );

    return Column(
      children: [
        // ── Monthly vs Annual Toggle Switch ──
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.isDark
                ? const Color(0xFF16182B)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () => setState(() => _billingCycle = 'monthly'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: !isAnnual ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    isMobile ? 'Monthly' : 'Monthly Billing',
                    style: TextStyle(
                      color: !isAnnual ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () => setState(() => _billingCycle = 'annual'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isAnnual ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    children: [
                      Text(
                        isMobile ? 'Annual' : 'Annual Billing',
                        style: TextStyle(
                          color: isAnnual ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentAmber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '20% OFF',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // ── Responsive Pricing Cards Deck ──
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 1080) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: cardFree),
                  const SizedBox(width: 24),
                  Expanded(child: cardPro),
                  const SizedBox(width: 24),
                  Expanded(child: cardUltra),
                ],
              );
            } else if (constraints.maxWidth >= 720) {
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(width: (constraints.maxWidth - 24) / 2, child: cardFree),
                  SizedBox(width: (constraints.maxWidth - 24) / 2, child: cardPro),
                  SizedBox(width: constraints.maxWidth, child: cardUltra),
                ],
              );
            } else {
              final initialIdx = currentTier == 'ultra'
                  ? 2
                  : (currentTier == 'pro' ? 1 : 1);
              return MobilePlanDeck(
                cards: [cardFree, cardPro, cardUltra],
                planTitles: const ['Starter', 'Pro ⭐', 'Ultra ✨'],
                initialIndex: initialIdx,
                cardHeight: 640,
              );
            }
          },
        ),

        const SizedBox(height: 60),

        // ── Frequently Asked Questions ──
        _buildFaqSection(isMobile),
      ],
    );
  }

  Widget _buildFaqSection(bool isMobile) {
    final faqs = [
      {
        'q': 'Can I change plans or cancel at any time?',
        'a':
            'Yes, absolutely. You can upgrade, downgrade, or cancel auto-renewal with a single click in the Billing & Settings tab. If you cancel, you will maintain full tier access until your current billing period ends.',
      },
      {
        'q': 'What payment options does Razorpay support?',
        'a':
            'Razorpay supports all major credit & debit cards (Visa, MasterCard, RuPay, Amex), UPI (Google Pay, PhonePe, Paytm), Netbanking across 50+ banks, and international cards.',
      },
      {
        'q': 'How does switching between Monthly and Annual billing work?',
        'a':
            'When you toggle between monthly and annual plans, discounts and prorated adjustments are automatically applied at checkout.',
      },
      {
        'q': 'What happens if I hit the Free plan limits?',
        'a':
            'You will be prompted to upgrade to Pro for unlimited AI sessions and higher query limits. Your session history and XP progress will never be lost.',
      },
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Have questions about EduTech AI subscriptions? We have got you covered.',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          ...faqs.map((faq) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.help_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              faq['q']!,
                              style: AppTextStyles.subtitle1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Text(
                          faq['a']!,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBillingSettingsTab(
    dynamic user,
    String currentTier,
    String formattedDate,
    bool autoRenew,
    String gatewayProvider,
  ) {
    if (currentTier == 'free') {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: GlassCard(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text('No Active Paid Subscription', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              Text(
                'You are currently on the Free plan. Upgrade to Pro or Ultra in the Plans tab to unlock higher limits and manage recurring billing.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(0);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('View Available Plans', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Subscription Card
          GlassCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENT SUBSCRIPTION',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: AppColors.emerald, size: 8),
                          const SizedBox(width: 6),
                          Text(
                            'ACTIVE',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.emerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '${currentTier.toUpperCase()} Plan Member',
                  style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Processed through $gatewayProvider. Renews automatically on $formattedDate.',
                  style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Settings Controls
          GlassCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Automatic Renewal',
                            style: AppTextStyles.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            autoRenew
                                ? 'Your subscription will automatically renew each billing period.'
                                : 'Auto-renewal is paused. Subscription terminates at the end of the current period.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Switch(
                      value: autoRenew,
                      activeThumbColor: AppColors.primary,
                      onChanged: _isCanceling
                          ? null
                          : (val) {
                              if (!val) {
                                _showCancelConfirmation(user.id, formattedDate);
                              }
                            },
                    ),
                  ],
                ),
                Divider(color: AppColors.glassBorder, height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancel Subscription',
                            style: AppTextStyles.subtitle1.copyWith(
                              color: AppColors.rose,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Disable auto-renewal and downgrade account when the billing cycle concludes.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.rose),
                        foregroundColor: AppColors.rose,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isCanceling
                          ? null
                          : () => _showCancelConfirmation(user.id, formattedDate),
                      child: _isCanceling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.rose,
                              ),
                            )
                          : const Text('Cancel Plan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab(String userId) {
    if (userId.isEmpty) {
      return const Center(child: Text('No active user session'));
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: FutureBuilder<List<PaymentTransactionModel>>(
        future: ref.read(subscriptionServiceProvider).getTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return GlassCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Failed to load invoices: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.rose),
                ),
              ),
            );
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return GlassCard(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('No Invoice Records Yet', style: AppTextStyles.h3),
                    const SizedBox(height: 10),
                    Text(
                      'Once you complete subscription upgrades via Razorpay, receipts will appear here.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, index) => const SizedBox(height: 14),
            itemBuilder: (context, idx) {
              final t = transactions[idx];
              final dateStr =
                  '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}-${t.createdAt.day.toString().padLeft(2, '0')}';

              return GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t.tier.toUpperCase()} Plan (${t.billingCycle})',
                            style: AppTextStyles.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Txn: ${t.transactionId} • $dateStr',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${t.amount.toStringAsFixed(2)}',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t.status.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.emerald,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSecurityFooter(bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        children: [
          Divider(color: AppColors.glassBorder),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildSecurityBadge(Icons.shield_outlined, '256-Bit SSL Secured', AppColors.emerald),
              _buildSecurityBadge(Icons.verified_user_outlined, 'Powered by Razorpay', AppColors.primary),
              _buildSecurityBadge(Icons.bolt_rounded, 'Instant Activation', AppColors.accentAmber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTierBadge(String tier) {
    Color color1 = AppColors.primary;
    Color color2 = AppColors.primaryViolet;

    if (tier == 'pro') {
      color1 = const Color(0xFF2563EB);
      color2 = const Color(0xFF7C3AED);
    } else if (tier == 'ultra') {
      color1 = const Color(0xFF9333EA);
      color2 = const Color(0xFFEC4899);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tier.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
