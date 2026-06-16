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
