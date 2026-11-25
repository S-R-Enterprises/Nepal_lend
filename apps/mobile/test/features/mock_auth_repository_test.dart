import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/features/auth/data/mock_auth_repository.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() async {
    await MockDb.instance.clear();
    final api = ApiClient(
      env: const Env(
        environment: AppEnvironment.mock,
        apiBaseUrl: 'https://mock.local/api/v1',
      ),
    );
    repository = MockAuthRepository(api: api);
  });

  test('validates Nepali mobile numbers', () {
    expect(MockAuthRepository.isValidNepaliMobile('9800000000'), isTrue);
    expect(MockAuthRepository.isValidNepaliMobile('9779800000000'), isTrue);
    expect(MockAuthRepository.isValidNepaliMobile('12345'), isFalse);
    expect(
      () => repository.sendCode('123'),
      throwsA(isA<AppFailure>().having((e) => e.code, 'code', 'validation_error')),
    );
  });

  test('returns the demo code hint only in mock mode', () async {
    final result = await repository.sendCode('9800000000');
    expect(result.phone, '+9779800000000');
    expect(result.demoCode, MockAuthRepository.demoCode);
  });

  test('rejects wrong, rate-limited and offline codes', () async {
    await repository.sendCode('9800000000');

    expect(
      () => repository.verifyCode(phone: '9800000000', code: '111111'),
      throwsA(isA<AppFailure>().having((e) => e.code, 'code', 'invalid_code')),
    );
    expect(
      () => repository.verifyCode(phone: '9800000000', code: '000000'),
      throwsA(isA<AppFailure>().having((e) => e.code, 'code', 'rate_limited')),
    );
    expect(
      () => repository.verifyCode(phone: '9800000000', code: '999999'),
      throwsA(isA<AppFailure>().having((e) => e.code, 'code', 'offline')),
    );
  });

  test('verified session can be restored and signed out', () async {
    await repository.sendCode('9800000000');
    final session = await repository.verifyCode(
      phone: '9800000000',
      code: MockAuthRepository.demoCode,
    );

    expect(session.user.phone, '+9779800000000');
    expect(session.token, startsWith('mock-id-token'));

    final restored = await repository.restoreSession();
    expect(restored?.id, session.user.id);

    await repository.signOut();
    expect(await repository.restoreSession(), isNull);
  });
}
