import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'location_service.dart';

class MockLocationService implements LocationService {
  const MockLocationService();

  @override
  Future<bool> requestLocationPermission() async {
    return true;
  }

  @override
  Future<LocationResult> getCurrentLocation() async {
    final geolocation = web.window.navigator.geolocation;
    final completer = Completer<LocationResult>();
    geolocation.getCurrentPosition(
      ((web.GeolocationPosition position) {
        if (completer.isCompleted) return;
        final coords = position.coords;
        completer.complete(
          LocationResult(
            latitude: coords.latitude,
            longitude: coords.longitude,
            city: 'Current location',
            region: 'Nearby',
            country: 'GPS',
          ),
        );
      }).toJS,
      ((web.GeolocationPositionError error) {
        if (!completer.isCompleted) {
          completer.complete(_fallbackLocation);
        }
      }).toJS,
      web.PositionOptions(
        enableHighAccuracy: true,
        timeout: 8000,
        maximumAge: 60000,
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 9),
      onTimeout: () => _fallbackLocation,
    );
  }

  static const _fallbackLocation = LocationResult(
    latitude: 63.0951,
    longitude: 21.6165,
    city: 'Vaasa',
    region: 'Ostrobothnia',
    country: 'Finland',
  );
}
