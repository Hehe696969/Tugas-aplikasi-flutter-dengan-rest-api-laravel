import 'package:flutter_riverpod/legacy.dart';
import '../core/network/api_exception.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'providers.dart';

class AuthState {
  final UserModel? user;
  final bool loading;
  final String? error;
  final Map<String, String> fieldErrors;

  const AuthState({
    this.user,
    this.loading = false,
    this.error,
    this.fieldErrors = const {},
  });

  AuthState copyWith({
    UserModel? user,
    bool? loading,
    String? error,
    Map<String, String>? fieldErrors,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<UserModel?> restoreSession() async {
    try {
      final user = await _repository.restoreSession();

      state = state.copyWith(
        user: user,
        loading: false,
        clearUser: user == null,
        clearError: true,
      );

      return user;
    } on ApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Gagal memulihkan sesi pengguna.',
      );
      return null;
    }
  }

  Future<bool> getProfile() async {
    try {
      state = state.copyWith(
        loading: true,
        clearError: true,
      );

      final user = await _repository.getProfile();

      state = state.copyWith(
        user: user,
        loading: false,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Gagal mengambil profil pengguna.',
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(
        loading: true,
        clearError: true,
        fieldErrors: {},
      );

      final user = await _repository.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        user: user,
        loading: false,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Terjadi kesalahan saat login.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      state = state.copyWith(
        loading: true,
        clearError: true,
        fieldErrors: {},
      );

      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      state = state.copyWith(
        user: user,
        loading: false,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Terjadi kesalahan saat registrasi.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true);

    try {
      await _repository.logout();
    } finally {
      state = const AuthState();
    }
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
      fieldErrors: {},
    );
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
