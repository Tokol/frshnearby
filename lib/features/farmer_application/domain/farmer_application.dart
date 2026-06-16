enum FarmerProfileType { individual, farm, cooperative }

class FarmerApplication {
  const FarmerApplication({
    required this.profileType,
    required this.displayName,
    required this.farmName,
    required this.phone,
    required this.email,
    required this.shortDescription,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.profilePhotoPlaceholder,
  });

  final FarmerProfileType profileType;
  final String displayName;
  final String farmName;
  final String phone;
  final String email;
  final String shortDescription;
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String? profilePhotoPlaceholder;
}

class FarmerApplicationDraft {
  const FarmerApplicationDraft({
    this.profileType = FarmerProfileType.individual,
    this.displayName = '',
    this.farmName = '',
    this.phone = '',
    this.email = '',
    this.shortDescription = '',
    this.latitude,
    this.longitude,
    this.city = '',
    this.country = '',
    this.profilePhotoPlaceholder,
  });

  final FarmerProfileType profileType;
  final String displayName;
  final String farmName;
  final String phone;
  final String email;
  final String shortDescription;
  final double? latitude;
  final double? longitude;
  final String city;
  final String country;
  final String? profilePhotoPlaceholder;

  bool get hasConfirmedLocation => latitude != null && longitude != null;

  FarmerApplicationDraft copyWith({
    FarmerProfileType? profileType,
    String? displayName,
    String? farmName,
    String? phone,
    String? email,
    String? shortDescription,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? profilePhotoPlaceholder,
  }) {
    return FarmerApplicationDraft(
      profileType: profileType ?? this.profileType,
      displayName: displayName ?? this.displayName,
      farmName: farmName ?? this.farmName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      shortDescription: shortDescription ?? this.shortDescription,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      profilePhotoPlaceholder:
          profilePhotoPlaceholder ?? this.profilePhotoPlaceholder,
    );
  }

  FarmerApplication toApplication() {
    final latitudeValue = latitude;
    final longitudeValue = longitude;
    if (latitudeValue == null || longitudeValue == null) {
      throw StateError('A confirmed location is required.');
    }

    return FarmerApplication(
      profileType: profileType,
      displayName: displayName.trim(),
      farmName: farmName.trim(),
      phone: phone.trim(),
      email: email.trim(),
      shortDescription: shortDescription.trim(),
      latitude: latitudeValue,
      longitude: longitudeValue,
      city: city.trim(),
      country: country.trim(),
      profilePhotoPlaceholder: profilePhotoPlaceholder,
    );
  }
}
