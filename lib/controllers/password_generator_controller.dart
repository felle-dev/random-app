import 'dart:math';
import 'package:random/config/password_constants.dart';

class PasswordGeneratorController {
  final Random _random = Random.secure();

  String generatePassword({
    required int length,
    required bool includeUppercase,
    required bool includeLowercase,
    required bool includeNumbers,
    required bool includeSymbols,
  }) {
    String chars = '';
    if (includeUppercase) chars += PasswordConstants.uppercase;
    if (includeLowercase) chars += PasswordConstants.lowercase;
    if (includeNumbers) chars += PasswordConstants.numbers;
    if (includeSymbols) chars += PasswordConstants.symbols;

    if (chars.isEmpty) return '';

    return List.generate(
      length,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  String getStrengthLabel({
    required int length,
    required bool includeUppercase,
    required bool includeLowercase,
    required bool includeNumbers,
    required bool includeSymbols,
  }) {
    int strength = 0;
    if (includeUppercase) strength++;
    if (includeLowercase) strength++;
    if (includeNumbers) strength++;
    if (includeSymbols) strength++;

    if (length >= 16 && strength >= 3) return 'Very Strong';
    if (length >= 12 && strength >= 3) return 'Strong';
    if (length >= 10 && strength >= 2) return 'Medium';
    return 'Weak';
  }
}
