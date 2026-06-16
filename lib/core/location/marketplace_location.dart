import 'dart:convert';

import 'location_service.dart';

class MarketplaceLocation {
  const MarketplaceLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.region,
    required this.country,
  });

  final double latitude;
  final double longitude;
  final String city;
  final String region;
  final String country;

  String get displayName {
    if (region.isEmpty) {
      return '$city, $country';
    }
    return '$city, $region';
  }

  Map<String, Object> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'region': region,
      'country': country,
    };
  }

  String encode() => jsonEncode(toJson());

  static MarketplaceLocation fromLocationResult(LocationResult result) {
    return MarketplaceLocation(
      latitude: result.latitude,
      longitude: result.longitude,
      city: result.city,
      region: result.region,
      country: result.country,
    );
  }

  static MarketplaceLocation? tryDecode(String? source) {
    if (source == null) {
      return null;
    }

    try {
      final json = jsonDecode(source) as Map<String, dynamic>;
      return MarketplaceLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        city: json['city'] as String,
        region: json['region'] as String? ?? '',
        country: json['country'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}
