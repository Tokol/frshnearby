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
  const AuthState({this.user, this.isRestoring = true, this.isLoading = false});

  final User? user;
  final bool isRestoring;
  final bool isLoading;

  bool get isSignedIn => user != null;
  bool get canAccessFarmerMode => user?.canAccessFarmerMode ?? false;
  bool get canApplyAsFarmer => user?.canApplyAsFarmer ?? false;

  AuthState copyWith({
    User? user,
    bool clearUser = false,
    bool? isRestoring,
    bool? isLoading,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
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
    state = state.copyWith(user: user, isRestoring: false);
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

  Future<void> _runAuthAction(Future<User> Function() action) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await action();
      state = state.copyWith(user: user, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}
