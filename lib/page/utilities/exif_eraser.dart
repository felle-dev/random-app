import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/exif_eraser_controller.dart';
import '../utils/exif_eraser_helper.dart';
import '../widgets/exif_image_preview_card.dart';
import '../widgets/exif_data_card.dart';
import '../widgets/exif_success_card.dart';
import '../widgets/exif_actions_card.dart';
import '../widgets/exif_info_card.dart';

class ExifEraserPage extends StatefulWidget {
  const ExifEraserPage({super.key});

  @override
  State<ExifEraserPage> createState() => _ExifEraserPageState();
}

class _ExifEraserPageState extends State<ExifEraserPage> {
  late ExifEraserController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExifEraserController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      await _controller.pickImage(source);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _removeExif() async {
    try {
      await _controller.removeExif();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('EXIF data removed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error processing image: $e')));
      }
    }
  }

  Future<void> _saveImage() async {
    try {
      final message = await ExifEraserHelper.saveImage(
        webProcessedBytes: _controller.webProcessedBytes,
        processedImage: _controller.processedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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
    try {
      if (kIsWeb) {
        // Web uses download instead of share
        await _saveImage();
      } else {
        await ExifEraserHelper.shareImage(
          webImageBytes: _controller.webImageBytes,
          processedImage: _controller.processedImage,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EXIF Eraser')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Image Preview Section
              if (_controller.hasImage) ...[
                ExifImagePreviewCard(
                  selectedImage: _controller.selectedImage,
                  processedImage: _controller.processedImage,
                  webImageBytes: _controller.webImageBytes,
                  webProcessedBytes: _controller.webProcessedBytes,
                  isProcessed: _controller.isProcessed,
                  onSave: _saveImage,
                  onShare: _shareImage,
                ),
                const SizedBox(height: 16),
              ],

              // EXIF Data Section
              if (_controller.hasExifData &&
                  !_controller.isProcessed &&
                  _controller.exifData.isNotEmpty) ...[
                ExifDataCard(
                  exifData: _controller.exifData,
                  showExifDetails: _controller.showExifDetails,
                  onToggleDetails: _controller.toggleExifDetails,
                ),
                const SizedBox(height: 16),
              ],

              // Success Section
              if (_controller.isProcessed) ...[
                const ExifSuccessCard(),
                const SizedBox(height: 16),
              ],

              // Action Buttons Section
              ExifActionsCard(
                hasImage: _controller.hasImage,
                isProcessed: _controller.isProcessed,
                isProcessing: _controller.isProcessing,
                onSelectImage: _showImageSourceDialog,
                onRemoveExif: _removeExif,
                onClear: _controller.clear,
              ),
              const SizedBox(height: 24),

              // Info Section
              const ExifInfoCard(),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }
}
