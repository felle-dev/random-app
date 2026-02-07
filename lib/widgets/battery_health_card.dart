import 'package:flutter/material.dart';
import '../../../config/app_strings.dart';
import '../../../config/device_info_constants.dart';

class BatteryHealthCard extends StatelessWidget {
  final Map<String, String> batteryData;
  final int chargingCycles;
  final int batteryLevel;

  const BatteryHealthCard({
    super.key,
    required this.batteryData,
    required this.chargingCycles,
    required this.batteryLevel,
  });

  Color _getBatteryColor(int level, ThemeData theme) {
    if (level >= DeviceInfoConstants.batteryFairThreshold) {
      return theme.colorScheme.primary;
    }
    if (level >= DeviceInfoConstants.batteryLowThreshold) {
      return Colors.orange;
    }
    return theme.colorScheme.error;
  }

  Widget _buildBatteryIndicator(int level, ThemeData theme) {
    return Container(
      width: DeviceInfoConstants.batteryIndicatorWidth,
      height: DeviceInfoConstants.batteryIndicatorHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: _getBatteryColor(level, theme),
          width: DeviceInfoConstants.batteryIndicatorBorderWidth,
        ),
        borderRadius: BorderRadius.circular(
          DeviceInfoConstants.batteryIndicatorBorderRadius,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: DeviceInfoConstants.batteryCapHeight,
            width: DeviceInfoConstants.batteryCapWidth,
            margin: EdgeInsets.only(
              top: DeviceInfoConstants.batteryCapTopMargin,
            ),
            decoration: BoxDecoration(
              color: _getBatteryColor(level, theme),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(
                  DeviceInfoConstants.batteryCapBorderRadius,
                ),
                bottomRight: Radius.circular(
                  DeviceInfoConstants.batteryCapBorderRadius,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(
                DeviceInfoConstants.batteryIndicatorPadding,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    height:
                        (DeviceInfoConstants.batteryIndicatorHeight -
                            DeviceInfoConstants.batteryCapHeight) *
                        (level / 100),
                    decoration: BoxDecoration(
                      color: _getBatteryColor(level, theme),
                      borderRadius: BorderRadius.circular(
                        DeviceInfoConstants.batteryInnerBorderRadius,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.battery_charging_full,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.deviceInfoBatteryHealth,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildBatteryIndicator(batteryLevel, theme),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...batteryData.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.value,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.deviceInfoChargingCycles,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chargingCycles ==
                                      DeviceInfoConstants.batteryUnknownCycles
                                  ? DeviceInfoConstants.notAvailableValue
                                  : chargingCycles.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
