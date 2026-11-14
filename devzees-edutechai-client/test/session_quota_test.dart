import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/data/models/learning/session_quota.dart';
import 'package:devzees_edutechai_client/core/providers/session_quota_provider.dart';

void main() {
  group('SessionQuota Model Tests', () {
    test('parses free tier JSON correctly', () {
      final json = {
        'tier': 'free',
        'is_unlimited': false,
        'used': 3,
        'limit': 10,
        'remaining': 7,
      };

      final quota = SessionQuota.fromJson(json);
      expect(quota.tier, 'free');
      expect(quota.isUnlimited, false);
      expect(quota.used, 3);
      expect(quota.limit, 10);
      expect(quota.remaining, 7);
    });

    test('parses pro/ultra unlimited tier JSON correctly', () {
      final json = {
        'tier': 'pro',
        'is_unlimited': true,
        'used': 15,
        'limit': null,
        'remaining': null,
      };

      final quota = SessionQuota.fromJson(json);
      expect(quota.tier, 'pro');
      expect(quota.isUnlimited, true);
      expect(quota.used, 15);
      expect(quota.limit, isNull);
      expect(quota.remaining, isNull);
    });

    test('SessionQuotaState getters for normal, low, and exhausted', () {
      const normalQuota = SessionQuota(
        tier: 'free',
        isUnlimited: false,
        used: 3,
        limit: 10,
        remaining: 7,
      );
      const normalState = SessionQuotaState(quota: normalQuota);
      expect(normalState.isUnlimited, false);
      expect(normalState.remaining, 7);
      expect(normalState.isLow, false);
      expect(normalState.isExhausted, false);

      const lowQuota = SessionQuota(
        tier: 'free',
        isUnlimited: false,
        used: 9,
        limit: 10,
        remaining: 1,
      );
      const lowState = SessionQuotaState(quota: lowQuota);
      expect(lowState.isLow, true);
      expect(lowState.isExhausted, false);

      const exhaustedQuota = SessionQuota(
        tier: 'free',
        isUnlimited: false,
        used: 10,
        limit: 10,
        remaining: 0,
      );
      const exhaustedState = SessionQuotaState(quota: exhaustedQuota);
      expect(exhaustedState.isLow, false);
      expect(exhaustedState.isExhausted, true);

      const proQuota = SessionQuota(
        tier: 'pro',
        isUnlimited: true,
        used: 42,
      );
      const proState = SessionQuotaState(quota: proQuota);
      expect(proState.isUnlimited, true);
      expect(proState.isLow, false);
      expect(proState.isExhausted, false);
    });
  });
}
