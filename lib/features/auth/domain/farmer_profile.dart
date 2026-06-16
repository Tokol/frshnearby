import '../../farmer_application/domain/farmer_application.dart';

enum FarmerVerificationStatus {
  none,
  pendingReview,
  verified,
  rejected,
  suspended,
}

class FarmerProfile {
  const FarmerProfile({
    required this.id,
    required this.farmName,
    required this.status,
    this.profileType,
    this.displayName,
    this.phone,
    this.email,
    this.shortDescription,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.profilePhotoPlaceholder,
    this.coverPhotoPlaceholder,
    this.pickupNote,
    this.pickupAvailable = true,
    this.pickupAtFarm = true,
    this.pickupAddress,
  });

  final String id;
  final String farmName;
  final FarmerVerificationStatus status;
  final FarmerProfileType? profileType;
  final String? displayName;
  final String? phone;
  final String? email;
  final String? shortDescription;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? profilePhotoPlaceholder;
  final String? coverPhotoPlaceholder;
  final String? pickupNote;
  final bool pickupAvailable;
  final bool pickupAtFarm;
  final String? pickupAddress;

  bool get canAccessFarmerMode => status == FarmerVerificationStatus.verified;

  FarmerProfile copyWith({
    String? id,
    String? farmName,
    FarmerVerificationStatus? status,
    FarmerProfileType? profileType,
    String? displayName,
    String? phone,
    String? email,
    String? shortDescription,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? profilePhotoPlaceholder,
    String? coverPhotoPlaceholder,
    String? pickupNote,
    bool? pickupAvailable,
    bool? pickupAtFarm,
    String? pickupAddress,
  }) {
    return FarmerProfile(
      id: id ?? this.id,
      farmName: farmName ?? this.farmName,
      status: status ?? this.status,
      profileType: profileType ?? this.profileType,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      shortDescription: shortDescription ?? this.shortDescription,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      profilePhotoPlaceholder:
          profilePhotoPlaceholder ?? this.profilePhotoPlaceholder,
      coverPhotoPlaceholder:
          coverPhotoPlaceholder ?? this.coverPhotoPlaceholder,
      pickupNote: pickupNote ?? this.pickupNote,
      pickupAvailable: pickupAvailable ?? this.pickupAvailable,
      pickupAtFarm: pickupAtFarm ?? this.pickupAtFarm,
      pickupAddress: pickupAddress ?? this.pickupAddress,
    );
  }
}
