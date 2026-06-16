import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage(
    this.source, {
    required this.fit,
    this.width,
    this.height,
    super.key,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bytes = _dataUriBytes(source);
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
      );
    }
    return Image.asset(source, width: width, height: height, fit: fit);
  }
}

Uint8List? _dataUriBytes(String source) {
  if (!source.startsWith('data:image/')) return null;
  final separator = source.indexOf(',');
  if (separator == -1) return null;
  return base64Decode(source.substring(separator + 1));
}

ImageProvider appImageProvider(String source) {
  final bytes = _dataUriBytes(source);
  return bytes == null ? AssetImage(source) : MemoryImage(bytes);
}
