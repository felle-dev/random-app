import 'dart:math';
import 'package:random/models/phone_country.dart';

class PhoneGeneratorController {
  final Random _random = Random();

  Map<String, String> generatePhone(PhoneCountry country) {
    String phone = country.format;

    // Replace # with random digits
    for (int i = 0; i < phone.length; i++) {
      if (phone[i] == '#') {
        phone = phone.replaceFirst('#', _random.nextInt(10).toString());
      }
    }

    final fullNumber = '${country.countryCode} $phone';

    return {
      'number': phone,
      'full': fullNumber,
      'flag': country.flag,
      'country': country.name,
    };
  }
}
