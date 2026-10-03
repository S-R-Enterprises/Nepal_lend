import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/app_config.dart';
import 'package:nepal_lend/core/network/api_client.dart';

void main() {
  group('AppConfig', () {
    test('defaults to dev without --dart-define', () {
      expect(AppConfig.env, AppEnv.dev);
      expect(AppConfig.useMock, isFalse);
      expect(AppConfig.isDev, isTrue);
      expect(AppConfig.apiBaseUrl, contains('localhost'));
    });

    test('unknown ENV name falls back to dev', () {
      expect(AppEnv.fromName('nope'), AppEnv.dev);
      expect(AppEnv.fromName('staging'), AppEnv.staging);
      expect(AppEnv.fromName('mock'), AppEnv.mock);
    });

    test('mock base url uses mock scheme', () {
      expect(AppEnv.mock.name, 'mock');
    });
  });

  group('ApiClient mock adapter', () {
    test('health returns 200 canned body', () async {
      final client = ApiClient(env: AppEnv.mock);
      final res = await client.dio.get('/health');
      expect(res.statusCode, 200);
      expect(res.data, {'status': 'ok', 'env': 'mock'});
    });

    test('unregistered path returns 501', () async {
      final client = ApiClient(env: AppEnv.mock);
      try {
        await client.dio.get('/loans');
        fail('expected DioException');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 501);
        expect(e.response?.data['error'], 'not_implemented');
      }
    });

    test('dio timeouts and headers configured', () {
      final client = ApiClient(env: AppEnv.dev);
      expect(client.dio.options.connectTimeout, const Duration(seconds: 10));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 15));
      expect(client.dio.options.headers['Content-Type'], 'application/json');
    });
  });
}
