import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/farmer_application.dart';

final farmerApplicationControllerProvider =
    StateNotifierProvider<FarmerApplicationController, FarmerApplicationState>((
      ref,
    ) {
      return FarmerApplicationController(ref);
    });

class FarmerApplicationState {
  const FarmerApplicationState({
    this.draft = const FarmerApplicationDraft(),
    this.isLoadingLocation = false,
    this.locationPermissionDenied = false,
  });

  final FarmerApplicationDraft draft;
  final bool isLoadingLocation;
  final bool locationPermissionDenied;

  bool get canReview {
    return draft.displayName.trim().isNotEmpty &&
        draft.farmName.trim().isNotEmpty &&
        draft.phone.trim().isNotEmpty &&
        draft.email.trim().isNotEmpty &&
        draft.shortDescription.trim().isNotEmpty &&
        draft.city.trim().isNotEmpty &&
        draft.country.trim().isNotEmpty &&
        draft.hasConfirmedLocation;
  }

  FarmerApplicationState copyWith({
    FarmerApplicationDraft? draft,
    bool? isLoadingLocation,
    bool? locationPermissionDenied,
  }) {
    return FarmerApplicationState(
      draft: draft ?? this.draft,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      locationPermissionDenied:
          locationPermissionDenied ?? this.locationPermissionDenied,
    );
  }
}

class FarmerApplicationController
    extends StateNotifier<FarmerApplicationState> {
  FarmerApplicationController(this._ref)
    : super(const FarmerApplicationState());

  final Ref _ref;

  void updateProfile({
    required FarmerProfileType profileType,
    required String displayName,
    required String farmName,
    required String phone,
    required String email,
    required String shortDescription,
    String? profilePhotoPlaceholder,
  }) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        profileType: profileType,
        displayName: displayName,
        farmName: farmName,
        phone: phone,
        email: email,
        shortDescription: shortDescription,
        profilePhotoPlaceholder: profilePhotoPlaceholder,
      ),
    );
  }

  Future<void> requestAndUseCurrentLocation() async {
    state = state.copyWith(
      isLoadingLocation: true,
      locationPermissionDenied: false,
    );

    final locationService = _ref.read(locationServiceProvider);
    final hasPermission = await locationService.requestLocationPermission();
    if (!hasPermission) {
      state = state.copyWith(
        isLoadingLocation: false,
        locationPermissionDenied: true,
      );
      return;
    }

    final location = await locationService.getCurrentLocation();
    confirmLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      city: location.city,
      country: location.country,
    );
    state = state.copyWith(isLoadingLocation: false);
  }

  void confirmLocation({
    required double latitude,
    required double longitude,
    required String city,
    required String country,
  }) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        latitude: latitude,
        longitude: longitude,
        city: city,
        country: country,
      ),
      locationPermissionDenied: false,
    );
  }

  Future<void> submit() async {
    await _ref
        .read(authControllerProvider.notifier)
        .applyAsFarmer(state.draft.toApplication());
  }
}
