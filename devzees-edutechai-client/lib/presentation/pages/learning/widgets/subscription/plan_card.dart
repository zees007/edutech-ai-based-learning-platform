import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../widgets/glass_card.dart';
import '../../../../widgets/gradient_button.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String billingCycle;
  final String description;
  final List<String> features;
  final String buttonText;
  final bool isCurrentPlan;
  final VoidCallback? onButtonTap;
  final bool useSpacer;
  final double? width;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.billingCycle,
    required this.description,
    required this.features,
    required this.buttonText,
    this.isCurrentPlan = false,
    this.onButtonTap,
    this.useSpacer = true,
    this.width = 320,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Important for SingleChildScrollView
      children: [
        if (isCurrentPlan)
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPink.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Text('CURRENT PLAN ⭐', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.accentPink)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(price, style: AppTextStyles.h1),
            Text('/$billingCycle', style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        Text(description, style: AppTextStyles.body2),
        const SizedBox(height: 24),
        const Divider(color: AppColors.glassBorder),
        const SizedBox(height: 24),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.check, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(f, style: AppTextStyles.body2)),
            ],
          ),
        )),
        if (useSpacer) const Spacer(),
        if (!isCurrentPlan) ...[
          const SizedBox(height: 32),
          GradientButton(
            text: buttonText,
            width: double.infinity,
            onPressed: onButtonTap ?? () {},
          )
        ],
      ],
    );

    return SizedBox(
      width: width,
      child: GlassCard(
        isGlowing: isCurrentPlan,
        padding: const EdgeInsets.all(32),
        child: useSpacer ? content : SingleChildScrollView(child: content),
      ),
    );
  }
}
