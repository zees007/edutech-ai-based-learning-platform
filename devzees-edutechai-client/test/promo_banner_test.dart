import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/data/models/subscription/payment_models.dart';
import 'package:devzees_edutechai_client/core/services/subscription_service.dart';
import 'package:devzees_edutechai_client/presentation/widgets/promo_announcement_bar.dart';

void main() {
  group('PromoBannerModel & PricingCatalogModel tests', () {
    test('parses promo_banner correctly from json', () {
      final json = {
        'currency': 'USD',
        'tiers': {
          'free': {'monthly': 0.0, 'annual': 0.0},
          'pro': {'monthly': 19.0, 'annual': 180.0},
          'ultra': {'monthly': 49.0, 'annual': 470.0},
        },
        'promo_banner': {
          'enabled': true,
          'text': 'Diwali Mega Sale: Get Flat 50% OFF Pro & Ultra!',
          'coupon_code': 'DIWALI50',
          'discount_percent': 50.0,
        },
      };

      final catalog = PricingCatalogModel.fromJson(json);
      expect(catalog.promoBanner, isNotNull);
      expect(catalog.promoBanner!.enabled, isTrue);
      expect(catalog.promoBanner!.text, contains('Diwali Mega Sale'));
      expect(catalog.promoBanner!.couponCode, 'DIWALI50');
      expect(catalog.promoBanner!.discountPercent, 50.0);
    });

    test('handles missing or null promo_banner gracefully', () {
      final json = {
        'currency': 'USD',
        'tiers': {
          'free': {'monthly': 0.0, 'annual': 0.0},
        },
      };

      final catalog = PricingCatalogModel.fromJson(json);
      expect(catalog.promoBanner, isNull);
    });
  });

  group('PromoAnnouncementBar widget tests', () {
    testWidgets('renders festive announcement bar when enabled', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockCatalog = const PricingCatalogModel(
        currency: 'USD',
        tiers: {
          'pro': TierPricingItem(monthly: 19.0, annual: 180.0),
        },
        promoBanner: PromoBannerModel(
          enabled: true,
          text: 'Diwali Mega Sale: Flat 50% OFF!',
          couponCode: 'DIWALI50',
          discountPercent: 50.0,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pricingCatalogProvider.overrideWith((ref) => Future.value(mockCatalog)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PromoAnnouncementBar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Diwali Mega Sale: Flat 50% OFF!'), findsOneWidget);
      expect(find.text('DIWALI50'), findsOneWidget);
      expect(find.text('Claim Offer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders nothing when promo banner is disabled', (tester) async {
      final mockCatalog = const PricingCatalogModel(
        currency: 'USD',
        tiers: {
          'pro': TierPricingItem(monthly: 19.0, annual: 180.0),
        },
        promoBanner: PromoBannerModel(
          enabled: false,
          text: 'Inactive Sale',
          couponCode: 'TEST',
          discountPercent: 10.0,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pricingCatalogProvider.overrideWith((ref) => Future.value(mockCatalog)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PromoAnnouncementBar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Inactive Sale'), findsNothing);
      expect(find.text('Claim Offer'), findsNothing);
    });
  });
}
