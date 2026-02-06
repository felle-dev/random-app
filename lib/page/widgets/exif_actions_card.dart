import 'package:flutter/material.dart';

class ExifActionsCard extends StatelessWidget {
  final bool hasImage;
  final bool isProcessed;
  final bool isProcessing;
  final VoidCallback onSelectImage;
  final VoidCallback onRemoveExif;
  final VoidCallback onClear;

  const ExifActionsCard({
    super.key,
    required this.hasImage,
    required this.isProcessed,
    required this.isProcessing,
    required this.onSelectImage,
    required this.onRemoveExif,
    required this.onClear,
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
                  Icons.tune_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions',
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
            child: Column(
              children: [
                if (!hasImage)
                  FilledButton.icon(
                    onPressed: onSelectImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Select Image'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  )
                else if (!isProcessed) ...[
                  FilledButton.icon(
                    onPressed: isProcessing ? null : onRemoveExif,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_sweep),
                    label: Text(
                      isProcessing ? 'Processing...' : 'Remove EXIF Data',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ] else ...[
                  FilledButton.icon(
                    onPressed: onSelectImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Select New Image'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
