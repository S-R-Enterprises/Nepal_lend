import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/app_config.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/network/api_exception.dart';
import 'package:nepal_lend/core/network/token_store.dart';
import 'package:nepal_lend/features/kyc/data/kyc_repository.dart';

/// End-to-end KYC checklist flow against the in-process mock adapter.
void main() {
  late TokenStore store;
  late KycRepository repo;

  setUp(() async {
    store = TokenStore();
    await store.clear(); // static fallback state must not leak across tests
    repo = KycRepository(ApiClient(env: AppEnv.mock));
    await store.save(accessToken: 'mock-access-token', refreshToken: 'r');
  });

  test('rejects getStatus without a bearer token', () async {
    await store.clear();
    try {
      await repo.getStatus();
      fail('expected ApiException');
    } on ApiException catch (e) {
      expect(e.statusCode, 401);
    }
  });

  test('starts unstarted with the four contract steps', () async {
    final status = await repo.getStatus();
    expect(status.state, 'unstarted');
    expect(status.steps.map((s) => s.id), [
      'citizenship',
      'selfie',
      'details',
      'bank_statement',
    ]);
    expect(status.steps.map((s) => s.label), [
      'Citizenship document',
      'Selfie verification',
      'Personal details',
      'Bank statement (6 months)',
    ]);
    expect(status.approvedCount, 0);
    expect(status.isVerified, isFalse);
  });

  test('walks unstarted -> in_review -> verified', () async {
    final afterOne = await repo.verifyStep('citizenship');
    expect(afterOne.state, 'in_review');
    expect(afterOne.steps.first.isApproved, isTrue);
    expect(afterOne.approvedCount, 1);

    await repo.verifyStep('selfie');
    await repo.verifyStep('details');
    final done = await repo.verifyStep('bank_statement');
    expect(done.state, 'verified');
    expect(done.approvedCount, 4);
    expect(done.isVerified, isTrue);
  });

  test('invalid step id maps the 400 to ApiException', () async {
    try {
      await repo.verifyStep('face');
      fail('expected ApiException');
    } on ApiException catch (e) {
      expect(e.statusCode, 400);
      expect(e.message, contains('citizenship'));
    }
  });
}
