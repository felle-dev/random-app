import 'dart:io';
import 'package:flutter/material.dart';
import '../../../config/app_strings.dart';

class DeviceInformationCard extends StatelessWidget {
  final Map<String, String> deviceData;
  final VoidCallback onCopyAll;

  const DeviceInformationCard({
    super.key,
    required this.deviceData,
    required this.onCopyAll,
  });

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
                  Platform.isWindows || Platform.isLinux || Platform.isMacOS
                      ? Icons.computer_outlined
                      : Icons.phone_android_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.deviceInfoDeviceInformation,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_all, size: 20),
                  onPressed: onCopyAll,
                  tooltip: AppStrings.deviceInfoCopyAll,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ...deviceData.entries.map((entry) {
            return Column(
              children: [
                ListTile(
                  title: Text(
                    entry.key,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entry.value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (entry.key != deviceData.entries.last.key)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.colorScheme.outlineVariant,
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
