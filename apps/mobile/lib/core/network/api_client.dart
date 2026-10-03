import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

/// App-wide Dio client. Screens/repositories take this from the container
/// rather than constructing Dio themselves.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// One environment-aware client per [ApiClient] instance.
class ApiClient {
  ApiClient({AppEnv? env}) : env = env ?? AppConfig.env {
    dio = Dio(
      BaseOptions(
        baseUrl: this.env == AppEnv.mock ? 'mock://local/api/v1' : AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Content-Type': 'application/json'},
      ),
    );
    if (this.env == AppEnv.mock) {
      dio.httpClientAdapter = _MockHttpClientAdapter();
    } else if (this.env == AppEnv.dev) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('[api] $o'),
      ));
    }
  }

  final AppEnv env;
  late final Dio dio;
}

/// Canned responses for `ENV=mock` so the app runs fully offline until the
/// backend (Stage 4) and OpenAPI examples (Stage 5) exist.
class _MockHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    final Object body;
    final int status;
    if (path.endsWith('/health')) {
      body = {'status': 'ok', 'env': 'mock'};
      status = 200;
    } else {
      body = {
        'error': 'not_implemented',
        'message': 'No mock registered for ${options.method} $path',
      };
      status = 501;
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
