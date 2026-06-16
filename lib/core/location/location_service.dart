class LocationResult {
  const LocationResult({
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
}

abstract class LocationService {
  Future<bool> requestLocationPermission();

  Future<LocationResult> getCurrentLocation();
}

class MockLocationService implements LocationService {
  const MockLocationService();

  @override
  Future<bool> requestLocationPermission() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return true;
  }

  @override
  Future<LocationResult> getCurrentLocation() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const LocationResult(
      latitude: 63.0951,
      longitude: 21.6165,
      city: 'Vaasa',
      region: 'Ostrobothnia',
      country: 'Finland',
    );
  }
}
