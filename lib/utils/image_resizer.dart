import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:flutter/foundation.dart';

Future<Uint8List> resizeImage(File imageFile) async {
  final image = img.decodeImage(await imageFile.readAsBytes());
  if (image == null) {
    throw Exception('Could not decode image');
  }

  // Resize the image to a standard web size (e.g., 1024 pixels wide)
  final resizedImage = img.copyResize(image, width: 1024);

  // Encode the image to JPEG format
  final encodedImage = img.encodeJpg(resizedImage, quality: 85);

  return Uint8List.fromList(encodedImage);
}
