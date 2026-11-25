import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/mock_adapter.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:uuid/uuid.dart';

final envProvider = Provider<Env>((ref) => Env.fromEnvironment());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(env: ref.watch(envProvider));
});

/// Single HTTP entry point for repositories. In mock mode the transport is
/// replaced by [MockAdapter]; the rest of the app never knows the difference.
class ApiClient {
  ApiClient({
    required Env env,
    Dio? dio,
    this.tokenProvider,
  })  : _env = env,
        _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, dynamic>{
        Headers.contentTypeHeader: Headers.jsonContentType,
      },
    );
    if (env.isMock) {
      _dio.httpClientAdapter = MockAdapter(MockDb.instance);
    }
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenProvider?.call();
          options.headers['Authorization'] =
              'Bearer ${token ?? 'mock-token'}';
          if (options.method == 'POST' &&
              options.extra['moneyMove'] == true &&
              options.extra['idempotencyKey'] == null) {
            options.extra['idempotencyKey'] = const Uuid().v4();
          }
          final key = options.extra['idempotencyKey'] as String?;
          if (key != null) options.headers['Idempotency-Key'] = key;
          handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(
      _RetryOnUnauthorized(() => _dio, tokenProvider),
    );
  }

  final Env _env;
  final Dio _dio;
  final Future<String?> Function()? tokenProvider;

  Env get env => _env;
  Dio get dio => _dio;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _request(() => _dio.get<dynamic>(path, queryParameters: queryParameters));

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? data,
    bool moneyMove = false,
    String? idempotencyKey,
  }) =>
      _request(() => _dio.post<dynamic>(
            path,
            data: data,
            options: Options(
              extra: <String, dynamic>{
                'moneyMove': moneyMove,
                'idempotencyKey': ?idempotencyKey,
              },
            ),
          ));

  Future<Map<String, dynamic>> patchJson(String path, {Object? data}) =>
      _request(() => _dio.patch<dynamic>(path, data: data));

  Future<Map<String, dynamic>> deleteJson(String path) =>
      _request(() => _dio.delete<dynamic>(path));

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() run,
  ) async {
    try {
      final response = await run();
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{'data': data};
    } on DioException catch (error) {
      throw AppFailure.from(error);
    }
  }
}

/// Refreshes the Firebase/ID token once on a 401 and replays the request.
class _RetryOnUnauthorized extends Interceptor {
  _RetryOnUnauthorized(this._dioGetter, this._tokenProvider);

  final Dio Function() _dioGetter;
  final Future<String?> Function()? _tokenProvider;

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final options = error.requestOptions;
    final isUnauthorized = error.response?.statusCode == 401;
    final alreadyRetried = options.extra['authRetried'] == true;

    if (!isUnauthorized || alreadyRetried || _tokenProvider == null) {
      handler.next(error);
      return;
    }

    try {
      final token = await _tokenProvider();
      if (token == null) {
        handler.next(error);
        return;
      }
      final retryOptions = options
        ..extra['authRetried'] = true
        ..headers['Authorization'] = 'Bearer $token';
      final response = await _dioGetter().fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
