import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage_service.dart';
import '../domain/customer_profile.dart';
import '../domain/farmer_profile.dart';
import '../domain/user.dart';
import '../../farmer_application/domain/farmer_application.dart';

abstract class AuthRepository {
  Future<User?> restoreSession();

  Future<AuthResult> login({required String email, required String password});

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  });

  Future<EmailVerificationChallenge?> restoreEmailVerification();

  Future<AuthResult> verifyEmailCode({
    required String email,
    required String code,
  });

  Future<EmailVerificationChallenge> resendEmailVerificationCode({
    required String email,
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

class AuthResult {
  const AuthResult._({this.user, this.emailVerification});

  const AuthResult.signedIn(User user) : this._(user: user);

  const AuthResult.emailVerificationRequired(
    EmailVerificationChallenge emailVerification,
  ) : this._(emailVerification: emailVerification);

  final User? user;
  final EmailVerificationChallenge? emailVerification;

  bool get isSignedIn => user != null;
}

class EmailVerificationChallenge {
  const EmailVerificationChallenge({
    required this.email,
    required this.expiresAt,
    required this.resendAvailableAt,
  });

  final String email;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canResend => !DateTime.now().isBefore(resendAvailableAt);
}

class BackendAuthRepository implements AuthRepository {
  BackendAuthRepository({
    required LocalStorageService localStorageService,
    required ApiClient apiClient,
    Dio? firebaseDio,
  }) : _localStorageService = localStorageService,
       _apiClient = apiClient,
       _firebaseDio = firebaseDio ?? Dio() {
    _apiClient.setRefreshAuthTokenHandler(refreshAuthToken);
  }

  final LocalStorageService _localStorageService;
  final ApiClient _apiClient;
  final Dio _firebaseDio;

  @override
  Future<User?> restoreSession() async {
    var token = _localStorageService.getAuthToken();
    final refreshToken = _localStorageService.getRefreshToken();
    if (token == null && refreshToken != null) {
      token = await _refreshIdToken(refreshToken);
    }
    if (token == null) {
      return null;
    }

    _apiClient.setAuthToken(token);
    try {
      return _sessionUser();
    } catch (_) {
      await signOut();
      return null;
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final auth = await _signInWithPassword(email: email, password: password);
    await _saveAuthTokens(auth);
    final user = await _sessionUser();
    if (!user.emailVerified) {
      final challenge = await _requestEmailSignup(
        email: email,
        password: password,
        displayName: user.name.isEmpty ? email.split('@').first : user.name,
      );
      await _saveVerificationChallenge(challenge);
      return AuthResult.emailVerificationRequired(challenge);
    }
    return AuthResult.signedIn(user);
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final challenge = await _requestEmailSignup(
      email: email,
      password: password,
      displayName: name,
    );
    await _saveVerificationChallenge(challenge);
    return AuthResult.emailVerificationRequired(challenge);
  }

  @override
  Future<EmailVerificationChallenge?> restoreEmailVerification() async {
    final encoded = _localStorageService.getEmailVerificationJson();
    if (encoded == null) {
      return null;
    }
    final data = jsonDecode(encoded) as Map<String, dynamic>;
    return EmailVerificationChallenge(
      email: data['email'] as String,
      expiresAt: DateTime.parse(data['expiresAt'] as String),
      resendAvailableAt: DateTime.parse(data['resendAvailableAt'] as String),
    );
  }

  @override
  Future<AuthResult> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    final data = await _graphql(
      r'''
      mutation VerifyEmailSignup($input: VerifyEmailSignupInput!) {
        verifyEmailSignup(input: $input) {
          customToken
          user {
            id
            email
            displayName
            emailVerified
            roles
          }
        }
      }
      ''',
      variables: {
        'input': {'email': email.trim().toLowerCase(), 'code': code.trim()},
      },
    );
    final result = data['verifyEmailSignup'] as Map<String, dynamic>;
    final auth = await _signInWithCustomToken(result['customToken'] as String);
    await _saveAuthTokens(auth);
    await _localStorageService.clearEmailVerification();
    return AuthResult.signedIn(_userFromJson(result['user']));
  }

  @override
  Future<EmailVerificationChallenge> resendEmailVerificationCode({
    required String email,
  }) async {
    final data = await _graphql(
      r'''
      mutation ResendEmailSignupCode($input: ResendEmailSignupCodeInput!) {
        resendEmailSignupCode(input: $input) {
          email
          expiresAt
          resendAvailableAt
        }
      }
      ''',
      variables: {
        'input': {'email': email.trim().toLowerCase()},
      },
    );
    final challenge = _challengeFromJson(data['resendEmailSignupCode']);
    await _saveVerificationChallenge(challenge);
    return challenge;
  }

  @override
  Future<User> applyAsFarmer({
    required User user,
    required FarmerApplication application,
  }) async {
    return user.copyWith(
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
  }

  @override
  Future<User> updateFarmerProfile({
    required User user,
    required FarmerProfile profile,
  }) async {
    return user.copyWith(farmerProfile: profile);
  }

  @override
  Future<void> signOut() async {
    await _localStorageService.clearAuthToken();
    await _localStorageService.clearRefreshToken();
    _apiClient.setAuthToken(null);
  }

  Future<String?> refreshAuthToken() async {
    final refreshToken = _localStorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await signOut();
      return null;
    }
    try {
      return await _refreshIdToken(refreshToken);
    } catch (_) {
      await signOut();
      return null;
    }
  }

  Future<EmailVerificationChallenge> _requestEmailSignup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final data = await _graphql(
      r'''
      mutation RequestEmailSignup($input: EmailSignupInput!) {
        requestEmailSignup(input: $input) {
          email
          expiresAt
          resendAvailableAt
        }
      }
      ''',
      variables: {
        'input': {
          'email': email.trim().toLowerCase(),
          'password': password,
          'displayName': displayName.trim(),
        },
      },
    );
    return _challengeFromJson(data['requestEmailSignup']);
  }

  Future<User> _sessionUser() async {
    final data = await _graphql(r'''
      query Session {
        session {
          user {
            id
            email
            displayName
            emailVerified
            roles
          }
        }
      }
      ''');
    final session = data['session'] as Map<String, dynamic>;
    return _userFromJson(session['user']);
  }

  Future<Map<String, dynamic>> _graphql(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final response = await _apiClient.postGraphQL<Map<String, dynamic>>(
      query,
      variables: variables,
    );
    final body = response.data;
    if (body == null) {
      throw StateError('The server returned an empty response.');
    }
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first as Map<String, dynamic>;
      throw StateError(first['message'] as String? ?? 'Request failed.');
    }
    return body['data'] as Map<String, dynamic>;
  }

  Future<_FirebaseAuthTokens> _signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _firebaseDio.post<Map<String, dynamic>>(
      _firebaseUrl('accounts:signInWithPassword'),
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'returnSecureToken': true,
      },
    );
    return _FirebaseAuthTokens.fromJson(response.data!);
  }

  Future<_FirebaseAuthTokens> _signInWithCustomToken(String customToken) async {
    final response = await _firebaseDio.post<Map<String, dynamic>>(
      _firebaseUrl('accounts:signInWithCustomToken'),
      data: {'token': customToken, 'returnSecureToken': true},
    );
    return _FirebaseAuthTokens.fromJson(response.data!);
  }

  Future<String?> _refreshIdToken(String refreshToken) async {
    final response = await _firebaseDio.post<Map<String, dynamic>>(
      _firebaseUrl('token', secureToken: true),
      options: Options(contentType: Headers.formUrlEncodedContentType),
      data: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
    );
    final data = response.data;
    if (data == null) {
      return null;
    }
    final idToken = data['id_token'] as String?;
    final nextRefreshToken = data['refresh_token'] as String?;
    if (idToken != null) {
      await _localStorageService.saveAuthToken(idToken);
      _apiClient.setAuthToken(idToken);
    }
    if (nextRefreshToken != null) {
      await _localStorageService.saveRefreshToken(nextRefreshToken);
    }
    return idToken;
  }

  Future<void> _saveAuthTokens(_FirebaseAuthTokens auth) async {
    await _localStorageService.saveAuthToken(auth.idToken);
    await _localStorageService.saveRefreshToken(auth.refreshToken);
    _apiClient.setAuthToken(auth.idToken);
  }

  Future<void> _saveVerificationChallenge(
    EmailVerificationChallenge challenge,
  ) async {
    await _localStorageService.saveEmailVerificationJson(
      jsonEncode({
        'email': challenge.email,
        'expiresAt': challenge.expiresAt.toIso8601String(),
        'resendAvailableAt': challenge.resendAvailableAt.toIso8601String(),
      }),
    );
  }

  EmailVerificationChallenge _challengeFromJson(Object? json) {
    final data = json as Map<String, dynamic>;
    return EmailVerificationChallenge(
      email: data['email'] as String,
      expiresAt: DateTime.parse(data['expiresAt'] as String),
      resendAvailableAt: DateTime.parse(data['resendAvailableAt'] as String),
    );
  }

  User _userFromJson(Object? json) {
    final data = json as Map<String, dynamic>;
    final email = data['email'] as String? ?? '';
    final name = data['displayName'] as String? ?? email.split('@').first;
    return User(
      id: data['id'] as String,
      email: email,
      name: name,
      emailVerified: data['emailVerified'] as bool? ?? false,
      customerProfile: CustomerProfile(
        id: data['id'] as String,
        displayName: name,
      ),
    );
  }

  String _firebaseUrl(String action, {bool secureToken = false}) {
    final apiKey = AppConfig.firebaseApiKey;
    if (apiKey.isEmpty) {
      throw StateError('FIREBASE_API_KEY must be provided with --dart-define.');
    }
    final host =
        secureToken
            ? 'https://securetoken.googleapis.com/v1'
            : 'https://identitytoolkit.googleapis.com/v1';
    return '$host/$action?key=$apiKey';
  }
}

