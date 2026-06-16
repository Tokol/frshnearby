import 'package:flutter_test/flutter_test.dart';
import 'package:freshfarm/core/network/api_client.dart';
import 'package:freshfarm/core/storage/local_storage_service.dart';
import 'package:freshfarm/features/auth/data/auth_repository.dart';
import 'package:freshfarm/features/auth/domain/farmer_profile.dart';
import 'package:freshfarm/features/farmer_application/domain/farmer_application.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('submitted farmer application becomes pending review', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.init();
    final repository = MockAuthRepository(
      localStorageService: storage,
      apiClient: ApiClient(),
    );
    final user = await repository.register(
      name: 'Applicant',
      email: 'applicant@example.com',
      password: 'password',
    );

    final updatedUser = await repository.applyAsFarmer(
      user: user,
      application: const FarmerApplication(
        profileType: FarmerProfileType.farm,
        displayName: 'Applicant Farm',
        farmName: 'Applicant Farm',
        phone: '+358 40 000 0000',
        email: 'applicant@example.com',
        shortDescription: 'Small local farm.',
        latitude: 60.1699,
        longitude: 24.9384,
        city: 'Helsinki',
        country: 'Finland',
      ),
    );

    expect(
      updatedUser.farmerProfile?.status,
      FarmerVerificationStatus.pendingReview,
    );
    expect(updatedUser.canAccessFarmerMode, isFalse);
    expect(updatedUser.farmerProfile?.latitude, 60.1699);
    expect(updatedUser.farmerProfile?.longitude, 24.9384);
  });
}
