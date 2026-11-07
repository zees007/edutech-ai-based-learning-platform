import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/core/constants/country_data.dart';
import 'package:devzees_edutechai_client/presentation/widgets/searchable_country_dropdown.dart';

void main() {
  group('CountryData — Unit Tests', () {
    test('detectCountry returns a valid default country or locale country', () {
      final country = CountryData.detectCountry();
      expect(country, isNotNull);
      expect(country.name.isNotEmpty, isTrue);
      expect(country.code.isNotEmpty, isTrue);
      expect(country.dialCode.startsWith('+'), isTrue);
      expect(country.flag.isNotEmpty, isTrue);
    });

    test('findByCode correctly identifies US and IN', () {
      final us = CountryData.findByCode('US');
      expect(us, isNotNull);
      expect(us!.name, equals('United States'));
      expect(us.dialCode, equals('+1'));
      expect(us.flag, equals('🇺🇸'));

      final india = CountryData.findByCode('IN');
      expect(india, isNotNull);
      expect(india!.name, equals('India'));
      expect(india.dialCode, equals('+91'));
      expect(india.flag, equals('🇮🇳'));
    });

    test('findByName is case-insensitive', () {
      final canada = CountryData.findByName('canada');
      expect(canada, isNotNull);
      expect(canada!.code, equals('CA'));
      expect(canada.dialCode, equals('+1'));

      final uae = CountryData.findByName('United Arab Emirates');
      expect(uae, isNotNull);
      expect(uae!.dialCode, equals('+971'));
    });

    test('findByDialCode matches codes with or without plus sign', () {
      final uk1 = CountryData.findByDialCode('+44');
      expect(uk1, isNotNull);
      expect(uk1!.code, equals('GB'));

      final uk2 = CountryData.findByDialCode('44');
      expect(uk2, isNotNull);
      expect(uk2!.code, equals('GB'));

      final in1 = CountryData.findByDialCode('+91');
      expect(in1, isNotNull);
      expect(in1!.name, equals('India'));
    });

    test('NRI scenario: Handles switching from India (+91) to US (+1)', () {
      // Simulating NRI flow
      var currentCountry = CountryData.findByCode('IN')!;
      expect(currentCountry.name, equals('India'));
      expect(currentCountry.dialCode, equals('+91'));

      // User chooses US
      final nriCountry = CountryData.findByCode('US')!;
      currentCountry = nriCountry;

      expect(currentCountry.name, equals('United States'));
      expect(currentCountry.dialCode, equals('+1'));

      // User enters local US number 4155552671
      const localNumber = '4155552671';
      final e164 = '${currentCountry.dialCode}$localNumber';
      expect(e164, equals('+14155552671'));
    });
  });

  group('SearchableCountryDropdown — Widget Tests', () {
    testWidgets('Renders selected country with flag and opens anchored dropdown on tap',
        (tester) async {
      Country selected = CountryData.findByCode('US')!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return SearchableCountryDropdown(
                      selectedCountry: selected,
                      isDark: false,
                      onCountryChanged: (c) {
                        setState(() => selected = c);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Verify trigger displays US flag and name
      expect(find.text('COUNTRY'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);

      // Tap to open in-place anchored dropdown
      await tester.tap(find.text('United States'));
      await tester.pumpAndSettle();

      // Search field appears inside the anchored overlay
      expect(find.byType(TextField), findsOneWidget);

      // Tap India in the list
      await tester.tap(find.text('India').last);
      await tester.pumpAndSettle();

      // Verify selection changed to India without any remaining modal backdrop
      expect(find.text('India'), findsOneWidget);
      expect(find.text('🇮🇳'), findsOneWidget);
    });
  });
}
