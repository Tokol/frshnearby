import 'dart:convert';

import 'package:image_picker/image_picker.dart';

Future<String?> pickDeviceImage() async {
  final image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 82,
    maxWidth: 1800,
  );
  if (image == null) return null;
  final bytes = await image.readAsBytes();
  final mimeType = image.mimeType ?? 'image/jpeg';
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}

Future<List<String>> pickDeviceImages() async {
  final images = await ImagePicker().pickMultiImage(
    imageQuality: 82,
    maxWidth: 1800,
  );
  if (images.isEmpty) return const [];

  final encoded = <String>[];
  for (final image in images) {
    final bytes = await image.readAsBytes();
    final mimeType = image.mimeType ?? 'image/jpeg';
    encoded.add('data:$mimeType;base64,${base64Encode(bytes)}');
  }
  return encoded;
}
