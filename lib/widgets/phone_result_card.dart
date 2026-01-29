import 'package:flutter/material.dart';
import 'package:random/models/phone_country.dart';
import 'package:random/config/app_strings.dart';
import 'package:random/config/app_dimensions.dart';

class PhoneResultCard extends StatelessWidget {
  final PhoneCountry country;
  final String phoneNumber;
  final String fullNumber;
  final VoidCallback onCopyWithCode;
  final VoidCallback onCopyWithoutCode;
  final VoidCallback onGenerate;

  const PhoneResultCard({
    super.key,
    required this.country,
    required this.phoneNumber,
    required this.fullNumber,
    required this.onCopyWithCode,
    required this.onCopyWithoutCode,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  color: theme.colorScheme.primary,
                  size: AppDimensions.iconMedium,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Text(
                  AppStrings.generatedPhone,
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
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              children: [
                // Country Flag and Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(country.flag, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: AppDimensions.spacing12),
                    Text(
                      country.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                // Full Phone Number with Country Code
                SelectableText(
                  fullNumber,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onCopyWithCode,
                        icon: const Icon(Icons.copy),
                        label: const Text(AppStrings.withCode),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                            vertical: AppDimensions.spacing12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: onGenerate,
                        icon: const Icon(Icons.refresh),
                        label: const Text(AppStrings.generate),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                            vertical: AppDimensions.spacing12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing8),
                OutlinedButton.icon(
                  onPressed: onCopyWithoutCode,
                  icon: const Icon(Icons.copy, size: AppDimensions.iconSmall),
                  label: const Text(AppStrings.copyWithoutCode),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingLarge,
                      vertical: 10,
                    ),
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
