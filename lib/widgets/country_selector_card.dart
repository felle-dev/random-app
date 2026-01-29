import 'package:flutter/material.dart';
import 'package:random/models/phone_country.dart';
import 'package:random/config/app_dimensions.dart';

class CountrySelectorCard extends StatelessWidget {
  final String title;
  final String selectedCountry;
  final Map<String, PhoneCountry> countries;
  final ValueChanged<String> onCountryChanged;

  const CountrySelectorCard({
    super.key,
    required this.title,
    required this.selectedCountry,
    required this.countries,
    required this.onCountryChanged,
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
                  Icons.public,
                  color: theme.colorScheme.primary,
                  size: AppDimensions.iconMedium,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Text(
                  title,
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
            child: Wrap(
              spacing: AppDimensions.spacing8,
              runSpacing: AppDimensions.spacing8,
              children: countries.entries.map((entry) {
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.value.flag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(entry.value.name),
                    ],
                  ),
                  selected: selectedCountry == entry.key,
                  onSelected: (selected) {
                    if (selected) onCountryChanged(entry.key);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
