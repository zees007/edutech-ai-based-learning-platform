import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/data/models/subscription/payment_models.dart';
import 'package:devzees_edutechai_client/core/services/subscription_service.dart';
import 'package:devzees_edutechai_client/presentation/widgets/promo_announcement_bar.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/subscription/ultra_extension_dialog.dart';

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

  group('UltraExtensionDialog widget tests', () {
    testWidgets('renders dynamic campaign text, discount percentage, and extension CTA', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const banner = PromoBannerModel(
        enabled: true,
        text: 'New Year 2027 Mega Sale: 50% OFF Pro & Ultra!',
        couponCode: 'NEWYEAR50',
        discountPercent: 50.0,
      );

      const catalog = PricingCatalogModel(
        currency: 'USD',
        tiers: {
          'ultra': TierPricingItem(monthly: 49.0, annual: 470.0),
        },
        promoBanner: banner,
      );

      bool extended = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UltraExtensionDialog(
              promoBanner: banner,
              catalog: catalog,
              user: null,
              onExtend: () {
                extended = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Extend Your Ultra Plan (50% OFF)'), findsOneWidget);
      expect(find.text('New Year 2027 Mega Sale: 50% OFF Pro & Ultra!'), findsOneWidget);
      expect(find.textContaining('NEWYEAR50'), findsWidgets);
      expect(find.text('Extend 1 Year (50% OFF)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Extend 1 Year (50% OFF)'));
      await tester.pumpAndSettle();
      expect(extended, isTrue);
    });
  });

  group('PROMO_VALIDITY tests', () {
    test('PromoBannerModel correctly detects expired vs active validity', () {
      final pastDate = DateTime.now().subtract(const Duration(hours: 2)).toIso8601String();
      final futureDate = DateTime.now().add(const Duration(days: 3, hours: 4)).toIso8601String();

      final expiredModel = PromoBannerModel.fromJson({
        'enabled': true,
        'valid_until': pastDate,
      });
      expect(expiredModel.isExpired, isTrue);
      expect(expiredModel.isActive, isFalse);

      final activeModel = PromoBannerModel.fromJson({
        'enabled': true,
        'valid_until': futureDate,
      });
      expect(activeModel.isExpired, isFalse);
      expect(activeModel.isActive, isTrue);
      expect(activeModel.remainingTimeLabel, contains('3d'));
    });

    testWidgets('renders countdown badge when valid_until is in the future', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final futureDate = DateTime.now().add(const Duration(days: 2, hours: 5)).toIso8601String();

      final mockCatalog = PricingCatalogModel(
        currency: 'USD',
        tiers: const {
          'pro': TierPricingItem(monthly: 19.0, annual: 180.0),
        },
        promoBanner: PromoBannerModel(
          enabled: true,
          text: 'Weekend Flash Sale!',
          couponCode: 'FLASH50',
          discountPercent: 50.0,
          validUntil: futureDate,
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

      expect(find.textContaining('Ends in'), findsOneWidget);
      expect(find.text('Weekend Flash Sale!'), findsOneWidget);
    });

    testWidgets('automatically hides promo banner if valid_until has passed', (tester) async {
      final pastDate = DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String();

      final mockCatalog = PricingCatalogModel(
        currency: 'USD',
        tiers: const {
          'pro': TierPricingItem(monthly: 19.0, annual: 180.0),
        },
        promoBanner: PromoBannerModel(
          enabled: true,
          text: 'Expired Flash Sale',
          couponCode: 'EXPIRED50',
          discountPercent: 50.0,
          validUntil: pastDate,
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

      expect(find.text('Expired Flash Sale'), findsNothing);
      expect(find.text('Claim Offer'), findsNothing);
    });
  });
}
