import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  // Harus sama dengan PGRST_JWT_SECRET di docker-compose
  static const _jwtSecret = 'super-secret-jwt-token-guesthouse-2026';

  AuthRemoteDataSource(this._apiClient)
    : _storage = const FlutterSecureStorage();

  /// Login: verifikasi di PostgreSQL, buat JWT di Flutter
  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/rpc/login',
        data: {'email': email, 'password': password},
      );

      // Response adalah user data langsung (JSON object)
      final data = response.data as Map<String, dynamic>;

      final user = UserModel.fromJson(data);

      // Buat JWT lokal — role harus 'anon' agar PostgREST izinkan akses
      // Role aplikasi asli (admin/receptionist) disimpan di claim 'app_role'
      final jwt = JWT({
        'sub': user.id,
        'email': user.email,
        'name': user.name,
        'role': 'anon', // PostgREST role
        'app_role': user.role.name, // Role aplikasi kita
      }, issuer: 'guesthouse-app');
      final token = jwt.sign(
        SecretKey(_jwtSecret),
        expiresIn: const Duration(hours: 8),
      );

      // Simpan token
      await _storage.write(key: AppConstants.tokenKey, value: token);

      return (user: user, token: token);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 400 || statusCode == 404) {
        // PostgREST raise exception → 400/404
        final msg = _extractErrorMessage(e.response?.data);
        throw AppException(msg, statusCode: statusCode);
      }
      if (statusCode == 401) {
        throw const AppException('Email atau password salah', statusCode: 401);
      }
      throw AppException(
        e.message ?? 'Terjadi kesalahan jaringan',
        statusCode: statusCode,
      );
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  Future<UserModel?> getSavedUser() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token == null) return null;

    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      return UserModel(
        id: payload['sub'] as String,
        name: payload['name'] as String,
        email: payload['email'] as String,
        role: UserModel.fromJson({
          'role': payload['app_role'] ?? payload['role'],
        }).role,
        isActive: true,
      );
    } catch (_) {
      // Token expired atau invalid — hapus
      await _storage.delete(key: AppConstants.tokenKey);
      return null;
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Email atau password salah';
    if (data is Map) {
      return (data['message'] as String?)?.replaceAll('ERROR:  ', '') ??
          'Email atau password salah';
    }
    return 'Email atau password salah';
  }
}
