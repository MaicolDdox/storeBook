import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../shared/models/user_model.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isBootstrapping = true,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserModel? user;
  final bool isBootstrapping;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    UserModel? user,
    bool? isBootstrapping,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState()) {
    bootstrap();
  }

  final Ref _ref;

  Future<void> bootstrap() async {
    state = state.copyWith(isBootstrapping: true, clearError: true);
    final repository = _ref.read(authRepositoryProvider);
    final token = await repository.readToken();

    if (token == null || token.isEmpty) {
      state = state.copyWith(isBootstrapping: false, clearUser: true);
      return;
    }

    try {
      final user = await repository.me();
      state = state.copyWith(
        user: user,
        isBootstrapping: false,
        clearError: true,
      );
    } catch (_) {
      await repository.logout();
      state = state.copyWith(isBootstrapping: false, clearUser: true);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _ref
          .read(authRepositoryProvider)
          .login(
            email: email,
            password: password,
            deviceName: 'flutter-mobile',
          );
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return true;
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _ref
          .read(authRepositoryProvider)
          .register(
            name: name,
            email: email,
            password: password,
            deviceName: 'flutter-mobile',
          );
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return true;
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _ref.read(authRepositoryProvider).logout();
    state = state.copyWith(isLoading: false, clearUser: true, clearError: true);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref);
  },
);
