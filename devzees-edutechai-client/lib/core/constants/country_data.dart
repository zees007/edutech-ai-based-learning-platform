import 'dart:ui' as ui;

class Country {
  final String name;
  final String code; // ISO 3166-1 alpha-2 (e.g., 'US', 'IN')
  final String dialCode; // e.g., '+1', '+91'
  final String flag; // Unicode emoji flag

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class CountryData {
  CountryData._();

  static const Country defaultCountry = Country(
    name: 'United States',
    code: 'US',
    dialCode: '+1',
    flag: '🇺🇸',
  );

  static Country detectCountry() {
    try {
      final locale = ui.PlatformDispatcher.instance.locale;
      final countryCode = locale.countryCode?.toUpperCase();
      if (countryCode != null && countryCode.isNotEmpty) {
        final found = findByCode(countryCode);
        if (found != null) {
          return found;
        }
      }
    } catch (_) {}
    return defaultCountry;
  }

  static Country? findByCode(String code) {
    final upper = code.trim().toUpperCase();
    for (final c in allCountries) {
      if (c.code == upper) return c;
    }
    return null;
  }

  static Country? findByName(String name) {
    final lower = name.trim().toLowerCase();
    for (final c in allCountries) {
      if (c.name.toLowerCase() == lower) return c;
    }
    return null;
  }

  static Country? findByDialCode(String dialCode) {
    var clean = dialCode.trim();
    if (!clean.startsWith('+')) {
      clean = '+$clean';
    }
    for (final c in allCountries) {
      if (c.dialCode == clean) return c;
    }
    return null;
  }

  /// Complete list of global countries with ISO codes, dial codes, and emoji flags
  static const List<Country> allCountries = [
    Country(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
    Country(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
    Country(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
    Country(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    Country(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
    Country(name: 'United Arab Emirates', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
    Country(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
    Country(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    Country(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    Country(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬'),
    Country(name: 'Malaysia', code: 'MY', dialCode: '+60', flag: '🇲🇾'),
    Country(name: 'Qatar', code: 'QA', dialCode: '+974', flag: '🇶🇦'),
    Country(name: 'Kuwait', code: 'KW', dialCode: '+965', flag: '🇰🇼'),
    Country(name: 'Oman', code: 'OM', dialCode: '+968', flag: '🇴🇲'),
    Country(name: 'Bahrain', code: 'BH', dialCode: '+973', flag: '🇧🇭'),
    Country(name: 'Pakistan', code: 'PK', dialCode: '+92', flag: '🇵🇰'),
    Country(name: 'Bangladesh', code: 'BD', dialCode: '+880', flag: '🇧🇩'),
    Country(name: 'Sri Lanka', code: 'LK', dialCode: '+94', flag: '🇱🇰'),
    Country(name: 'Nepal', code: 'NP', dialCode: '+977', flag: '🇳🇵'),
    Country(name: 'New Zealand', code: 'NZ', dialCode: '+64', flag: '🇳🇿'),
    Country(name: 'Ireland', code: 'IE', dialCode: '+353', flag: '🇮🇪'),
    Country(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
    Country(name: 'South Korea', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
    Country(name: 'China', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
    Country(name: 'Hong Kong', code: 'HK', dialCode: '+852', flag: '🇭🇰'),
    Country(name: 'Taiwan', code: 'TW', dialCode: '+886', flag: '🇹🇼'),
    Country(name: 'Indonesia', code: 'ID', dialCode: '+62', flag: '🇮🇩'),
    Country(name: 'Philippines', code: 'PH', dialCode: '+63', flag: '🇵🇭'),
    Country(name: 'Thailand', code: 'TH', dialCode: '+66', flag: '🇹🇭'),
    Country(name: 'Vietnam', code: 'VN', dialCode: '+84', flag: '🇻🇳'),
    Country(name: 'Italy', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
    Country(name: 'Spain', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
    Country(name: 'Netherlands', code: 'NL', dialCode: '+31', flag: '🇳🇱'),
    Country(name: 'Switzerland', code: 'CH', dialCode: '+41', flag: '🇨🇭'),
    Country(name: 'Sweden', code: 'SE', dialCode: '+46', flag: '🇸🇪'),
    Country(name: 'Norway', code: 'NO', dialCode: '+47', flag: '🇳🇴'),
    Country(name: 'Denmark', code: 'DK', dialCode: '+45', flag: '🇩🇰'),
    Country(name: 'Finland', code: 'FI', dialCode: '+358', flag: '🇫🇮'),
    Country(name: 'Belgium', code: 'BE', dialCode: '+32', flag: '🇧🇪'),
    Country(name: 'Austria', code: 'AT', dialCode: '+43', flag: '🇦🇹'),
    Country(name: 'Poland', code: 'PL', dialCode: '+48', flag: '🇵🇱'),
    Country(name: 'Portugal', code: 'PT', dialCode: '+351', flag: '🇵🇹'),
    Country(name: 'Greece', code: 'GR', dialCode: '+30', flag: '🇬🇷'),
    Country(name: 'Turkey', code: 'TR', dialCode: '+90', flag: '🇹🇷'),
    Country(name: 'Brazil', code: 'BR', dialCode: '+55', flag: '🇧🇷'),
    Country(name: 'Mexico', code: 'MX', dialCode: '+52', flag: '🇲🇽'),
    Country(name: 'Argentina', code: 'AR', dialCode: '+54', flag: '🇦🇷'),
    Country(name: 'South Africa', code: 'ZA', dialCode: '+27', flag: '🇿🇦'),
    Country(name: 'Egypt', code: 'EG', dialCode: '+20', flag: '🇪🇬'),
    Country(name: 'Nigeria', code: 'NG', dialCode: '+234', flag: '🇳🇬'),
    Country(name: 'Kenya', code: 'KE', dialCode: '+254', flag: '🇰🇪'),
    Country(name: 'Ghana', code: 'GH', dialCode: '+233', flag: '🇬🇭'),
    Country(name: 'Israel', code: 'IL', dialCode: '+972', flag: '🇮🇱'),
    Country(name: 'Jordan', code: 'JO', dialCode: '+962', flag: '🇯🇴'),
    Country(name: 'Czech Republic', code: 'CZ', dialCode: '+420', flag: '🇨🇿'),
    Country(name: 'Hungary', code: 'HU', dialCode: '+36', flag: '🇭🇺'),
    Country(name: 'Romania', code: 'RO', dialCode: '+40', flag: '🇷🇴'),
    Country(name: 'Ukraine', code: 'UA', dialCode: '+380', flag: '🇺🇦'),
    Country(name: 'Colombia', code: 'CO', dialCode: '+57', flag: '🇨🇴'),
    Country(name: 'Chile', code: 'CL', dialCode: '+56', flag: '🇨🇱'),
    Country(name: 'Peru', code: 'PE', dialCode: '+51', flag: '🇵🇪'),
    Country(name: 'Algeria', code: 'DZ', dialCode: '+213', flag: '🇩🇿'),
    Country(name: 'Morocco', code: 'MA', dialCode: '+212', flag: '🇲🇦'),
    Country(name: 'Tunisia', code: 'TN', dialCode: '+216', flag: '🇹🇳'),
    Country(name: 'Lebanon', code: 'LB', dialCode: '+961', flag: '🇱🇧'),
    Country(name: 'Iraq', code: 'IQ', dialCode: '+964', flag: '🇮🇶'),
    Country(name: 'Kazakhstan', code: 'KZ', dialCode: '+7', flag: '🇰🇿'),
    Country(name: 'Uzbekistan', code: 'UZ', dialCode: '+998', flag: '🇺🇿'),
    Country(name: 'Ethiopia', code: 'ET', dialCode: '+251', flag: '🇪🇹'),
    Country(name: 'Tanzania', code: 'TZ', dialCode: '+255', flag: '🇹🇿'),
    Country(name: 'Uganda', code: 'UG', dialCode: '+256', flag: '🇺🇬'),
    Country(name: 'Mauritius', code: 'MU', dialCode: '+230', flag: '🇲🇺'),
    Country(name: 'Cyprus', code: 'CY', dialCode: '+357', flag: '🇨🇾'),
    Country(name: 'Malta', code: 'MT', dialCode: '+356', flag: '🇲🇹'),
    Country(name: 'Luxembourg', code: 'LU', dialCode: '+352', flag: '🇱🇺'),
    Country(name: 'Iceland', code: 'IS', dialCode: '+354', flag: '🇮🇸'),
    Country(name: 'Estonia', code: 'EE', dialCode: '+372', flag: '🇪🇪'),
    Country(name: 'Latvia', code: 'LV', dialCode: '+371', flag: '🇱🇻'),
    Country(name: 'Lithuania', code: 'LT', dialCode: '+370', flag: '🇱🇹'),
    Country(name: 'Croatia', code: 'HR', dialCode: '+385', flag: '🇭🇷'),
    Country(name: 'Bulgaria', code: 'BG', dialCode: '+359', flag: '🇧🇬'),
    Country(name: 'Slovakia', code: 'SK', dialCode: '+421', flag: '🇸🇰'),
    Country(name: 'Slovenia', code: 'SI', dialCode: '+386', flag: '🇸🇮'),
    Country(name: 'Serbia', code: 'RS', dialCode: '+381', flag: '🇷🇸'),
  ];
}

