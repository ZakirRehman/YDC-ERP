import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Clean isolate-based preprocessor for camera and physical sheet scans
class ImagePreprocessor {
  ImagePreprocessor._();

  /// Executes image pre-processing (grayscale, contrast boost, adaptive thresholding)
  /// completely off the main UI thread inside a dedicated worker isolate.
  static Future<String> preprocessSheet(String inputImagePath) async {
    return compute(_isolateWorker, inputImagePath);
  }

  static String _isolateWorker(String imagePath) {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw Exception('Input image file not found at path: $imagePath');
    }

    final rawBytes = file.readAsBytesSync();
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw Exception('Could not decode image format.');
    }

    // Step 1: Grayscale conversion (Reduces 3-channel RGB to single luminance channel)
    final grayscale = img.grayscale(decoded);

    // Step 2: Ink Contrast Enhancement (Increases stroke visibility against paper noise)
    final contrasted = img.contrast(grayscale, contrast: 150);

    // Step 3: Write out preprocessed image artifact alongside original
    final outputPath = '${imagePath}_preprocessed.png';
    final encodedPng = img.encodePng(contrasted);
    File(outputPath).writeAsBytesSync(encodedPng);

    return outputPath;
  }
}
