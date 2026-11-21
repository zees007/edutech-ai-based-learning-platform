import 'package:flutter/material.dart';

class TrophyStyle {
  final IconData icon;
  final Color color;

  const TrophyStyle(this.icon, this.color);
}

/// Returns the icon and accent color for a given trophy ID or icon key.
TrophyStyle getTrophyStyle(String? trophyId) {
  final key = trophyId?.toLowerCase().trim();
  switch (key) {
    case 'bronze':
      return const TrophyStyle(Icons.military_tech_rounded, Color(0xFFCD7F32));
    case 'silver':
      return const TrophyStyle(Icons.verified_rounded, Color(0xFFCBD5E1));
    case 'gold':
      return const TrophyStyle(Icons.emoji_events_rounded, Color(0xFFF59E0B));
    case 'platinum':
      return const TrophyStyle(Icons.auto_awesome_rounded, Color(0xFFA78BFA));
    case 'sapphire':
      return const TrophyStyle(Icons.token_rounded, Color(0xFF2563EB));
    case 'diamond':
      return const TrophyStyle(Icons.diamond_rounded, Color(0xFF22D3EE));
    // Legacy support
    case 'flag':
      return const TrophyStyle(Icons.flag_rounded, Color(0xFF06B6D4));
    case 'bullseye':
      return const TrophyStyle(Icons.track_changes_rounded, Color(0xFF10B981));
    case 'flame':
      return const TrophyStyle(Icons.local_fire_department_rounded, Color(0xFFEF4444));
    case 'compass':
      return const TrophyStyle(Icons.explore_rounded, Color(0xFF8B5CF6));
    case 'books':
      return const TrophyStyle(Icons.menu_book_rounded, Color(0xFF38BDF8));
    case 'crown':
      return const TrophyStyle(Icons.workspace_premium_rounded, Color(0xFFF59E0B));
    default:
      return const TrophyStyle(Icons.military_tech_outlined, Color(0xFF8B5CF6));
  }
}
