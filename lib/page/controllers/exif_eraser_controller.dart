// ignore: unused_shown_name
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class ExifEraserController extends ChangeNotifier {
  File? _selectedImage;
  File? _processedImage;
  bool _isProcessing = false;
  bool _hasExifData = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _webImageBytes;
  Uint8List? _webProcessedBytes;
  Map<String, String> _exifData = {};
  bool _showExifDetails = false;

  // Getters
  File? get selectedImage => _selectedImage;
  File? get processedImage => _processedImage;
  bool get isProcessing => _isProcessing;
  bool get hasExifData => _hasExifData;
  Uint8List? get webImageBytes => _webImageBytes;
  Uint8List? get webProcessedBytes => _webProcessedBytes;
  Map<String, String> get exifData => _exifData;
  bool get showExifDetails => _showExifDetails;
  bool get hasImage => kIsWeb ? _webImageBytes != null : _selectedImage != null;
  bool get isProcessed =>
      kIsWeb ? _webProcessedBytes != null : _processedImage != null;

  void toggleExifDetails() {
    _showExifDetails = !_showExifDetails;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.first.bytes != null) {
          _webImageBytes = result.files.first.bytes;
          _selectedImage = null;
          _processedImage = null;
          _hasExifData = false;
          _exifData = {};
          _webProcessedBytes = null;
          notifyListeners();

          // Extract EXIF data for web
          await _extractExifData(_webImageBytes!);
        }
      } else {
        // Use image_picker for mobile
        final XFile? image = await _picker.pickImage(source: source);
        if (image == null) return;

        _selectedImage = File(image.path);
        _processedImage = null;
        _hasExifData = false;
        _webImageBytes = null;
        _webProcessedBytes = null;
        _exifData = {};
        notifyListeners();

        // Extract EXIF data for mobile
        final bytes = await _selectedImage!.readAsBytes();
        await _extractExifData(bytes);
      }
    } catch (e) {
      rethrow;
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

        _hasExifData = hasExif;
        _exifData = exifMap;
        notifyListeners();
      }
    } catch (e) {
      _hasExifData = true;
      _exifData = {'Error': 'Could not parse EXIF data'};
      notifyListeners();
    }
  }

  Future<void> removeExif() async {
    if (!kIsWeb && _selectedImage == null) return;
    if (kIsWeb && _webImageBytes == null) return;

    _isProcessing = true;
    notifyListeners();

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
      final newBytes = img.encodeJpg(image, quality: 95);

      if (kIsWeb) {
        _webProcessedBytes = newBytes;
        _isProcessing = false;
        notifyListeners();
      } else {
        // For mobile/desktop, save to temp directory
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newPath = '${tempDir.path}/exif_erased_$timestamp.jpg';
        final newFile = File(newPath);
        await newFile.writeAsBytes(newBytes);

        _processedImage = newFile;
        _isProcessing = false;
        notifyListeners();
      }
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _selectedImage = null;
    _processedImage = null;
    _hasExifData = false;
    _webImageBytes = null;
    _webProcessedBytes = null;
    _exifData = {};
    _showExifDetails = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _selectedImage = null;
    _processedImage = null;
    _webImageBytes = null;
    _webProcessedBytes = null;
    super.dispose();
  }
}
