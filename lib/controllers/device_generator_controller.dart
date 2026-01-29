import 'dart:math';
import 'package:random/config/device_constants.dart';

class DeviceGeneratorController {
  final Random _random = Random();

  String generateDeviceName({required String category}) {
    String selectedCategory = category;

    // If random, pick a random category
    if (category == 'Random') {
      final categories = DeviceConstants.namePatterns.keys.toList();
      selectedCategory = categories[_random.nextInt(categories.length)];
    }

    // Get patterns for the selected category
    final patterns = DeviceConstants.namePatterns[selectedCategory]!;
    final pattern = patterns[_random.nextInt(patterns.length)];

    // Generate device name from pattern
    return _generateFromPattern(pattern);
  }

  String _generateFromPattern(String pattern) {
    return pattern.replaceAllMapped(RegExp(r'#'), (match) {
      return _random.nextInt(10).toString();
    });
  }
}
