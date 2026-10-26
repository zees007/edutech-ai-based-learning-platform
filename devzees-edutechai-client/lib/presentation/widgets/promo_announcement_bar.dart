import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devzees_edutechai_client/core/services/subscription_service.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

/// Top announcement banner for festive and promotional sales campaigns (e.g. Diwali Mega Sale).
/// Controlled dynamically via backend system settings (PROMO_BANNER_ENABLED, PROMO_BANNER_TEXT, etc.).
class PromoAnnouncementBar extends ConsumerStatefulWidget {
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onClaim;

  const PromoAnnouncementBar({
    super.key,
    this.margin,
    this.onClaim,
  });

  @override
  ConsumerState<PromoAnnouncementBar> createState() => _PromoAnnouncementBarState();
}

class _PromoAnnouncementBarState extends ConsumerState<PromoAnnouncementBar> {
  bool _dismissed = false;

  void _copyCoupon(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Coupon "$code" copied to clipboard!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD97706),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final catalogAsync = ref.watch(pricingCatalogProvider);
    final catalog = catalogAsync.value;
    final banner = catalog?.promoBanner;

    if (banner == null || !banner.enabled) {
      return const SizedBox.shrink();
    }

    final isMobile = Responsive.isMobile(context);
    final text = banner.text.isNotEmpty
        ? banner.text
        : 'Limited Time Festive Offer: Upgrade today and save big!';
    final coupon = banner.couponCode;

    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF831843), // deep rose/wine
            Color(0xFF7C2D12), // deep festive amber/terracotta
            Color(0xFF4C1D95), // deep royal purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Ambient glowing accent
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 18,
                vertical: isMobile ? 10 : 10,
              ),
              child: isMobile
                  ? _buildMobileLayout(context, text, coupon)
                  : _buildDesktopLayout(context, text, coupon),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, String text, String coupon) {
    return Row(
      children: [
        // Festive Diya / Sparkle Icon
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFCD34D).withValues(alpha: 0.4)),
          ),
          child: const Text('🪔', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 12),

        // Campaign Text
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),

        // Coupon Chip
        if (coupon.isNotEmpty) ...[
          InkWell(
            onTap: () => _copyCoupon(context, coupon),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFCD34D).withValues(alpha: 0.6),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'USE CODE: ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFDE68A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    coupon,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFBBF24),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.copy_rounded,
                    size: 13,
                    color: Color(0xFFFDE68A),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],

        // CTA Button
        ElevatedButton(
          onPressed: () {
            if (widget.onClaim != null) {
              widget.onClaim!();
            } else {
              context.push('/subscription');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Claim Offer',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Dismiss X button
        IconButton(
          onPressed: () => setState(() => _dismissed = true),
          icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white70),
          splashRadius: 16,
          tooltip: 'Dismiss banner',
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, String text, String coupon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🪔', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () => setState(() => _dismissed = true),
              child: const Padding(
                padding: EdgeInsets.all(2.0),
                child: Icon(Icons.close_rounded, size: 16, color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (coupon.isNotEmpty)
              InkWell(
                onTap: () => _copyCoupon(context, coupon),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFCD34D).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'CODE: ',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFDE68A),
                        ),
                      ),
                      Text(
                        coupon,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy_rounded, size: 11, color: Color(0xFFFDE68A)),
                    ],
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            InkWell(
              onTap: () {
                if (widget.onClaim != null) {
                  widget.onClaim!();
                } else {
                  context.push('/subscription');
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Claim Offer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
