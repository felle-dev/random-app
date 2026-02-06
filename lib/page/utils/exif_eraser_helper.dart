import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gal/gal.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class ExifEraserHelper {
  static Future<String> saveImage({
    required Uint8List? webProcessedBytes,
    required File? processedImage,
  }) async {
    if (kIsWeb) {
      if (webProcessedBytes == null) {
        throw Exception('No processed image available');
      }

      final blob = html.Blob([webProcessedBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'exif_erased_${DateTime.now().millisecondsSinceEpoch}.jpg',
        )
        ..click();
      html.Url.revokeObjectUrl(url);

      return 'Image downloaded successfully!';
    }

    if (processedImage == null) {
      throw Exception('No processed image available');
    }

    final bytes = await processedImage.readAsBytes();

    if (Platform.isAndroid || Platform.isIOS) {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          throw Exception('Permission denied. Cannot save to gallery.');
        }
      }

      // Save to "Random" album only on Android
      if (Platform.isAndroid) {
        await Gal.putImageBytes(
          bytes,
          album: "Random",
          name: "exif_erased_${DateTime.now().millisecondsSinceEpoch}",
        );
        return 'Image saved to "Pictures/Random/"';
      } else {
        // iOS: save without album parameter
        await Gal.putImageBytes(
          bytes,
          name: "exif_erased_${DateTime.now().millisecondsSinceEpoch}",
        );
        return 'Image saved to gallery!';
      }
    } else {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        throw Exception('No directory selected');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'exif_erased_$timestamp.jpg';
      final savePath = '$selectedDirectory/$fileName';

      final saveFile = File(savePath);
      await saveFile.writeAsBytes(bytes);

      // Open file after saving (desktop platforms)
      await OpenFile.open(savePath);

      return 'Image saved to: $savePath';
    }
  }

  static Future<void> shareImage({
    required Uint8List? webImageBytes,
    required File? processedImage,
  }) async {
    if (kIsWeb && webImageBytes == null) {
      throw Exception('No image available to share');
    }
    if (!kIsWeb && processedImage == null) {
      throw Exception('No processed image available');
    }

    if (kIsWeb) {
      // Web download instead of share
      throw Exception('Use save/download for web');
    } else {
      await Share.shareXFiles([
        XFile(processedImage!.path),
      ], text: 'Image with EXIF data removed');
    }
  }
}
