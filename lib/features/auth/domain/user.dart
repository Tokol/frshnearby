import 'customer_profile.dart';
import 'farmer_profile.dart';

class User {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.customerProfile,
    this.emailVerified = false,
    this.farmerProfile,
  });

  final String id;
  final String email;
  final String name;
  final CustomerProfile customerProfile;
  final bool emailVerified;
  final FarmerProfile? farmerProfile;

  bool get canAccessFarmerMode => farmerProfile?.canAccessFarmerMode ?? false;

  bool get canApplyAsFarmer =>
      farmerProfile == null ||
      farmerProfile?.status == FarmerVerificationStatus.none;

  User copyWith({
    String? id,
    String? email,
    String? name,
    CustomerProfile? customerProfile,
    bool? emailVerified,
    FarmerProfile? farmerProfile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      customerProfile: customerProfile ?? this.customerProfile,
      emailVerified: emailVerified ?? this.emailVerified,
      farmerProfile: farmerProfile ?? this.farmerProfile,
    );
  }
}
