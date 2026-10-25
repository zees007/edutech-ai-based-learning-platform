import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/responsive.dart';
import '../../../../../core/providers/user_provider.dart';
import '../../../../../core/services/subscription_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../data/models/subscription/payment_models.dart';
import 'checkout_review_dialog.dart';
import 'mobile_plan_deck.dart';
import 'plan_card.dart';

class SubscriptionModal extends ConsumerStatefulWidget {
  const SubscriptionModal({super.key});

  @override
  ConsumerState<SubscriptionModal> createState() => _SubscriptionModalState();
}

class _SubscriptionModalState extends ConsumerState<SubscriptionModal>
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
    final gatewayProvider = user?.subscription?.gatewayProvider?.toUpperCase() ?? 'RAZORPAY';

    final String formattedDate = end != null
        ? '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}'
        : 'N/A';

    final bool isMobile =
        Responsive.isMobile(context) || MediaQuery.of(context).size.width < 1100;
    final bool isDark = AppColors.isDark;

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
          height: isMobile ? 850 : 750,
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F111E).withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.96),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        Row(
                          children: [
                            Text(
                              'Subscription & Billing',
                              style: isMobile ? AppTextStyles.h3 : AppTextStyles.h2,
                            ),
                            const SizedBox(width: 14),
                            _buildTierBadge(currentTier),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentTier == 'free'
                              ? 'Curious learner on the Free plan'
                              : 'Renews on $formattedDate (\$$price/mo via $gatewayProvider)',
                          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16182B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.auto_awesome_rounded, size: 16),
                      text: 'Plans & Upgrades',
                    ),
                    Tab(
                      icon: Icon(Icons.manage_accounts_rounded, size: 16),
                      text: 'Billing & Settings',
                    ),
                    Tab(
                      icon: Icon(Icons.receipt_long_rounded, size: 16),
                      text: 'Payment Invoices',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab Bar Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPlansTab(context, currentTier, isMobile),
                    _buildBillingSettingsTab(user, currentTier, formattedDate, autoRenew, gatewayProvider),
                    _buildInvoicesTab(user?.id ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildPlansTab(BuildContext context, String currentTier, bool isMobile) {
    final isAnnual = _billingCycle == 'annual';

    // Pricing definitions
    final proPrice = isAnnual ? '\$180' : '\$19';
    final ultraPrice = isAnnual ? '\$470' : '\$49';
    final proRawPrice = isAnnual ? 180.0 : 19.0;
    final ultraRawPrice = isAnnual ? 470.0 : 49.0;

    final List<Widget> allCards = [
      PlanCard(
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
        onButtonTap: null,
        useSpacer: !isMobile,
        width: isMobile ? double.infinity : 310,
      ),
      PlanCard(
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
        onButtonTap: currentTier == 'pro'
            ? null
            : () => _openCheckout('pro', proRawPrice),
        useSpacer: !isMobile,
        width: isMobile ? double.infinity : 310,
      ),
      PlanCard(
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
        onButtonTap: currentTier == 'ultra'
            ? null
            : () => _openCheckout('ultra', ultraRawPrice),
        useSpacer: !isMobile,
        width: isMobile ? double.infinity : 310,
      ),
    ];

    return Column(
      children: [
        // Monthly vs Annual Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _billingCycle = 'monthly'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: !isAnnual ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Monthly Billing',
                  style: TextStyle(
                    color: !isAnnual ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _billingCycle = 'annual'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isAnnual ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'Annual Billing',
                      style: TextStyle(
                        color: isAnnual ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
                        'SAVE 20%',
                        style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Plan Cards Deck
        Expanded(
          child: isMobile
              ? MobilePlanDeck(cards: allCards)
              : Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: allCards.asMap().entries.expand((e) {
                          return [
                            e.value,
                            if (e.key != allCards.length - 1) const SizedBox(width: 20),
                          ];
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBillingSettingsTab(
    dynamic user,
    String currentTier,
    String formattedDate,
    bool autoRenew,
    String gatewayProvider,
  ) {
    final bool isDark = AppColors.isDark;

    if (currentTier == 'free') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_outlined, size: 54, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('No Active Paid Subscription', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Text(
              'Upgrade to Pro or Ultra in the Plans tab to unlock higher limits and manage recurring billing.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Subscription Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16182B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current Active Tier', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, color: AppColors.emerald, size: 8),
                          const SizedBox(width: 6),
                          Text('ACTIVE', style: AppTextStyles.caption.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${currentTier.toUpperCase()} Member',
                  style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Processed through $gatewayProvider. Renews automatically on $formattedDate.',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Settings Controls
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16182B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Auto-Renewal', style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          autoRenew ? 'Automatic renewal is active.' : 'Subscription will terminate at end of cycle.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
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
                Divider(color: AppColors.glassBorder, height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cancel Subscription', style: AppTextStyles.subtitle1.copyWith(color: AppColors.rose)),
                        const SizedBox(height: 2),
                        Text('Downgrade account at the end of billing period', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.rose),
                        foregroundColor: AppColors.rose,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isCanceling ? null : () => _showCancelConfirmation(user.id, formattedDate),
                      child: _isCanceling
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.rose))
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

    return FutureBuilder<List<PaymentTransactionModel>>(
      future: ref.read(subscriptionServiceProvider).getTransactions(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load invoices: ${snapshot.error}',
              style: TextStyle(color: AppColors.rose),
            ),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 54, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text('No Invoice Records Yet', style: AppTextStyles.h4),
                const SizedBox(height: 8),
                Text(
                  'Once you complete subscription upgrades via Razorpay, receipts will appear here.',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: transactions.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final t = transactions[idx];
            final dateStr =
                '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}-${t.createdAt.day.toString().padLeft(2, '0')}';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.isDark ? const Color(0xFF16182B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.tier.toUpperCase()} Plan (${t.billingCycle})',
                          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Txn: ${t.transactionId} • $dateStr',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${t.amount.toStringAsFixed(2)}',
                        style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t.status.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.emerald,
                            fontSize: 10,
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
    );
  }
}
