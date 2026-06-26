import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../storage/local_storage_service.dart';
import 'location_service.dart';
import 'marketplace_location.dart';

final marketplaceLocationControllerProvider =
    StateNotifierProvider<
      MarketplaceLocationController,
      MarketplaceLocationState
    >((ref) {
      final controller = MarketplaceLocationController(
        localStorageService: ref.watch(localStorageServiceProvider),
        locationService: ref.watch(locationServiceProvider),
      );
      controller.initialize();
      return controller;
    });

class MarketplaceLocationState {
  const MarketplaceLocationState({
    this.isInitializing = true,
    this.isLoading = false,
    this.detectedLocation,
    this.selectedLocation,
    this.hasAskedForConfirmation = false,
  });

  final bool isInitializing;
  final bool isLoading;
  final MarketplaceLocation? detectedLocation;
  final MarketplaceLocation? selectedLocation;
  final bool hasAskedForConfirmation;

  MarketplaceLocation get displayLocation {
    return selectedLocation ??
        detectedLocation ??
        const MarketplaceLocation(
          latitude: 63.0951,
          longitude: 21.6165,
          city: 'Vaasa',
          region: 'Ostrobothnia',
          country: 'Finland',
        );
  }

  bool get shouldConfirmDetectedLocation {
    return !isInitializing &&
        selectedLocation == null &&
        detectedLocation != null &&
        !hasAskedForConfirmation;
  }

  MarketplaceLocationState copyWith({
    bool? isInitializing,
    bool? isLoading,
    MarketplaceLocation? detectedLocation,
    MarketplaceLocation? selectedLocation,
    bool? hasAskedForConfirmation,
  }) {
    return MarketplaceLocationState(
      isInitializing: isInitializing ?? this.isInitializing,
      isLoading: isLoading ?? this.isLoading,
      detectedLocation: detectedLocation ?? this.detectedLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      hasAskedForConfirmation:
          hasAskedForConfirmation ?? this.hasAskedForConfirmation,
    );
  }
}

class MarketplaceLocationController
    extends StateNotifier<MarketplaceLocationState> {
  MarketplaceLocationController({
    required LocalStorageService localStorageService,
    required LocationService locationService,
  }) : _localStorageService = localStorageService,
       _locationService = locationService,
       super(const MarketplaceLocationState());

  final LocalStorageService _localStorageService;
  final LocationService _locationService;

  static const suggestions = [
    MarketplaceLocation(
      latitude: 63.0951,
      longitude: 21.6165,
      city: 'Vaasa',
      region: 'Ostrobothnia',
      country: 'Finland',
    ),
    MarketplaceLocation(
      latitude: 63.1147,
      longitude: 21.6822,
      city: 'Mustasaari',
      region: 'Ostrobothnia',
      country: 'Finland',
    ),
    MarketplaceLocation(
      latitude: 62.7903,
      longitude: 22.8403,
      city: 'Seinäjoki',
      region: 'South Ostrobothnia',
      country: 'Finland',
    ),
    MarketplaceLocation(
      latitude: 63.6749,
      longitude: 22.7026,
      city: 'Kokkola',
      region: 'Central Ostrobothnia',
      country: 'Finland',
    ),
  ];

  Future<void> initialize() async {
    final savedLocation = MarketplaceLocation.tryDecode(
      _localStorageService.getSelectedLocationJson(),
    );

    if (savedLocation != null) {
      state = state.copyWith(
        selectedLocation: savedLocation,
        isInitializing: false,
        hasAskedForConfirmation: true,
      );
      unawaited(_refreshDetectedLocation());
      return;
    }

    await _refreshDetectedLocation(markInitialized: true);
  }

  Future<void> _refreshDetectedLocation({bool markInitialized = false}) async {
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        if (markInitialized) {
          state = state.copyWith(isInitializing: false);
        }
        return;
      }

      final result = await _locationService.getCurrentLocation();
      state = state.copyWith(
        detectedLocation: MarketplaceLocation.fromLocationResult(result),
        selectedLocation: MarketplaceLocation.fromLocationResult(result),
        isInitializing: markInitialized ? false : state.isInitializing,
      );
    } catch (_) {
      if (markInitialized) {
        state = state.copyWith(isInitializing: false);
      }
    }
  }

  Future<void> confirmDetectedLocation() async {
    final location = state.detectedLocation ?? state.displayLocation;
    await selectLocation(location);
  }

  Future<void> selectLocation(MarketplaceLocation location) async {
    state = state.copyWith(isLoading: true);
    await _localStorageService.saveSelectedLocationJson(location.encode());
    state = state.copyWith(
      isLoading: false,
      selectedLocation: location,
      hasAskedForConfirmation: true,
    );
  }

  void markConfirmationAsked() {
    state = state.copyWith(hasAskedForConfirmation: true);
  }

  List<MarketplaceLocation> searchSuggestions(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return suggestions;
    }

    return suggestions.where((location) {
      final searchable =
          '${location.city} ${location.region} ${location.country}'
              .toLowerCase();
      return searchable.contains(normalizedQuery);
    }).toList();
  }
}
