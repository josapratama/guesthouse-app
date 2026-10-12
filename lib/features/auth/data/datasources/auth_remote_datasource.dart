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

  AuthRemoteDataSource(this._apiClient)
      : _storage = const FlutterSecureStorage();

  /// Login menggunakan email + password.
  /// PostgREST tidak punya endpoint auth bawaan, kita buat RPC di PostgreSQL.
  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/rpc/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;

      // Decode JWT untuk ambil user info
      final jwt = JWT.decode(token);
      final payload = jwt.payload as Map<String, dynamic>;

      final user = UserModel(
        id: payload['sub'] as String,
        name: payload['name'] as String,
        email: payload['email'] as String,
        role: UserModel.fromJson({'role': payload['role']}).role,
        isActive: true,
      );

      // Simpan token
      await _storage.write(key: AppConstants.tokenKey, value: token);

      return (user: user, token: token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AppException('Email atau password salah', statusCode: 401);
      }
      throw AppException(
        e.message ?? 'Terjadi kesalahan jaringan',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  Future<String?> getSavedToken() async {
    return _storage.read(key: AppConstants.tokenKey);
  }
}
