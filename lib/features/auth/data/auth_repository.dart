import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage_service.dart';
import '../domain/customer_profile.dart';
import '../domain/farmer_profile.dart';
import '../domain/user.dart';
import '../../farmer_application/domain/farmer_application.dart';

abstract class AuthRepository {
  Future<User?> restoreSession();

  Future<User> login({required String email, required String password});

  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  Future<User> applyAsFarmer({
    required User user,
    required FarmerApplication application,
  });

  Future<User> updateFarmerProfile({
    required User user,
    required FarmerProfile profile,
  });

  Future<void> signOut();
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    required LocalStorageService localStorageService,
    required ApiClient apiClient,
  }) : _localStorageService = localStorageService,
       _apiClient = apiClient;

  final LocalStorageService _localStorageService;
  final ApiClient _apiClient;
  User? _currentUser;

  // TODO(backend): Replace mock auth/session state with real auth API calls.
  @override
  Future<User?> restoreSession() async {
    final token = _localStorageService.getAuthToken();
    _apiClient.setAuthToken(token);
    if (token == null) {
      _currentUser ??= _mockVerifiedFarmerUser('farmer@example.com');
      return _currentUser;
    }

    _currentUser ??= _mockCustomerUser();
    return _currentUser;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    const token = 'mock-auth-token';
    await _localStorageService.saveAuthToken(token);
    _apiClient.setAuthToken(token);
    _currentUser = email.toLowerCase().contains('farmer')
        ? _mockVerifiedFarmerUser(email)
        : _mockCustomerUser(email: email);
    return _currentUser!;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    const token = 'mock-auth-token';
    await _localStorageService.saveAuthToken(token);
    _apiClient.setAuthToken(token);
    _currentUser = _mockCustomerUser(email: email, name: name);
    return _currentUser!;
  }

  @override
  Future<User> applyAsFarmer({
    required User user,
    required FarmerApplication application,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _currentUser = user.copyWith(
      farmerProfile: FarmerProfile(
        id: 'farmer-pending-1',
        farmName: application.farmName,
        status: FarmerVerificationStatus.pendingReview,
        profileType: application.profileType,
        displayName: application.displayName,
        phone: application.phone,
        email: application.email,
        shortDescription: application.shortDescription,
        latitude: application.latitude,
        longitude: application.longitude,
        city: application.city,
        country: application.country,
        profilePhotoPlaceholder: application.profilePhotoPlaceholder,
      ),
    );
    return _currentUser!;
  }

  @override
  Future<User> updateFarmerProfile({
    required User user,
    required FarmerProfile profile,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _currentUser = user.copyWith(farmerProfile: profile);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await _localStorageService.clearAuthToken();
    _apiClient.setAuthToken(null);
    _currentUser = _mockGuestCustomerUser();
  }

  User _mockGuestCustomerUser() {
    return const User(
      id: 'user-guest-customer',
      email: 'guest@freshfarm.local',
      name: 'Guest customer',
      customerProfile: CustomerProfile(
        id: 'customer-guest',
        displayName: 'Guest customer',
      ),
    );
  }

  User _mockCustomerUser({
    String email = 'customer@example.com',
    String name = 'Fresh Farm Customer',
  }) {
    return User(
      id: 'user-customer-1',
      email: email,
      name: name,
      customerProfile: CustomerProfile(id: 'customer-1', displayName: name),
    );
  }

  // TODO(backend): Load farmer verification/profile data from the backend.
  User _mockVerifiedFarmerUser(String email) {
    return User(
      id: 'user-farmer-1',
      email: email,
      name: 'Verified Farmer',
      customerProfile: const CustomerProfile(
        id: 'customer-farmer-1',
        displayName: 'Verified Farmer',
      ),
      farmerProfile: const FarmerProfile(
        id: 'farmer-1',
        farmName: 'North Field Farm',
        status: FarmerVerificationStatus.verified,
        profileType: FarmerProfileType.farm,
        displayName: 'North Field Farm',
        phone: '+358 40 123 4567',
        email: 'farmer@example.com',
        shortDescription: 'Verified local producer.',
        latitude: 63.0951,
        longitude: 21.6165,
        city: 'Vaasa',
        country: 'Finland',
        coverPhotoPlaceholder: 'assets/images/home/hero_market.png',
        pickupNote: 'Farm gate pickup after the order is confirmed.',
      ),
    );
  }
}
