import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

class CtaFooter extends StatelessWidget {
  const CtaFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        // CTA Banner
        GlassCard(
          padding: EdgeInsets.all(isMobile ? 32 : 64),
          isGlowing: true,
          child: Column(
            children: [
              GradientText(
                'Ready to Accelerate Your Learning?',
                style: AppTextStyles.h2.copyWith(fontSize: isMobile ? 28 : 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Join thousands of students and professionals mastering complex topics faster with EduTech AI.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: 'Get Started Free →',
                width: isMobile ? 260 : 300,
                onPressed: () {},
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 80),
        
        // Footer Links
        Container(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  const Text('EduTech AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('© 2024 EduTech AI. Empowering cognitive research through education.', style: AppTextStyles.body2.copyWith(fontSize: 12)),
                ],
              ),
              if (isMobile) const SizedBox(height: 24),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: isMobile ? WrapAlignment.center : WrapAlignment.end,
                children: [
                  _FooterLink('Terms of Service'),
                  _FooterLink('Privacy Policy'),
                  _FooterLink('Contact Support'),
                  _FooterLink('Documentation'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String text;

  const _FooterLink(this.text);

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {},
        child: Text(
          widget.text,
          style: TextStyle(
            color: _isHovered ? Colors.white : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