class _FirebaseAuthTokens {
  const _FirebaseAuthTokens({
    required this.idToken,
    required this.refreshToken,
  });

  final String idToken;
  final String refreshToken;

  factory _FirebaseAuthTokens.fromJson(Map<String, dynamic> json) {
    return _FirebaseAuthTokens(
      idToken: json['idToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
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

  static const _verificationCode = '123456';
  static const _verificationWindow = Duration(minutes: 10);
  static const _resendCooldown = Duration(seconds: 45);

  // TODO(backend): Replace mock auth/session state with real auth API calls.
  @override
  Future<User?> restoreSession() async {
    final token = _localStorageService.getAuthToken();
    _apiClient.setAuthToken(token);
    if (token == null) {
      final pendingVerification = await restoreEmailVerification();
      if (pendingVerification != null) {
        return null;
      }
      _currentUser ??= _mockVerifiedFarmerUser('farmer@example.com');
      return _currentUser;
    }

    _currentUser ??= _mockCustomerUser();
    return _currentUser;
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final pendingVerification = await restoreEmailVerification();
    if (pendingVerification != null &&
        pendingVerification.email == email.trim().toLowerCase()) {
      return AuthResult.emailVerificationRequired(pendingVerification);
    }

    const token = 'mock-auth-token';
    await _localStorageService.saveAuthToken(token);
    _apiClient.setAuthToken(token);
    _currentUser =
        email.toLowerCase().contains('farmer')
            ? _mockVerifiedFarmerUser(email)
            : _mockCustomerUser(email: email);
    return AuthResult.signedIn(_currentUser!);
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final verification = await _createVerification(
      email: email.trim().toLowerCase(),
      name: name.trim(),
    );
    return AuthResult.emailVerificationRequired(verification);
  }

  @override
  Future<EmailVerificationChallenge?> restoreEmailVerification() async {
    final encoded = _localStorageService.getEmailVerificationJson();
    if (encoded == null) {
      return null;
    }

    final data = jsonDecode(encoded) as Map<String, dynamic>;
    final challenge = EmailVerificationChallenge(
      email: data['email'] as String,
      expiresAt: DateTime.parse(data['expiresAt'] as String),
      resendAvailableAt: DateTime.parse(data['resendAvailableAt'] as String),
    );
    if (challenge.isExpired) {
      return challenge;
    }
    return challenge;
  }

  @override
  Future<AuthResult> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final pendingVerification = await restoreEmailVerification();
    if (pendingVerification == null ||
        pendingVerification.email != email.trim().toLowerCase()) {
      throw StateError('No email verification is pending.');
    }
    if (pendingVerification.isExpired) {
      throw StateError('The verification code has expired.');
    }
    if (code.trim() != _verificationCode) {
      throw StateError('The verification code is not correct.');
    }

    const token = 'mock-auth-token';
    await _localStorageService.saveAuthToken(token);
    await _localStorageService.clearEmailVerification();
    _apiClient.setAuthToken(token);
    _currentUser = _mockCustomerUser(
      email: pendingVerification.email,
      name: _pendingName,
    );
    return AuthResult.signedIn(_currentUser!);
  }

  @override
  Future<EmailVerificationChallenge> resendEmailVerificationCode({
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _createVerification(
      email: email.trim().toLowerCase(),
      name: _pendingName,
    );
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

  Future<EmailVerificationChallenge> _createVerification({
    required String email,
    required String name,
  }) async {
    final now = DateTime.now();
    final challenge = EmailVerificationChallenge(
      email: email,
      expiresAt: now.add(_verificationWindow),
      resendAvailableAt: now.add(_resendCooldown),
    );
    await _localStorageService.saveEmailVerificationJson(
      jsonEncode({
        'email': challenge.email,
        'name': name,
        'expiresAt': challenge.expiresAt.toIso8601String(),
        'resendAvailableAt': challenge.resendAvailableAt.toIso8601String(),
      }),
    );
    return challenge;
  }

  String get _pendingName {
    final encoded = _localStorageService.getEmailVerificationJson();
    if (encoded == null) {
      return 'Fresh Farm Customer';
    }
    final data = jsonDecode(encoded) as Map<String, dynamic>;
    final name = data['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      return 'Fresh Farm Customer';
    }
    return name;
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
