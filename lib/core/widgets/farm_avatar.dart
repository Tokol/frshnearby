import 'package:flutter/material.dart';

import 'app_image.dart';

class FarmAvatar extends StatelessWidget {
  const FarmAvatar({
    required this.farmName,
    required this.radius,
    this.photo,
    this.borderWidth = 0,
    super.key,
  });

  final String farmName;
  final double radius;
  final String? photo;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final validPhoto = photo != null && photo!.trim().isNotEmpty;
    return CircleAvatar(
      radius: radius + borderWidth,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF2F6B45),
        backgroundImage: validPhoto ? appImageProvider(photo!) : null,
        child: validPhoto
            ? null
            : Text(
                _initials(farmName),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.62,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
      ),
    );
  }

  static String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'F';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}
