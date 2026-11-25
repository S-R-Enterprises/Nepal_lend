import 'package:flutter_test/flutter_test.dart';
import 'package:nepal_lend/core/config/env.dart';
import 'package:nepal_lend/core/network/api_client.dart';
import 'package:nepal_lend/core/utils/error_mapper.dart';
import 'package:nepal_lend/data/mock/mock_db.dart';
import 'package:nepal_lend/data/models/app_user.dart';
import 'package:nepal_lend/data/models/enums.dart';
import 'package:nepal_lend/data/models/kyc.dart';
import 'package:nepal_lend/features/kyc/data/document_picker.dart';
import 'package:nepal_lend/features/kyc/data/kyc_repository.dart';
import 'package:nepal_lend/features/kyc/data/mock_kyc_repository.dart';

void main() {
  late KycRepository repository;

  setUp(() async {
    await MockDb.instance.clear();
    MockDb.instance.kycProfile = KycProfile.initial();
    await MockDb.instance.setUser(
      const AppUser(id: 'demo-user', phone: '+9779800000000'),
    );
    final api = ApiClient(
      env: const Env(
        environment: AppEnvironment.mock,
        apiBaseUrl: 'https://mock.local/api/v1',
      ),
    );
    repository = MockKycRepository(api: api);
  });

  test('load returns the four seeded steps', () async {
    final profile = await repository.load();
    expect(profile.completedCount, 0);
    expect(profile.overallState, KycStatus.notStarted);
  });

  test('document creation echoes the local path and submit stores it', () async {
    const document = PickedDocument(
      path: '/tmp/citizenship.jpg',
      name: 'citizenship.jpg',
    );

    final submitted = await repository.submitDocument(
      KycStepKind.citizenship,
      document: document,
    );

    final step = submitted.step(KycStepKind.citizenship);
    expect(step.status, KycStatus.inReview);
    expect(step.documentPath, document.path);
    expect(submitted.overallState, KycStatus.inReview);

    final reloaded = await repository.load();
    expect(
      reloaded.step(KycStepKind.citizenship).documentPath,
      document.path,
    );
  });

  test('personal details are stored with the step', () async {
    final profile = await repository.submitPersonalDetails(const {
      'fullName': 'Sita Sharma',
      'citizenshipNumber': '001-02-345678',
      'dateOfBirth': '1998-04-12',
      'bankName': 'Nepal Bank',
      'accountNumber': '1234567890',
    });

    expect(profile.details['fullName'], 'Sita Sharma');
    expect(
      profile.step(KycStepKind.personalDetails).status,
      KycStatus.inReview,
    );
  });

  test('admin decision moves steps forward and rejects illegal jumps', () async {
    await repository.submitDocument(
      KycStepKind.selfie,
      document: const PickedDocument(path: '/tmp/selfie.jpg', name: 'selfie.jpg'),
    );

    final verified = await repository.decide(
      KycStepKind.selfie,
      KycStatus.verified,
    );
    expect(verified.step(KycStepKind.selfie).isVerified, isTrue);

    expect(
      () => repository.decide(KycStepKind.selfie, KycStatus.rejected),
      throwsA(isA<AppFailure>().having(
        (error) => error.code,
        'code',
        'invalid_transition',
      )),
    );
  });

  test('rejected step can be resubmitted', () async {
    await repository.submitDocument(
      KycStepKind.bankStatement,
      document: const PickedDocument(path: '/tmp/bank.jpg', name: 'bank.jpg'),
    );
    await repository.decide(
      KycStepKind.bankStatement,
      KycStatus.rejected,
      reason: 'Name not visible',
    );

    final retried = await repository.submitDocument(
      KycStepKind.bankStatement,
      document: const PickedDocument(path: '/tmp/bank2.jpg', name: 'bank2.jpg'),
    );
    final step = retried.step(KycStepKind.bankStatement);
    expect(step.status, KycStatus.inReview);
    expect(step.reason, isNull);
    expect(step.documentPath, '/tmp/bank2.jpg');
  });

  test('demo approve-all verifies the user in MockDb', () async {
    final profile = await repository.approveAll();

    expect(profile.allVerified, isTrue);
    expect(MockDb.instance.currentUser?.isVerified, isTrue);
    expect((await repository.load()).overallState, KycStatus.verified);
  });
}
