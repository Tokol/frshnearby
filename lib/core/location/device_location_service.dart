export 'location_service.dart' show LocationResult, LocationService;
export 'location_service.dart'
    if (dart.library.js_interop) 'location_service_web.dart'
    show MockLocationService;
