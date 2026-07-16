import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/auth_repository.dart';
import '../domain/farmer_profile.dart';
import '../domain/user.dart';
import '../../farmer_application/domain/farmer_application.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final controller = AuthController(ref.watch(authRepositoryProvider));
    controller.restoreSession();
    return controller;
  },
);

class AuthState {
  const AuthState({
    this.user,
    this.emailVerification,
    this.errorMessage,
    this.isRestoring = true,
    this.isLoading = false,
  });

  final User? user;
  final EmailVerificationChallenge? emailVerification;
  final String? errorMessage;
  final bool isRestoring;
  final bool isLoading;

  bool get isSignedIn => user != null;
  bool get hasPendingEmailVerification => emailVerification != null;
  bool get canAccessFarmerMode => user?.canAccessFarmerMode ?? false;
  bool get canApplyAsFarmer => user?.canApplyAsFarmer ?? false;

  AuthState copyWith({
    User? user,
    EmailVerificationChallenge? emailVerification,
    bool clearEmailVerification = false,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
    bool? isRestoring,
    bool? isLoading,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      emailVerification:
          clearEmailVerification
              ? null
              : emailVerification ?? this.emailVerification,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isRestoring: isRestoring ?? this.isRestoring,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._authRepository) : super(const AuthState());

  final AuthRepository _authRepository;

  Future<void> restoreSession() async {
    final user = await _authRepository.restoreSession();
    final emailVerification = await _authRepository.restoreEmailVerification();
    state = state.copyWith(
      user: user,
      emailVerification: emailVerification,
      isRestoring: false,
    );
  }

  Future<void> login({required String email, required String password}) async {
    await _runAuthAction(
      () => _authRepository.login(email: email, password: password),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _runAuthAction(
      () => _authRepository.register(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<void> applyAsFarmer(FarmerApplication application) async {
    final user = state.user;
    if (user == null || !state.canApplyAsFarmer) {
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final updatedUser = await _authRepository.applyAsFarmer(
        user: user,
        application: application,
      );
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> updateFarmerProfile(FarmerProfile profile) async {
    final user = state.user;
    if (user == null || user.farmerProfile == null) {
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final updatedUser = await _authRepository.updateFarmerProfile(
        user: user,
        profile: profile,
      );
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    final user = await _authRepository.restoreSession();
    state = state.copyWith(user: user);
  }

  Future<void> verifyEmailCode(String code) async {
    final verification = state.emailVerification;
    if (verification == null) {
      return;
    }
    await _runAuthAction(
      () => _authRepository.verifyEmailCode(
        email: verification.email,
        code: code,
      ),
    );
  }

  Future<void> resendEmailVerificationCode() async {
    final verification = state.emailVerification;
    if (verification == null) {
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedVerification = await _authRepository
          .resendEmailVerificationCode(email: verification.email);
      state = state.copyWith(
        emailVerification: updatedVerification,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: '$error', isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _runAuthAction(Future<AuthResult> Function() action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await action();
      if (result.isSignedIn) {
        state = state.copyWith(
          user: result.user,
          clearEmailVerification: true,
          isLoading: false,
        );
        return;
      }
      state = state.copyWith(
        clearUser: true,
        emailVerification: result.emailVerification,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: '$error', isLoading: false);
    }
  }
}
