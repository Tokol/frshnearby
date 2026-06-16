import '../../auth/domain/farmer_profile.dart';

class FarmerPublicProfile {
  const FarmerPublicProfile({
    required this.id,
    required this.displayName,
    required this.farmName,
    required this.city,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.status,
    required this.shortDescription,
    this.profilePhotoPlaceholder,
    this.coverPhotoPlaceholder,
    this.pickupNote,
    this.pickupAvailable = true,
    this.pickupAtFarm = true,
    this.pickupAddress,
  });

  final String id;
  final String displayName;
  final String farmName;
  final String city;
  final String country;
  final double rating;
  final int reviewCount;
  final FarmerVerificationStatus status;
  final String shortDescription;
  final String? profilePhotoPlaceholder;
  final String? coverPhotoPlaceholder;
  final String? pickupNote;
  final bool pickupAvailable;
  final bool pickupAtFarm;
  final String? pickupAddress;

  bool get isVerified => status == FarmerVerificationStatus.verified;

  String get approximateLocation => '$city, $country';

  FarmerPublicProfile copyWith({
    String? id,
    String? displayName,
    String? farmName,
    String? city,
    String? country,
    double? rating,
    int? reviewCount,
    FarmerVerificationStatus? status,
    String? shortDescription,
    String? profilePhotoPlaceholder,
    String? coverPhotoPlaceholder,
    String? pickupNote,
    bool? pickupAvailable,
    bool? pickupAtFarm,
    String? pickupAddress,
  }) {
    return FarmerPublicProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      farmName: farmName ?? this.farmName,
      city: city ?? this.city,
      country: country ?? this.country,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      status: status ?? this.status,
      shortDescription: shortDescription ?? this.shortDescription,
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
