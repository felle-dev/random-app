import 'package:flutter/material.dart';
import 'package:random/config/app_strings.dart';
import 'package:random/config/app_dimensions.dart';
import 'package:random/config/password_constants.dart';

class PasswordOptionsCard extends StatelessWidget {
  final int length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;
  final ValueChanged<int> onLengthChanged;
  final ValueChanged<bool> onUppercaseChanged;
  final ValueChanged<bool> onLowercaseChanged;
  final ValueChanged<bool> onNumbersChanged;
  final ValueChanged<bool> onSymbolsChanged;

  const PasswordOptionsCard({
    super.key,
    required this.length,
    required this.includeUppercase,
    required this.includeLowercase,
    required this.includeNumbers,
    required this.includeSymbols,
    required this.onLengthChanged,
    required this.onUppercaseChanged,
    required this.onLowercaseChanged,
    required this.onNumbersChanged,
    required this.onSymbolsChanged,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                Icon(
                  Icons.tune_outlined,
                  color: theme.colorScheme.primary,
                  size: AppDimensions.iconMedium,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Text(
                  AppStrings.options,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.length, style: theme.textTheme.titleMedium),
                    Text(
                      length.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing12),
                Slider(
                  value: length.toDouble(),
                  min: PasswordConstants.minLength.toDouble(),
                  max: PasswordConstants.maxLength.toDouble(),
                  divisions: PasswordConstants.divisions,
                  label: length.toString(),
                  onChanged: (value) => onLengthChanged(value.toInt()),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          SwitchListTile(
            title: const Text(AppStrings.uppercaseLetters),
            subtitle: const Text(AppStrings.uppercaseSubtitle),
            value: includeUppercase,
            onChanged: onUppercaseChanged,
          ),
          Divider(
            height: 1,
            indent: AppDimensions.paddingMedium,
            endIndent: AppDimensions.paddingMedium,
            color: theme.colorScheme.outlineVariant,
          ),
          SwitchListTile(
            title: const Text(AppStrings.lowercaseLetters),
            subtitle: const Text(AppStrings.lowercaseSubtitle),
            value: includeLowercase,
            onChanged: onLowercaseChanged,
          ),
          Divider(
            height: 1,
            indent: AppDimensions.paddingMedium,
            endIndent: AppDimensions.paddingMedium,
            color: theme.colorScheme.outlineVariant,
          ),
          SwitchListTile(
            title: const Text(AppStrings.numbersLabel),
            subtitle: const Text(AppStrings.numbersSubtitle),
            value: includeNumbers,
            onChanged: onNumbersChanged,
          ),
          Divider(
            height: 1,
            indent: AppDimensions.paddingMedium,
            endIndent: AppDimensions.paddingMedium,
            color: theme.colorScheme.outlineVariant,
          ),
          SwitchListTile(
            title: const Text(AppStrings.symbolsLabel),
            subtitle: const Text(AppStrings.symbolsSubtitle),
            value: includeSymbols,
            onChanged: onSymbolsChanged,
          ),
        ],
      ),
    );
  }
}
