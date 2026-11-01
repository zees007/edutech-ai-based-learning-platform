import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/core/providers/gamification_provider.dart';

void main() {
  group('GamificationUtils Leveling Tests (Recalibrated 0-1000 XP Scale)', () {
    test('verifies all 10 level thresholds and titles', () {
      expect(GamificationUtils.levels.length, 10);

      final expectedLevels = [
        {"level": 1, "xp_required": 0, "title": "Curious Explorer"},
        {"level": 2, "xp_required": 60, "title": "Knowledge Seeker"},
        {"level": 3, "xp_required": 140, "title": "Quick Learner"},
        {"level": 4, "xp_required": 250, "title": "Deep Thinker"},
        {"level": 5, "xp_required": 380, "title": "Rising Scholar"},
        {"level": 6, "xp_required": 520, "title": "Concept Master"},
        {"level": 7, "xp_required": 670, "title": "Wisdom Weaver"},
        {"level": 8, "xp_required": 800, "title": "Knowledge Architect"},
        {"level": 9, "xp_required": 920, "title": "Enlightened Mind"},
        {"level": 10, "xp_required": 1000, "title": "Grand Sage"},
      ];

      for (int i = 0; i < expectedLevels.length; i++) {
        final expected = expectedLevels[i];
        final actual = GamificationUtils.levels[i];
        expect(actual["level"], expected["level"]);
        expect(actual["xp_required"], expected["xp_required"]);
        expect(actual["title"], expected["title"]);
      }
    });

    test('calculates correct level for single session milestones', () {
      // 0 XP -> Level 1
      expect(GamificationUtils.calculateLevel(0), 1);
      expect(GamificationUtils.getLevelTitle(1), 'Curious Explorer');

      // 60 XP -> Level 2
      expect(GamificationUtils.calculateLevel(60), 2);
      expect(GamificationUtils.getLevelTitle(2), 'Knowledge Seeker');

      // 140 XP (Step 1 complete with full quiz) -> Level 3
      expect(GamificationUtils.calculateLevel(140), 3);
      expect(GamificationUtils.getLevelTitle(3), 'Quick Learner');

      // 380 XP (Mid-point of standard journey) -> Level 5
      expect(GamificationUtils.calculateLevel(380), 5);
      expect(GamificationUtils.getLevelTitle(5), 'Rising Scholar');

      // 940 XP (Alice 6-step session with 100% quiz accuracy) -> Level 9
      expect(GamificationUtils.calculateLevel(940), 9);
      expect(GamificationUtils.getLevelTitle(9), 'Enlightened Mind');

      // 1000 XP (Threshold for Grand Sage) -> Level 10
      expect(GamificationUtils.calculateLevel(1000), 10);
      expect(GamificationUtils.getLevelTitle(10), 'Grand Sage');

      // 1080 XP (Free User 7 steps complete + 100 bonus) -> Level 10
      expect(GamificationUtils.calculateLevel(1080), 10);

      // 1620 XP (Pro User 1.5x) -> Level 10
      expect(GamificationUtils.calculateLevel(1620), 10);

      // 2160 XP (Ultra User 2.0x) -> Level 10
      expect(GamificationUtils.calculateLevel(2160), 10);
    });

    test('calculateLevelData returns correct progress and max level flag', () {
      // Start of journey
      final startData = GamificationUtils.calculateLevelData(0);
      expect(startData["level"], 1);
      expect(startData["title"], "Curious Explorer");
      expect(startData["is_max_level"], false);
      expect(startData["progress"], 0.0);

      // Midway through level 9 (940 XP out of 920->1000: 20/80 = 0.25)
      final midwayData = GamificationUtils.calculateLevelData(940);
      expect(midwayData["level"], 9);
      expect(midwayData["title"], "Enlightened Mind");
      expect(midwayData["is_max_level"], false);
      expect(midwayData["xp_in_level"], 20);
      expect(midwayData["xp_needed_for_next"], 80);
      expect(midwayData["progress"], 0.25);

      // Max Level reached (1000 XP)
      final maxData = GamificationUtils.calculateLevelData(1000);
      expect(maxData["level"], 10);
      expect(maxData["title"], "Grand Sage");
      expect(maxData["is_max_level"], true);
      expect(maxData["progress"], 1.0);

      // 1080 XP (Over max level)
      final overMaxData = GamificationUtils.calculateLevelData(1080);
      expect(overMaxData["level"], 10);
      expect(overMaxData["title"], "Grand Sage");
      expect(overMaxData["is_max_level"], true);
      expect(overMaxData["progress"], 1.0);
    });
  });
}

