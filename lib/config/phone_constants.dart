import 'package:random/models/phone_country.dart';

class PhoneConstants {
  static const Map<String, PhoneCountry> countries = {
    'US': PhoneCountry(
      code: 'US',
      name: 'United States',
      countryCode: '+1',
      flag: '🇺🇸',
      format: '(###) ###-####',
      example: '(555) 123-4567',
    ),
    'GB': PhoneCountry(
      code: 'GB',
      name: 'United Kingdom',
      countryCode: '+44',
      flag: '🇬🇧',
      format: '#### ### ####',
      example: '7700 900123',
    ),
    'DE': PhoneCountry(
      code: 'DE',
      name: 'Germany',
      countryCode: '+49',
      flag: '🇩🇪',
      format: '#### ########',
      example: '0151 23456789',
    ),
    'FR': PhoneCountry(
      code: 'FR',
      name: 'France',
      countryCode: '+33',
      flag: '🇫🇷',
      format: '# ## ## ## ##',
      example: '6 12 34 56 78',
    ),
    'ID': PhoneCountry(
      code: 'ID',
      name: 'Indonesia',
      countryCode: '+62',
      flag: '🇮🇩',
      format: '8##-####-####',
      example: '812-3456-7890',
    ),
    'JP': PhoneCountry(
      code: 'JP',
      name: 'Japan',
      countryCode: '+81',
      flag: '🇯🇵',
      format: '##-####-####',
      example: '90-1234-5678',
    ),
    'AU': PhoneCountry(
      code: 'AU',
      name: 'Australia',
      countryCode: '+61',
      flag: '🇦🇺',
      format: '#### ### ###',
      example: '0412 345 678',
    ),
    'CA': PhoneCountry(
      code: 'CA',
      name: 'Canada',
      countryCode: '+1',
      flag: '🇨🇦',
      format: '(###) ###-####',
      example: '(416) 555-0123',
    ),
  };
}
