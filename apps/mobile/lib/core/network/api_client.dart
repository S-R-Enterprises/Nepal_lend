import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'token_store.dart';

/// App-wide Dio client. Screens/repositories take this from the container
/// rather than constructing Dio themselves.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// One environment-aware client per [ApiClient] instance.
class ApiClient {
  ApiClient({AppEnv? env, TokenStore? tokenStore})
      : env = env ?? AppConfig.env {
    dio = Dio(
      BaseOptions(
        baseUrl: this.env == AppEnv.mock
            ? 'mock://local/api/v1'
            : AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Content-Type': 'application/json'},
      ),
    );
    if (this.env == AppEnv.dev) {
      // Added first so the log runs before the auth header is attached.
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('[api] $o'),
      ));
    }
    final store = tokenStore ?? TokenStore();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await store.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
    if (this.env == AppEnv.mock) {
      dio.httpClientAdapter = _MockHttpClientAdapter();
    }
  }

  final AppEnv env;
  late final Dio dio;
}

/// Canned responses for `ENV=mock` so the app runs fully offline. Shapes
/// follow `packages/api-spec/openapi.yaml` (D10: the spec is the truth).
class _MockHttpClientAdapter implements HttpClientAdapter {
  /// Approved KYC steps for the current app run (stateful like the API).
  final Set<String> _approvedKyc = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    final raw = requestStream == null
        ? null
        : await utf8.decoder.bind(requestStream).join();
    final body = (raw != null && raw.isNotEmpty)
        ? jsonDecode(raw) as Map<String, dynamic>
        : const <String, dynamic>{};

    final Object payload;
    final int status;
    if (path.endsWith('/health')) {
      payload = {'status': 'ok', 'db': 'ok', 'env': 'mock', 'time': _now()};
      status = 200;
    } else if (_requiresAuth(path) && !_hasBearer(options)) {
      payload = {
        'error': 'unauthorized',
        'message': 'Missing or invalid access token',
      };
      status = 401;
    } else if (path.endsWith('/auth/otp/request') &&
        options.method == 'POST') {
      final phone = body['phone'] as String? ?? '9800000000';
      payload = {
        'requestId': 'mock-otp-$phone',
        'phone': '9841***567',
        'maskedPhone': '9841***567',
        'expiresInSeconds': 120,
        'devCode': '123456',
      };
      status = 200;
    } else if (path.endsWith('/auth/otp/verify') && options.method == 'POST') {
      if (body['code'] == '123456') {
        final requestId = body['requestId'] as String? ?? '';
        final phone = requestId.startsWith('mock-otp-')
            ? requestId.replaceFirst('mock-otp-', '')
            : '9841234567';
        payload = {
          'accessToken': 'mock-access-token',
          'refreshToken': 'mock-refresh-token',
          'expiresInSeconds': 3600,
          'isNewUser': true,
          'user': _user(phone: phone),
        };
        status = 200;
      } else {
        payload = {
          'error': 'invalid_otp',
          'message': 'Incorrect or expired code',
        };
        status = 401;
      }
    } else if (path.endsWith('/auth/logout') && options.method == 'POST') {
      payload = '';
      status = 204;
    } else if (path.endsWith('/me') && options.method == 'GET') {
      payload = _user();
      status = 200;
    } else if (path.endsWith('/me') && options.method == 'PATCH') {
      payload = {
        ..._user(),
        if (body['name'] != null) 'name': body['name'],
        if (body['role'] != null) 'role': body['role'],
      };
      status = 200;
    } else if (path.endsWith('/me/kyc') && options.method == 'GET') {
      payload = _kycStatus();
      status = 200;
    } else if (path.contains('/me/kyc/steps/') &&
        path.endsWith('/verify') &&
        options.method == 'POST') {
      final parts = path.split('/');
      final stepId = parts[parts.length - 2];
      if (const ['citizenship', 'selfie', 'details'].contains(stepId)) {
        _approvedKyc.add(stepId);
        payload = _kycStatus();
        status = 200;
      } else {
        payload = {
          'error': 'validation_error',
          'message': 'stepId must be one of: citizenship, selfie, details',
        };
        status = 400;
      }
    } else {
      payload = {
        'error': 'not_implemented',
        'message': 'No mock registered for ${options.method} $path',
      };
      status = 501;
    }
    // 204 must stay empty with no content-type, or Dio's JSON transformer trips.
    final headers = status == 204
        ? <String, List<String>>{}
        : <String, List<String>>{
            Headers.contentTypeHeader: [Headers.jsonContentType],
          };
    return ResponseBody.fromString(
      status == 204 ? '' : jsonEncode(payload),
      status,
      headers: headers,
    );
  }

  bool _requiresAuth(String path) =>
      path.endsWith('/me') ||
      path.contains('/me/kyc') ||
      path.endsWith('/auth/logout');

  Map<String, dynamic> _kycStatus() {
    const steps = [
      ('citizenship', 'Citizenship document'),
      ('selfie', 'Selfie verification'),
      ('details', 'Personal details'),
    ];
    return {
      'state': _approvedKyc.length >= steps.length
          ? 'verified'
          : _approvedKyc.isEmpty
              ? 'unstarted'
              : 'in_review',
      'steps': [
        for (final (id, label) in steps)
          {
            'id': id,
            'label': label,
            'status': _approvedKyc.contains(id) ? 'Approved' : 'Not started',
            'updatedAt': _approvedKyc.contains(id) ? _now() : null,
          },
      ],
    };
  }

  bool _hasBearer(RequestOptions options) {
    final h = options.headers['Authorization'];
    return h is String && h.startsWith('Bearer ');
  }

  Map<String, dynamic> _user({String phone = '9841234567'}) => {
        'id': 'mock-user',
        'phone': phone,
        'name': null,
        'role': 'borrower',
        'email': null,
        'avatarUrl': null,
        'kycState': 'unstarted',
        'createdAt': _now(),
      };

  String _now() => DateTime.now().toUtc().toIso8601String();

  @override
  void close({bool force = false}) {}
}
