import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ExifImagePreviewCard extends StatelessWidget {
  final File? selectedImage;
  final File? processedImage;
  final Uint8List? webImageBytes;
  final Uint8List? webProcessedBytes;
  final bool isProcessed;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const ExifImagePreviewCard({
    super.key,
    this.selectedImage,
    this.processedImage,
    this.webImageBytes,
    this.webProcessedBytes,
    required this.isProcessed,
    required this.onSave,
    required this.onShare,
  });

  Widget _buildImageWidget() {
    if (kIsWeb && webProcessedBytes != null) {
      return Image.memory(
        webProcessedBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (kIsWeb && webImageBytes != null) {
      return Image.memory(
        webImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (processedImage != null) {
      return Image.file(
        processedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    return const SizedBox.shrink();
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
                  Icons.image_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isProcessed ? 'Processed Image' : 'Selected Image',
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImageWidget(),
                ),
                if (isProcessed) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: onSave,
                        icon: const Icon(Icons.download),
                        label: Text(kIsWeb ? 'Download' : 'Save'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      if (!kIsWeb) const SizedBox(width: 12),
                      if (!kIsWeb)
                        OutlinedButton.icon(
                          onPressed: onShare,
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                    ],
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
