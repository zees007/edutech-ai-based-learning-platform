import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';

class AuthTopNavbar extends StatelessWidget {
  final bool isMobile;

  const AuthTopNavbar({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 12 : 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Text(
                '⚡ ',
                style: GoogleFonts.inter(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.w900),
              ),
              GradientText(
                'EduTech',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AI',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFC084FC),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          // Back to Home Button
          OutlinedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white70),
            label: Text(
              isMobile ? 'Back' : 'Back to Home',
              style: const TextStyle(color: Colors.white70),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
