import 'dart:io' show File, Platform;
import 'package:gal/gal.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import 'package:universal_html/html.dart' as html;

class ExifEraserPage extends StatefulWidget {
  const ExifEraserPage({super.key});

  @override
  State<ExifEraserPage> createState() => _ExifEraserPageState();
}

class _ExifEraserPageState extends State<ExifEraserPage> {
  File? _selectedImage;
  File? _processedImage;
  bool _isProcessing = false;
  bool _hasExifData = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _webImageBytes;
  Uint8List? _webProcessedBytes;
  Map<String, String> _exifData = {};
  bool _showExifDetails = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.first.bytes != null) {
          setState(() {
            _webImageBytes = result.files.first.bytes;
            _selectedImage = null;
            _processedImage = null;
            _hasExifData = false;
            _exifData = {};
          });

          // Extract EXIF data for web
          await _extractExifData(_webImageBytes!);
        }
      } else {
        // Use image_picker for mobile
        final XFile? image = await _picker.pickImage(source: source);
        if (image == null) return;

        setState(() {
          _selectedImage = File(image.path);
          _processedImage = null;
          _hasExifData = false;
          _webImageBytes = null;
          _exifData = {};
        });

        // Extract EXIF data for mobile
        final bytes = await _selectedImage!.readAsBytes();
        await _extractExifData(bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _extractExifData(Uint8List bytes) async {
    try {
      final originalImage = img.decodeImage(bytes);
      if (originalImage != null) {
        Map<String, String> exifMap = {};

        // Check for EXIF data
        bool hasExif = false;

        // Image IFD
        final imageIfdData = originalImage.exif.imageIfd;
        if (imageIfdData.values.isNotEmpty) {
          hasExif = true;
          for (var key in imageIfdData.keys) {
            final value = imageIfdData[key];
            if (value != null) {
              exifMap['Image: $key'] = value.toString();
            }
          }
        }

        // EXIF IFD
        final exifIfdData = originalImage.exif.exifIfd;
        if (exifIfdData.values.isNotEmpty) {
          hasExif = true;
          for (var key in exifIfdData.keys) {
            final value = exifIfdData[key];
            if (value != null) {
              exifMap['EXIF: $key'] = value.toString();
            }
          }
        }

        // GPS IFD
        final gpsIfdData = originalImage.exif.gpsIfd;
        if (gpsIfdData.values.isNotEmpty) {
          hasExif = true;
          for (var key in gpsIfdData.keys) {
            final value = gpsIfdData[key];
            if (value != null) {
              exifMap['GPS: $key'] = value.toString();
            }
          }
        }

        // Thumbnail IFD
        final thumbnailIfdData = originalImage.exif.thumbnailIfd;
        if (thumbnailIfdData.values.isNotEmpty) {
          hasExif = true;
          for (var key in thumbnailIfdData.keys) {
            final value = thumbnailIfdData[key];
            if (value != null) {
              exifMap['Thumbnail: $key'] = value.toString();
            }
          }
        }

        setState(() {
          _hasExifData = hasExif;
          _exifData = exifMap;
        });
      }
    } catch (e) {
      setState(() {
        _hasExifData = true;
        _exifData = {'Error': 'Could not parse EXIF data'};
      });
    }
  }

  Future<void> _removeExif() async {
    if (!kIsWeb && _selectedImage == null) return;
    if (kIsWeb && _webImageBytes == null) return;

    setState(() => _isProcessing = true);

    try {
      // Read the image
      final bytes = kIsWeb
          ? _webImageBytes!
          : await _selectedImage!.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Clear EXIF data explicitly
      image.exif.clear();

      // Encode as JPEG without any metadata
      // The key is to encode directly without copyResize which may preserve metadata
      final newBytes = img.encodeJpg(image, quality: 95);

      if (kIsWeb) {
        setState(() {
          _webProcessedBytes = newBytes;
          _isProcessing = false;
        });
      } else {
        // For mobile/desktop, save to temp directory
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newPath = '${tempDir.path}/exif_erased_$timestamp.jpg';
        final newFile = File(newPath);
        await newFile.writeAsBytes(newBytes);

        setState(() {
          _processedImage = newFile;
          _isProcessing = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('EXIF data removed successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error processing image: $e')));
      }
    }
  }

  Future<void> _saveImage() async {
    if (kIsWeb) {
      if (_webProcessedBytes == null) return;

      try {
        final blob = html.Blob([_webProcessedBytes!]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute(
            'download',
            'exif_erased_${DateTime.now().millisecondsSinceEpoch}.jpg',
          )
          ..click();
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image downloaded successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading image: $e')),
          );
        }
      }
      return;
    }

    if (_processedImage == null) return;

    try {
      final bytes = await _processedImage!.readAsBytes();

      if (Platform.isAndroid || Platform.isIOS) {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          final granted = await Gal.requestAccess();
          if (!granted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permission denied. Cannot save to gallery.'),
                ),
              );
            }
            return;
          }
        }

        // Save to "Random" album only on Android
        if (Platform.isAndroid) {
          await Gal.putImageBytes(
            bytes,
            album: "Random",
            name: "exif_erased_${DateTime.now().millisecondsSinceEpoch}",
          );
        } else {
          // iOS: save without album parameter
          await Gal.putImageBytes(
            bytes,
            name: "exif_erased_${DateTime.now().millisecondsSinceEpoch}",
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Platform.isAndroid
                    ? 'Image saved to "Pictures/Random/"'
                    : 'Image saved to gallery!',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        String? selectedDirectory = await FilePicker.platform
            .getDirectoryPath();

        if (selectedDirectory == null) return;

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'exif_erased_$timestamp.jpg';
        final savePath = '$selectedDirectory/$fileName';

        final saveFile = File(savePath);
        await saveFile.writeAsBytes(bytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image saved to: $savePath'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () async {
                  await OpenFile.open(savePath);
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    }
  }

  Future<void> _shareImage() async {
    if (kIsWeb && _webImageBytes == null) return;
    if (!kIsWeb && _processedImage == null) return;

    try {
      if (kIsWeb) {
        // Web download instead of share
        await _saveImage();
      } else {
        await Share.shareXFiles([
          XFile(_processedImage!.path),
        ], text: 'Image with EXIF data removed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing image: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (!kIsWeb) // Camera not available on web
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (kIsWeb && _webProcessedBytes != null) {
      return Image.memory(
        _webProcessedBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (kIsWeb && _webImageBytes != null) {
      return Image.memory(
        _webImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (_processedImage != null) {
      return Image.file(
        _processedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = kIsWeb ? _webImageBytes != null : _selectedImage != null;
    final isProcessed = kIsWeb
        ? _webProcessedBytes != null
        : _processedImage != null;

    return Scaffold(
      appBar: AppBar(title: const Text('EXIF Eraser')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Image Preview Section
          if (hasImage) ...[
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
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
                                onPressed: _saveImage,
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
                                  onPressed: _shareImage,
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
            ),
            const SizedBox(height: 16),
          ],

          // EXIF Data Section
          if (_hasExifData && !isProcessed && _exifData.isNotEmpty) ...[
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surface,
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showExifDetails = !_showExifDetails;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'EXIF Data Detected (${_exifData.length} fields)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Icon(
                            _showExifDetails
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This image contains EXIF metadata',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'EXIF data may include location, camera model, date, and other metadata.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_showExifDetails) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EXIF Details:',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._exifData.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            entry.key,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'monospace',
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            entry.value,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontFamily: 'monospace',
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Success Section
          if (isProcessed) ...[
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
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
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'EXIF Data Removed',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Your image has been processed and all EXIF metadata has been removed. You can now save or share it safely.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Buttons Section
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
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
                          onPressed: _showImageSourceDialog,
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
                          onPressed: _isProcessing ? null : _removeExif,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_sweep),
                          label: Text(
                            _isProcessing
                                ? 'Processing...'
                                : 'Remove EXIF Data',
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
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                              _processedImage = null;
                              _hasExifData = false;
                              _webImageBytes = null;
                              _exifData = {};
                              _showExifDetails = false;
                            });
                          },
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
                          onPressed: _showImageSourceDialog,
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
          ),
          const SizedBox(height: 24),

          // Info Section
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
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
                        Icons.help_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About EXIF Data',
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
                  child: Text(
                    'EXIF (Exchangeable Image File Format) data is metadata embedded in photos. '
                    'It can include GPS location, camera settings, date and time, and more. '
                    'Removing EXIF data helps protect your privacy when sharing images online.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
