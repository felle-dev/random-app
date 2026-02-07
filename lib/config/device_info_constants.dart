/// Configuration constants for Device Info feature
class DeviceInfoConstants {
  // Platform channel
  static const String batteryInfoChannel = 'com.random.app/battery_info';
  static const String getBatteryCyclesMethod = 'getBatteryCycles';

  // macOS command
  static const String macOSSystemProfiler = 'system_profiler';
  static const String macOSPowerDataType = 'SPPowerDataType';

  // Battery health thresholds
  static const int batteryGoodThreshold = 80;
  static const int batteryFairThreshold = 50;
  static const int batteryLowThreshold = 20;

  // Battery indicator dimensions
  static const double batteryIndicatorWidth = 80.0;
  static const double batteryIndicatorHeight = 120.0;
  static const double batteryIndicatorBorderWidth = 3.0;
  static const double batteryIndicatorBorderRadius = 8.0;
  static const double batteryCapHeight = 8.0;
  static const double batteryCapWidth = 30.0;
  static const double batteryCapTopMargin = -3.0;
  static const double batteryCapBorderRadius = 4.0;
  static const double batteryIndicatorPadding = 4.0;
  static const double batteryInnerBorderRadius = 4.0;

  // Battery health calculation
  static const int batteryUnknownCycles = -1;

  // Memory conversion
  static const int megabytesToGigabytes = 1024;
  static const int memoryDecimalPlaces = 2;

  // Error states
  static const String errorKey = 'Error';
  static const String notAvailableValue = 'N/A';

  // RegEx patterns
  static const String macOSCycleCountPattern = r'Cycle Count:\s*(\d+)';
}
