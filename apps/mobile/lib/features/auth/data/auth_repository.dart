import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/token_store.dart';
import 'auth_models.dart';

/// Backend-communicable auth failure with the server's message.
class AuthException implements Exception {
  AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider), TokenStore()),
);

class AuthRepository {
  AuthRepository(this._api, this.tokens);

  final ApiClient _api;
  final TokenStore tokens;

  Future<OtpChallenge> requestOtp(String phone) async {
    final data = await _post('/auth/otp/request', {'phone': phone});
    return OtpChallenge.fromJson(data);
  }

  Future<AuthSession> verifyOtp(String requestId, String code) async {
    final data = await _post('/auth/otp/verify', {
      'requestId': requestId,
      'code': code,
    });
    final session = AuthSession.fromJson(data);
    await tokens.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    return session;
  }

  Future<ApiUser> me() async {
    try {
      final res = await _api.dio.get('/me');
      return ApiUser.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<ApiUser> updateProfile({String? name, String? role}) async {
    try {
      final res = await _api.dio.patch('/me', data: {
        'name': ?name,
        'role': ?role,
      });
      return ApiUser.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } on DioException catch (e) {
      throw _map(e);
    } finally {
      await tokens.clear();
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _api.dio.post(path, data: body);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  AuthException _map(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return AuthException(
        data['message'] as String,
        statusCode: e.response?.statusCode,
      );
    }
    if (e.response == null) {
      return AuthException('Cannot reach the server. Check your connection.');
    }
    return AuthException('Something went wrong.', statusCode: e.response?.statusCode);
  }
}
