import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/app_config.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/network/token_store.dart';
import 'package:nepal_lend/features/auth/data/auth_repository.dart';

/// End-to-end auth flow against the in-process mock adapter (spec-shaped).
void main() {
  late TokenStore store;
  late AuthRepository repo;

  setUp(() async {
    store = TokenStore();
    await store.clear(); // static fallback state must not leak across tests
    repo = AuthRepository(ApiClient(env: AppEnv.mock), store);
  });

  test('requestOtp returns a challenge with a masked phone', () async {
    final challenge = await repo.requestOtp('9841234567');
    expect(challenge.requestId, 'mock-otp-9841234567');
    expect(challenge.maskedPhone, '9841***567');
    expect(challenge.expiresInSeconds, 120);
    expect(challenge.devCode, '123456'); // non-production echo
  });

  test('me() without a token is rejected by the bearer guard', () async {
    await expectLater(repo.me(), throwsA(isA<AuthException>()));
    try {
      await repo.me();
    } on AuthException catch (e) {
      expect(e.statusCode, 401);
      expect(e.message, 'Missing or invalid access token');
    }
  });

  test('wrong OTP maps the 401 to AuthException', () async {
    try {
      await repo.verifyOtp('mock-otp-9841234567', '000000');
      fail('expected AuthException');
    } on AuthException catch (e) {
      expect(e.statusCode, 401);
      expect(e.message, 'Incorrect or expired code');
    }
  });

  test('correct OTP returns a new-user session and stores tokens', () async {
    final session = await repo.verifyOtp('mock-otp-9841234567', '123456');
    expect(session.isNewUser, isTrue);
    expect(session.accessToken, 'mock-access-token');
    expect(session.refreshToken, 'mock-refresh-token');
    expect(session.user.phone, '9841234567');
    expect(session.user.role, 'borrower');
    expect(await store.readAccessToken(), 'mock-access-token');
  });

  test('me() attaches the bearer token via the interceptor', () async {
    await repo.verifyOtp('mock-otp-9841234567', '123456');
    final user = await repo.me();
    expect(user.id, 'mock-user');
    expect(user.kycState, 'unstarted');
  });

  test('updateProfile(role) returns the updated role', () async {
    await repo.verifyOtp('mock-otp-9841234567', '123456');
    final user = await repo.updateProfile(role: 'lender');
    expect(user.role, 'lender');
  });

  test('logout clears tokens and locks the API again', () async {
    await repo.verifyOtp('mock-otp-9841234567', '123456');
    await repo.logout(); // must not throw on 204
    expect(await store.readAccessToken(), isNull);
    await expectLater(repo.me(), throwsA(isA<AuthException>()));
  });
}
