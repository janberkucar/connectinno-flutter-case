import 'package:connectinno_notes/core/failures/app_failure.dart';
import 'package:connectinno_notes/core/network/api_constants.dart';
import 'package:connectinno_notes/core/storage/secure_storage_keys.dart';
import 'package:connectinno_notes/features/auth/auth_state.dart';
import 'package:connectinno_notes/features/auth/models/app_user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Staged auth: same interface for local session + remote JWT. Integrates with FastAPI `/auth/*`.
class AuthRepository {
  AuthRepository({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _storage = secureStorage;

  final Dio _dio;
  final FlutterSecureStorage _storage;

  /// Restore session from secure storage (no network). Used on cold start.
  Future<AuthAuthenticated?> readPersistedSession() async {
    final token = await _storage.read(key: SecureStorageKeys.authToken);
    final email = await _storage.read(key: SecureStorageKeys.userEmail);
    if (token == null || token.isEmpty || email == null || email.isEmpty) {
      return null;
    }
    return AuthAuthenticated(AppUser(email: email));
  }

  Future<AuthAuthenticated> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.authSignUp,
        data: <String, String>{
          'email': email,
          'password': password,
        },
      );
      return _fromAuthResponse(res.data!, email);
    } on DioException catch (e) {
      throw _asFailure(e);
    }
  }

  Future<AuthAuthenticated> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.authLogin,
        data: <String, String>{
          'email': email,
          'password': password,
        },
      );
      return _fromAuthResponse(res.data!, email);
    } on DioException catch (e) {
      throw _asFailure(e);
    }
  }

  Future<void> signOut() async {
    await _storage.delete(key: SecureStorageKeys.authToken);
    await _storage.delete(key: SecureStorageKeys.userEmail);
  }

  Future<AuthAuthenticated> _fromAuthResponse(Map<String, dynamic> data, String email) async {
    final access = data['access_token'] as String?;
    if (access == null || access.isEmpty) {
      throw const AppFailure('Invalid auth response from server');
    }
    final userId = data['user_id'] as String?;
    await _storage.write(key: SecureStorageKeys.authToken, value: access);
    await _storage.write(key: SecureStorageKeys.userEmail, value: email);
    return AuthAuthenticated(
      AppUser(
        email: email,
        id: userId,
      ),
    );
  }

  AppFailure _asFailure(DioException e) {
    if (e.error is AppFailure) {
      return e.error! as AppFailure;
    }
    return AppFailure(
      e.message ?? 'Request failed',
      code: e.response?.statusCode?.toString(),
    );
  }
}
